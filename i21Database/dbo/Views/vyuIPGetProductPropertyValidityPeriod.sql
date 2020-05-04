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
FROM tblQMProductPropertyValidityPeriod PPV WITH (NOLOCK)
JOIN tblQMProductProperty PP WITH (NOLOCK) ON PP.intProductPropertyId = PPV.intProductPropertyId
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = PPV.intUnitMeasureId
LEFT JOIN tblQMTest T WITH (NOLOCK) ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = PP.intPropertyId
