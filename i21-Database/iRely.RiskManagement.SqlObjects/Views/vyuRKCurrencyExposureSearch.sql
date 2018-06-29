CREATE VIEW vyuRKCurrencyExposureSearch

AS

SELECT
	intCurrencyExposureId,
	strBatchName,
	dtmBatchDate,
	intWeightUnit,
	dtmCurrencyExposureAsOn,
	e.intCompanyId,
	dtmMarketPremiumAsOn,
	e.intCommodityId,
	dtmFutureClosingDate,
	e.intCurrencyId ,
	c.strCommodityCode,
	ic.strUnitMeasure,
	cur.strCurrency
FROM tblRKCurrencyExposure e
JOIN tblICCommodity c on c.intCommodityId=e.intCommodityId
JOIN tblICUnitMeasure ic on ic.intUnitMeasureId=e.intWeightUnit
JOIN tblSMCurrency cur on cur.intCurrencyID=e.intCurrencyId