CREATE PROCEDURE uspQMSaveTestInTemplates @intTestId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intSeqNo INT
	,@intPropertyId INT
	,@strIsMandatory NVARCHAR(20)
	,@intProductId INT
	,@intRowNo INT
	,@intTemplateProductId INT
DECLARE @NewProperty TABLE (
	intSeqNo INT IDENTITY(1, 1)
	,intPropertyId INT
	)
DECLARE @ExistingTemplates TABLE (
	intSeqNo INT IDENTITY(1, 1)
	,intProductId INT
	,intSequenceNo INT
	)
DECLARE @TestProperty TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intTestPropertyId INT
	,intSequenceNo INT
	)
DECLARE @ExistingTemplatesSeqNo TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intProductId INT
	)
DECLARE @ProductProperty TABLE (
	intProductRowNo INT IDENTITY(1, 1)
	,intProductPropertyId INT
	,intSequenceNo INT
	)

-- Delete the properties which are not available in Test
DELETE
FROM tblQMProductProperty
WHERE intTestId = @intTestId
	AND intPropertyId NOT IN (
		SELECT intPropertyId
		FROM tblQMTestProperty
		WHERE intTestId = @intTestId
		)

-- Insert the properties which are added in Test and not available in template
INSERT INTO @NewProperty
SELECT intPropertyId
FROM tblQMTestProperty
WHERE intTestId = @intTestId
--AND intPropertyId NOT IN (
--	SELECT DISTINCT intPropertyId
--	FROM tblQMProductProperty
--	WHERE intTestId = @intTestId
--	)
ORDER BY intSequenceNo

SELECT @intSeqNo = MIN(intSeqNo)
FROM @NewProperty

