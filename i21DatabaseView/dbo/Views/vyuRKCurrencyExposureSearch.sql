CREATE VIEW vyuRKCurrencyExposureSearch

AS

SELECT intCurrencyExposureId
	, strBatchName
	, dtmBatchDate
	, intWeightUnit
	, ic.strUnitMeasure
	, e.intCompanyId
	, e.intCommodityId
	, c.strCommodityCode
	, dtmFutureClosingDate
	, intCurrencyId
	, cur.strCurrency
	, e.intConcurrencyId
FROM tblRKCurrencyExposure e
LEFT JOIN tblICCommodity c ON c.intCommodityId = e.intCommodityId
LEFT JOIN tblICUnitMeasure ic ON ic.intUnitMeasureId = e.intWeightUnit
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = e.intCurrencyId