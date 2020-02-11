CREATE VIEW vyuIPGetProductPropertyValidityPeriod
AS
SELECT PPV.intProductPropertyValidityPeriodId
	,PPV.intConcurrencyId
	,PPV.intProductPropertyId
	,PPV.dtmValidFrom
	,PPV.dtmValidTo
	,PPV.strPropertyRangeText
	,PPV.dblMinValue
	,PPV.dblMaxValue
	,PPV.dblLowValue
	,PPV.dblHighValue
	,PPV.intUnitMeasureId
	,PPV.strFormula
	,PPV.strFormulaParser
	,PPV.intCreatedUserId
	,PPV.dtmCreated
	,PPV.intLastModifiedUserId
	,PPV.dtmLastModified
	,PPV.intProductPropertyValidityPeriodRefId
	,UOM.strUnitMeasure
	,T.strTestName
	,P.strPropertyName
	,PP.intProductId
FROM tblQMProductPropertyValidityPeriod PPV
JOIN tblQMProductProperty PP ON PP.intProductPropertyId = PPV.intProductPropertyId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = PPV.intUnitMeasureId
LEFT JOIN tblQMTest T ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
