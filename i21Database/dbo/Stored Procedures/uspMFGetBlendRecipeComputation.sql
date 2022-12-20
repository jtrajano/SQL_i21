CREATE PROCEDURE [dbo].[uspMFGetBlendRecipeComputation] @strXml NVARCHAR(Max)
	,@intTypeId INT
	,@intProductId INT
AS
DECLARE @idoc INT
	,@strMethod NVARCHAR(50)
	,@intValidDate INT
	,@ysnEnableParentLot BIT = 0
	,@intProductTypeId INT
	,@dblTotal NUMERIC(18, 6)

EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
FROM tblMFCompanyPreference

IF @ysnEnableParentLot = 0
	SET @intProductTypeId = 6 --Lot
ELSE
	SET @intProductTypeId = 11 --Parent Lot

DECLARE @tblProductProperty AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intPropertyId INT
	,strPropertyName NVARCHAR(100)
	,intProductId INT
	,dblMinValue NUMERIC(18, 6)
	,dblMaxValue NUMERIC(18, 6)
	,intTestId INT
	,strTestName NVARCHAR(50)
	,intSequenceNo INT
	,dblPinpointValue NUMERIC(18, 6)
	)
DECLARE @tblComputedValue AS TABLE (
	intWorkOrderRecipeComputationId INT IDENTITY(1, 1)
	,intTestId INT
	,strTestName NVARCHAR(50)
	,intPropertyId INT
	,strPropertyName NVARCHAR(100)
	,dblComputedValue NUMERIC(18, 6)
	,dblMinValue NUMERIC(18, 6)
	,dblMaxValue NUMERIC(18, 6)
	,strMethodName NVARCHAR(50)
	,intMethodId INT
	,intSequenceNo INT
	,dblPinpointValue NUMERIC(18, 6)
	)
DECLARE @tblLot AS TABLE (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQty NUMERIC(18, 6)
	)

SET @intValidDate = (
		SELECT DATEPART(dy, GETDATE())
		)

INSERT INTO @tblProductProperty
SELECT DISTINCT PRT.intPropertyId
	,PRT.strPropertyName
	,PRD.intProductValueId
	,MIN(PPV.dblMinValue)
	,MAX(PPV.dblMaxValue)
	,TST.intTestId
	,TST.strTestName
	,PP.intSequenceNo
	,MAX(PPV.dblPinpointValue)
FROM tblQMProduct PRD
JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
JOIN tblQMProperty PRT ON PRT.intPropertyId = PP.intPropertyId
JOIN tblQMTestProperty TP ON TP.intPropertyId = PRT.intPropertyId
	AND PP.intTestId = TP.intTestId
JOIN tblQMTest TST ON TST.intTestId = TP.intTestId
WHERE PRD.intProductValueId = @intProductId
	AND PRD.intProductTypeId = 2
	AND PRD.ysnActive = 1
	AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
		AND DATEPART(dy, PPV.dtmValidTo)
GROUP BY PRT.intPropertyId
	,PRT.strPropertyName
	,PRD.intProductValueId
	,TST.intTestId
	,TST.strTestName
	,PP.intSequenceNo
ORDER BY PP.intSequenceNo

IF @ysnEnableParentLot = 0
	INSERT INTO @tblLot (
		intLotId
		,strLotNumber
		,dblQty
		)
	SELECT x.intLotId
		,l.strLotNumber
		,x.dblQty
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intLotId INT
			,dblQty NUMERIC(18, 6)
			) x
	JOIN tblICLot l ON x.intLotId = l.intLotId
ELSE
	INSERT INTO @tblLot (
		intLotId
		,dblQty
		)
	SELECT intLotId
		,dblQty
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intLotId INT
			,dblQty NUMERIC(18, 6)
			)

SELECT @strMethod = strName
FROM tblMFWorkOrderRecipeComputationMethod
WHERE intMethodId = 1

SELECT @dblTotal = SUM(dblQty)
FROM @tblLot

