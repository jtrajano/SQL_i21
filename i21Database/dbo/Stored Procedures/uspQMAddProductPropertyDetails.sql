CREATE PROCEDURE uspQMAddProductPropertyDetails
	@intProductId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	,intCreatedUserId
	,dtmCreated
	,intLastModifiedUserId
	,dtmLastModified
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
	,PP.intCreatedUserId
	,PP.dtmCreated
	,PP.intLastModifiedUserId
	,PP.dtmLastModified
FROM dbo.tblQMPropertyValidityPeriod AS PV
JOIN dbo.tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId
	AND PV.intPropertyId = P.intPropertyId
	AND PP.intProductId = @intProductId
	AND NOT EXISTS (
		-- To ignore already available Product Properties in Update mode  
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
	,PP.intCreatedUserId
	,PP.dtmCreated
	,PP.intLastModifiedUserId
	,PP.dtmLastModified
FROM tblQMConditionalProperty CP
JOIN tblQMProductProperty PP ON PP.intPropertyId = CP.intPropertyId
	AND PP.intProductId = @intProductId
	AND NOT EXISTS (
		-- To ignore already available Product Conditional Properties in Update mode  
		SELECT *
		FROM tblQMConditionalProductProperty CPP
		WHERE CPP.intProductPropertyId = PP.intProductPropertyId
		)
