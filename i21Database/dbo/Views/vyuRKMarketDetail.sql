CREATE VIEW vyuRKMarketDetail
AS
SELECT fm.intFutureMarketId
	,strFutMarketName
	,fm.strFutSymbol AS strFutSymbol
	,um1.intUnitMeasureId
	,um1.strUnitMeasure
	,c.intCurrencyID intCurrencyId
	,c.strCurrency strCurrency
	,um.strUnitMeasure strForecastUnitMeasure
	,um.intUnitMeasureId intForecastWeeklyConsumptionUOMId
	,mm.intCommodityId intCommodityMarketId
	,co.strCommodityCode
	,fm.dblContractSize
	,fm.strOptMarketName
	,fm.ysnOptions
FROM tblRKFutureMarket fm
INNER JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
INNER JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
INNER JOIN tblICUnitMeasure um1 ON fm.intUnitMeasureId = um1.intUnitMeasureId
INNER JOIN tblICCommodity co ON mm.intCommodityId = co.intCommodityId
LEFT JOIN tblICUnitMeasure um ON fm.intForecastWeeklyConsumptionUOMId = um.intUnitMeasureId