CREATE VIEW vyuRKMarketDetail
AS
SELECT intFutureMarketId
	,strFutMarketName
	,strFutSymbol AS strFutSymbol
	,um1.strUnitMeasure
	,c.strCurrency strCurrency
	,um.strUnitMeasure strForecastUnitMeasure
FROM tblRKFutureMarket fm
INNER JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
INNER JOIN tblICUnitMeasure um1 ON fm.intUnitMeasureId = um1.intUnitMeasureId
LEFT JOIN tblICUnitMeasure um ON fm.intForecastWeeklyConsumptionUOMId = um.intUnitMeasureId