WHILE (@intSeqNo > 0)
BEGIN
	SELECT @intPropertyId = intPropertyId
	FROM @NewProperty
	WHERE intSeqNo = @intSeqNo

	SELECT @strIsMandatory = strIsMandatory
	FROM tblQMProperty
	WHERE intPropertyId = @intPropertyId

	DELETE
	FROM @ExistingTemplates

	INSERT INTO @ExistingTemplates
	SELECT DISTINCT intProductId
		,(
			SELECT MAX(intSequenceNo) + 1
			FROM tblQMProductProperty
			WHERE intProductId = PP.intProductId
			) AS intSequenceNo
	FROM tblQMProductProperty PP
	WHERE PP.intTestId = @intTestId
		AND PP.intProductId NOT IN (
			SELECT intProductId
			FROM tblQMProductProperty
			WHERE intTestId = @intTestId
				AND intPropertyId = @intPropertyId
			)
	ORDER BY PP.intProductId

	INSERT INTO tblQMProductProperty (
		intConcurrencyId
		,intProductId
		,intTestId
		,intPropertyId
		,strFormulaParser
		,strComputationMethod
		,intSequenceNo
		,intComputationTypeId
		,strFormulaField
		,strIsMandatory
		,ysnPrintInLabel
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,t.intProductId
		,@intTestId
		,@intPropertyId
		,''
		,''
		,t.intSequenceNo
		,1
		,''
		,@strIsMandatory
		,0
		,@intUserId
		,GETDATE()
		,@intUserId
		,GETDATE()
	FROM @ExistingTemplates t

	SELECT @intProductId = MIN(intProductId)
	FROM @ExistingTemplates

	WHILE (@intProductId > 0)
	BEGIN
		INSERT INTO tblQMProductPropertyValidityPeriod (
			intConcurrencyId
			,intProductPropertyId
			,dtmValidFrom
			,dtmValidTo
			,strPropertyRangeText
			,dblMinValue
			,dblMaxValue
			,dblLowValue
			,dblHighValue
			,intUnitMeasureId
			,strFormula
			,strFormulaParser
			,PP.intCreatedUserId
			,PP.dtmCreated
			,PP.intLastModifiedUserId
			,PP.dtmLastModified
			)
		SELECT 1
			,PP.intProductPropertyId
			,PV.dtmValidFrom
			,PV.dtmValidTo
			,PV.strPropertyRangeText
			,PV.dblMinValue
			,PV.dblMaxValue
			,PV.dblLowValue
			,PV.dblHighValue
			,PV.intUnitMeasureId
			,P.strFormula
			,P.strFormulaParser
			,@intUserId
			,GETDATE()
			,@intUserId
			,GETDATE()
		FROM tblQMPropertyValidityPeriod AS PV
		JOIN tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
		JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId
			AND PV.intPropertyId = P.intPropertyId
			AND PP.intProductId = @intProductId
			AND NOT EXISTS (
				-- To ignore already available Product Properties
				SELECT *
				FROM tblQMProductPropertyValidityPeriod PPV
				WHERE PPV.intProductPropertyId = PP.intProductPropertyId
				)

		INSERT INTO tblQMConditionalProductProperty (
			intProductPropertyId
			,intConcurrencyId
			,intOnSuccessPropertyId
			,intOnFailurePropertyId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT PP.intProductPropertyId
			,1
			,CP.intOnSuccessPropertyId
			,CP.intOnFailurePropertyId
			,@intUserId
			,GETDATE()
			,@intUserId
			,GETDATE()
		FROM tblQMConditionalProperty CP
		JOIN tblQMProductProperty PP ON PP.intPropertyId = CP.intPropertyId
			AND PP.intProductId = @intProductId
			AND NOT EXISTS (
				-- To ignore already available Product Conditional Properties in Update mode  
				SELECT *
				FROM tblQMConditionalProductProperty CPP
				WHERE CPP.intProductPropertyId = PP.intProductPropertyId
				)

		SELECT @intProductId = MIN(intProductId)
		FROM @ExistingTemplates
		WHERE intProductId > @intProductId
	END

	SELECT @intSeqNo = MIN(intSeqNo)
	FROM @NewProperty
	WHERE intSeqNo > @intSeqNo
END

-- Updating seq no in Test starting from 1
INSERT INTO @TestProperty
SELECT intTestPropertyId
	,ROW_NUMBER() OVER (
		PARTITION BY intTestId ORDER BY intTestId
			,intSequenceNo
		)
FROM tblQMTestProperty
WHERE intTestId = @intTestId

UPDATE tblQMTestProperty
SET intSequenceNo = a.intSequenceNo
FROM @TestProperty a
JOIN tblQMTestProperty TP ON TP.intTestPropertyId = a.intTestPropertyId

-- Updating seq no in Template starting from 1(taking order from Test)
INSERT INTO @ExistingTemplatesSeqNo
SELECT DISTINCT intProductId
FROM tblQMProductProperty PP
WHERE PP.intTestId = @intTestId
ORDER BY PP.intProductId

SELECT @intRowNo = MIN(intRowNo)
FROM @ExistingTemplatesSeqNo

WHILE (@intRowNo > 0)
BEGIN
	SELECT @intTemplateProductId = intProductId
	FROM @ExistingTemplatesSeqNo
	WHERE intRowNo = @intRowNo

	DELETE
	FROM @ProductProperty

	INSERT INTO @ProductProperty
	SELECT PP.intProductPropertyId
		,ROW_NUMBER() OVER (
			ORDER BY PT.intProductTestId
				,TP.intSequenceNo
			) AS intSequenceNo
	FROM tblQMProductProperty PP
	JOIN tblQMProductTest PT ON PT.intProductId = PP.intProductId
		AND PT.intTestId = PP.intTestId
	JOIN tblQMTestProperty TP ON TP.intTestId = PP.intTestId
		AND TP.intPropertyId = PP.intPropertyId
	WHERE PP.intProductId = @intTemplateProductId

	UPDATE tblQMProductProperty
	SET intSequenceNo = a.intSequenceNo
	FROM @ProductProperty a
	JOIN tblQMProductProperty TP ON TP.intProductPropertyId = a.intProductPropertyId

	SELECT @intRowNo = MIN(intRowNo)
	FROM @ExistingTemplatesSeqNo
	WHERE intRowNo > @intRowNo
END
