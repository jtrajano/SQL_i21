CREATE VIEW vyuRKMarketDetail

AS

SELECT intFutureMarketId,strFutMarketName,strFutSymbol as strFutSymbol
,um1.strUnitMeasure,c.strCurrency strCurrency,um.strUnitMeasure strForecastUnitMeasure
FROM tblRKFutureMarket fm
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
JOIN tblICUnitMeasure um1 on fm.intUnitMeasureId=um1.intUnitMeasureId
LEFT JOIN tblICUnitMeasure um on fm.intForecastWeeklyConsumptionUOMId=um.intUnitMeasureId