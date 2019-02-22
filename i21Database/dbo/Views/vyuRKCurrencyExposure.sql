CREATE VIEW vyuRKCurrencyExposure

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
	, cur.strCurrency
	, e.intConcurrencyId
	, cur.intCurrencyID intCurrencyId
	,ic.intUnitMeasureId
	,dblAP
	,dblAR
	,dblMoneyMarket
FROM tblRKCurrencyExposure e
LEFT JOIN tblICCommodity c ON c.intCommodityId = e.intCommodityId
LEFT JOIN tblICUnitMeasure ic ON ic.intUnitMeasureId = e.intWeightUnit
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = e.intCurrencyId
