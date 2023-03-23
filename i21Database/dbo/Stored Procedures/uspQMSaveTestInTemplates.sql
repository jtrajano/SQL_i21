CREATE PROCEDURE uspQMSaveTestInTemplates 
	@intTestId INT
  , @intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intSeqNo				INT
	  , @intPropertyId			INT
	  , @strIsMandatory			NVARCHAR(20)
	  , @intProductId			INT
	  , @intRowNo				INT
	  , @intTemplateProductId	INT

DECLARE @TestProperty TABLE 
(
	intRowNo			INT IDENTITY(1, 1)
  , intTestPropertyId	INT
  , intSequenceNo		INT
)

DECLARE @ProductProperty TABLE 
(
	intProductRowNo		 INT IDENTITY(1, 1)
  , intProductPropertyId INT
  , intSequenceNo		 INT
)

DECLARE @InterCompanyExistingTemplates TABLE 
(
	intProductId INT
)

DECLARE @ICintProductId INT

-- Add all the existing templates
INSERT INTO @InterCompanyExistingTemplates (intProductId)
SELECT DISTINCT intProductId
FROM tblQMProductTest
WHERE intTestId = @intTestId

-- Delete the properties which are not available in Test
DELETE
FROM tblQMProductProperty
WHERE intTestId = @intTestId
	AND intPropertyId NOT IN (
		SELECT intPropertyId
		FROM tblQMTestProperty
		WHERE intTestId = @intTestId
		)

INSERT INTO tblQMProductProperty 
(
	intConcurrencyId
  , intProductId
  , intTestId
  , intPropertyId
  , strFormulaParser
  , strComputationMethod
  , intComputationTypeId
  , strFormulaField
  , strIsMandatory
  , ysnPrintInLabel
  , intCreatedUserId
  , dtmCreated
  , intLastModifiedUserId
  , dtmLastModified
  , intSequenceNo
)
SELECT DISTINCT 1 
			  , ProductProperty.intProductId
			  , @intTestId
			  , TestProperty.intPropertyId
			  , ''
			  , ''
			  , 1
			  , ''
			  , Property.strIsMandatory
			  , 0
			  , @intUserId
			  , GETDATE()
			  , @intUserId
			  , GETDATE()
			  , TestProperty.intSequenceNo
FROM tblQMTestProperty AS TestProperty
JOIN tblQMProperty AS Property ON TestProperty.intPropertyId = TestProperty.intPropertyId
JOIN tblQMProductProperty AS ProductProperty ON ProductProperty.intPropertyId = Property.intPropertyId
WHERE TestProperty.intTestId = @intTestId AND TestProperty.intPropertyId NOT IN (SELECT DISTINCT intPropertyId
																				 FROM tblQMProductProperty
																				 WHERE intTestId = @intTestId)
ORDER BY TestProperty.intSequenceNo;

/* Sync Template and Insert new property validity period added based on Test Property. */
INSERT INTO tblQMProductPropertyValidityPeriod 
(
	intConcurrencyId
  , intProductPropertyId
  , dtmValidFrom
  , dtmValidTo
  , strPropertyRangeText
  , dblMinValue
  , dblMaxValue
  , dblLowValue
  , dblHighValue
  , intUnitMeasureId
  , strFormula
  , strFormulaParser
  , intCreatedUserId
  , dtmCreated
  , intLastModifiedUserId
  , dtmLastModified
)
SELECT 1
	 , PP.intProductPropertyId
	 , PV.dtmValidFrom
	 , PV.dtmValidTo
	 , PV.strPropertyRangeText
	 , PV.dblMinValue
	 , PV.dblMaxValue
	 , PV.dblLowValue
	 , PV.dblHighValue
	 , PV.intUnitMeasureId
	 , P.strFormula
	 , P.strFormulaParser
	 , @intUserId
	 , GETDATE()
	 , @intUserId
	 , GETDATE()
FROM tblQMPropertyValidityPeriod AS PV
JOIN tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId 
					   AND PV.intPropertyId = P.intPropertyId 
					   /* Remove existing Product Properties. */
					   AND NOT EXISTS (SELECT *
									   FROM tblQMProductPropertyValidityPeriod PPV
										WHERE PPV.intProductPropertyId = PP.intProductPropertyId)
WHERE PP.intTestId = @intTestId;

/* Sync Template and Insert new conditional properties added from Test. */
INSERT INTO tblQMConditionalProductProperty 
(
	intProductPropertyId
  , intConcurrencyId
  , intOnSuccessPropertyId
  , intOnFailurePropertyId
  , intCreatedUserId
  , dtmCreated
  , intLastModifiedUserId
  , dtmLastModified
)
SELECT PP.intProductPropertyId
	 , 1
	 , CP.intOnSuccessPropertyId
	 , CP.intOnFailurePropertyId
	 , @intUserId
	 , GETDATE()
	 , @intUserId
	 , GETDATE()
FROM tblQMConditionalProperty CP
JOIN tblQMProductProperty PP ON PP.intPropertyId = CP.intPropertyId 
			/* Remove existing Product Conditional Properties. */
			AND NOT EXISTS (SELECT *
							FROM tblQMConditionalProductProperty CPP
							WHERE CPP.intProductPropertyId = PP.intProductPropertyId)
WHERE PP.intTestId = @intTestId;

/* Updating Test Property Sequence No starting from no.1 sequence. */
INSERT INTO @TestProperty
SELECT intTestPropertyId
	 , ROW_NUMBER() OVER (PARTITION BY intTestId ORDER BY intTestId, intSequenceNo)
FROM tblQMTestProperty
WHERE intTestId = @intTestId

UPDATE tblQMTestProperty
SET intSequenceNo = a.intSequenceNo
FROM @TestProperty a
JOIN tblQMTestProperty TP ON TP.intTestPropertyId = a.intTestPropertyId

/* Updating seq no in Template starting from 1(taking order from Test). */

UPDATE ProductProperty 
SET ProductProperty.intSequenceNo = TestProperty.intSequenceNo
FROM tblQMProductProperty AS ProductProperty
JOIN tblQMProductTest AS ProductTest ON ProductTest.intProductId = ProductProperty.intProductId AND ProductTest.intTestId = ProductProperty.intTestId
JOIN tblQMTestProperty AS TestProperty ON TestProperty.intTestId = ProductProperty.intTestId AND TestProperty.intPropertyId = ProductProperty.intPropertyId
WHERE ProductProperty.intTestId = @intTestId

SELECT @ICintProductId = MIN(intProductId)
FROM @InterCompanyExistingTemplates

WHILE @ICintProductId IS NOT NULL
BEGIN
	EXEC uspIPInterCompanyPreStageProduct @ICintProductId
		,'Modified'
		,@intUserId

	SELECT @ICintProductId = MIN(intProductId)
	FROM @InterCompanyExistingTemplates
	WHERE intProductId > @ICintProductId
END