--Blend Management/Production
IF (@ysnEnableParentLot = 0)
BEGIN
	INSERT INTO @tblComputedValue (
		intTestId
		,strTestName
		,intPropertyId
		,strPropertyName
		,dblComputedValue
		,dblMinValue
		,dblMaxValue
		,strMethodName
		,intMethodId
		,intSequenceNo
		,dblPinpointValue
		)
	SELECT PP.intTestId
		,PP.strTestName
		,PP.intPropertyId
		,PP.strPropertyName
		,CAST(SUM(L.dblQty * ISNULL(TR.strPropertyValue, 0)) / SUM(L.dblQty) AS DECIMAL(18, 4)) AS dblComputedValue
		,PP.dblMinValue
		,PP.dblMaxValue
		,MIN(@strMethod) AS strMethodName
		,1 AS intMethodId
		,MIN(TR.intSequenceNo)
		,PP.dblPinpointValue
	FROM @tblProductProperty PP
	JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId
		AND ISNUMERIC(TR.strPropertyValue) = 1
	JOIN tblICLot lt ON lt.intLotId = TR.intProductValueId
	JOIN @tblLot AS L ON L.strLotNumber = lt.strLotNumber
		AND TR.intProductTypeId = @intProductTypeId
		AND TR.intSampleId = (
			SELECT MAX(intSampleId)
			FROM tblQMTestResult tr
			WHERE tr.intProductValueId = lt.intLotId
				AND tr.intProductTypeId = @intProductTypeId
			)
	GROUP BY PP.intPropertyId
		,PP.strPropertyName
		,PP.intTestId
		,PP.strTestName
		,PP.dblMinValue
		,PP.dblMaxValue
		,PP.dblPinpointValue

	IF NOT EXISTS (
			SELECT *
			FROM @tblComputedValue
			)
	BEGIN
		INSERT INTO @tblComputedValue (
			intTestId
			,strTestName
			,intPropertyId
			,strPropertyName
			,dblComputedValue
			,dblMinValue
			,dblMaxValue
			,strMethodName
			,intMethodId
			,intSequenceNo
			,dblPinpointValue
			)
		SELECT PP.intTestId
			,PP.strTestName
			,PP.intPropertyId
			,PP.strPropertyName
			,CAST(SUM(L.dblQty * ISNULL(TR.strPropertyValue, 0)) / SUM(L.dblQty) AS DECIMAL(18, 4)) AS dblComputedValue
			,PP.dblMinValue
			,PP.dblMaxValue
			,MIN(@strMethod) AS strMethodName
			,1 AS intMethodId
			,MIN(TR.intSequenceNo)
			,PP.dblPinpointValue
		FROM @tblProductProperty PP
		JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId
			AND ISNUMERIC(TR.strPropertyValue) = 1
		JOIN tblMFBatch lt ON lt.intBatchId = TR.intProductValueId
		JOIN @tblLot AS L ON L.strLotNumber = lt.strBatchId
			AND TR.intProductTypeId = 13
			AND TR.intSampleId = (
				SELECT MAX(intSampleId)
				FROM tblQMTestResult tr
				WHERE tr.intProductValueId = lt.intBatchId
					AND tr.intProductTypeId = 13
				)
		GROUP BY PP.intPropertyId
			,PP.strPropertyName
			,PP.intTestId
			,PP.strTestName
			,PP.dblMinValue
			,PP.dblMaxValue
			,PP.dblPinpointValue

		INSERT INTO @tblComputedValue (
			intTestId
			,strTestName
			,intPropertyId
			,strPropertyName
			,dblComputedValue
			,dblMinValue
			,dblMaxValue
			,strMethodName
			,intMethodId
			,intSequenceNo
			,dblPinpointValue
			)
		SELECT PP.intTestId
			,PP.strTestName
			,PP.intPropertyId
			,PP.strPropertyName
			,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
			,PP.dblMinValue
			,PP.dblMaxValue
			,@strMethod AS strMethodName
			,1 AS intMethodId
			,0 AS intSequenceNo
			,PP.dblPinpointValue
		FROM @tblProductProperty PP
		OUTER APPLY (
			SELECT CA.strDescription
				,sum(L.dblQty) dblQty
			FROM @tblLot L
			JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
			JOIN tblICItem I ON I.intItemId = Lot.intItemId
			JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intProductTypeId
			WHERE CA.strDescription COLLATE Latin1_General_CI_AS = PP.strPropertyName
			GROUP BY CA.strDescription
			) Type1
		WHERE PP.strTestName = 'Type'

		INSERT INTO @tblComputedValue (
			intTestId
			,strTestName
			,intPropertyId
			,strPropertyName
			,dblComputedValue
			,dblMinValue
			,dblMaxValue
			,strMethodName
			,intMethodId
			,intSequenceNo
			,dblPinpointValue
			)
		SELECT PP.intTestId
			,PP.strTestName
			,PP.intPropertyId
			,PP.strPropertyName
			,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
			,PP.dblMinValue
			,PP.dblMaxValue
			,@strMethod AS strMethodName
			,1 AS intMethodId
			,0 AS intSequenceNo
			,PP.dblPinpointValue
		FROM @tblProductProperty PP
		OUTER APPLY (
			SELECT C.strISOCode
				,sum(L.dblQty) dblQty
			FROM @tblLot L
			JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
			JOIN tblICItem I ON I.intItemId = Lot.intItemId
			JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
			JOIN tblSMCountry C ON C.intCountryID = CA.intCountryID
			WHERE C.strISOCode COLLATE Latin1_General_CI_AS = PP.strPropertyName
			GROUP BY C.strISOCode
			) Type1
		WHERE PP.strTestName = 'Origin'

		INSERT INTO @tblComputedValue (
			intTestId
			,strTestName
			,intPropertyId
			,strPropertyName
			,dblComputedValue
			,dblMinValue
			,dblMaxValue
			,strMethodName
			,intMethodId
			,intSequenceNo
			,dblPinpointValue
			)
		SELECT PP.intTestId
			,PP.strTestName
			,PP.intPropertyId
			,PP.strPropertyName
			,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
			,PP.dblMinValue
			,PP.dblMaxValue
			,@strMethod AS strMethodName
			,1 AS intMethodId
			,0 AS intSequenceNo
			,PP.dblPinpointValue
		FROM @tblProductProperty PP
		OUTER APPLY (
			SELECT B.strBrandCode
				,sum(L.dblQty) dblQty
			FROM @tblLot L
			JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
			JOIN tblICItem I ON I.intItemId = Lot.intItemId
			JOIN tblICBrand B ON B.intBrandId = I.intBrandId
			WHERE B.strBrandCode COLLATE Latin1_General_CI_AS = PP.strPropertyName
			GROUP BY B.strBrandCode
			) Type1
		WHERE PP.strTestName = 'Size'
	END
