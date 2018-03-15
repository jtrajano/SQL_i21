CREATE VIEW vyuRKMarketDetail
AS
SELECT fm.intFutureMarketId
	,strFutMarketName
	,fm.strFutSymbol AS strFutSymbol
	,um1.intUnitMeasureId
	,um1.strUnitMeasure
	,c.intCurrencyID intCurrencyId
	,c.strCurrency strCurrency
	,fm.intForecastWeeklyConsumption
	,um.strUnitMeasure strForecastUnitMeasure
	,um.intUnitMeasureId intForecastWeeklyConsumptionUOMId
	,intCommodityMarketId = (SELECT TOP 1  intCommodityMarketId FROM tblRKCommodityMarketMapping WHERE intFutureMarketId = fm.intFutureMarketId ORDER BY intCommodityMarketId ASC)
	,strCommodityCode = (SELECT TOP 1  strCommodityCode FROM tblRKCommodityMarketMapping mm INNER JOIN tblICCommodity co ON mm.intCommodityId = co.intCommodityId WHERE mm.intFutureMarketId = fm.intFutureMarketId ORDER BY intCommodityMarketId ASC)
	,fm.dblContractSize
	,fm.strOptMarketName
	,fm.ysnOptions
	,intCommodityId = (SELECT TOP 1  intCommodityId FROM tblRKCommodityMarketMapping WHERE intFutureMarketId = fm.intFutureMarketId ORDER BY intCommodityMarketId ASC)
FROM tblRKFutureMarket fm
--INNER JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
INNER JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
INNER JOIN tblICUnitMeasure um1 ON fm.intUnitMeasureId = um1.intUnitMeasureId
--INNER JOIN tblICCommodity co ON mm.intCommodityId = co.intCommodityId
LEFT JOIN tblICUnitMeasure um ON fm.intForecastWeeklyConsumptionUOMId = um.intUnitMeasureId