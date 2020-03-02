CREATE VIEW vyuIPGetPropertyValidityPeriod
AS
SELECT PVP.intPropertyValidityPeriodId
	,PVP.intPropertyId
	,PVP.intConcurrencyId
	,PVP.dtmValidFrom
	,PVP.dtmValidTo
	,PVP.strPropertyRangeText
	,PVP.dblMinValue
	,PVP.dblMaxValue
	,PVP.dblLowValue
	,PVP.dblHighValue
	,PVP.intUnitMeasureId
	,PVP.intCreatedUserId
	,PVP.dtmCreated
	,PVP.intLastModifiedUserId
	,PVP.dtmLastModified
	,PVP.intPropertyValidityPeriodRefId
	,UOM.strUnitMeasure
FROM tblQMPropertyValidityPeriod PVP WITH (NOLOCK)
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = PVP.intUnitMeasureId