END
ELSE
BEGIN
	INSERT INTO @tblComputedValue (
		intTestId
		,strTestName
		,intPropertyId
		,strPropertyName
		,dblComputedValue
		,dblMinValue
		,dblMaxValue
		,strMethodName
		,intMethodId
		,intSequenceNo
		,dblPinpointValue
		)
	SELECT PP.intTestId
		,PP.strTestName
		,PP.intPropertyId
		,PP.strPropertyName
		,CAST(SUM(L.dblQty * ISNULL(TR.strPropertyValue, 0)) / SUM(L.dblQty) AS DECIMAL(18, 4)) AS dblComputedValue
		,PP.dblMinValue
		,PP.dblMaxValue
		,MIN(@strMethod) AS strMethodName
		,1 AS intMethodId
		,MIN(TR.intSequenceNo)
		,PP.dblPinpointValue
	FROM @tblProductProperty PP
	JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId
		AND ISNUMERIC(TR.strPropertyValue) = 1
	JOIN @tblLot AS L ON L.intLotId = TR.intProductValueId
		AND TR.intProductTypeId = @intProductTypeId
		AND TR.intSampleId = (
			SELECT MAX(intSampleId)
			FROM tblQMTestResult tr
			WHERE tr.intProductValueId = L.intLotId
				AND tr.intProductTypeId = @intProductTypeId
			)
	GROUP BY PP.intPropertyId
		,PP.strPropertyName
		,PP.intTestId
		,PP.strTestName
		,PP.dblMinValue
		,PP.dblMaxValue
		,PP.dblPinpointValue
END

SELECT *
FROM @tblComputedValue
ORDER BY intSequenceNo

IF @idoc <> 0
	EXEC sp_xml_removedocument @idoc
