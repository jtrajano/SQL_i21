CREATE VIEW vyuRKCommodityMarketMap
AS

SELECT 
 mm.intCommodityMarketId
,mm.intCommodityId
,dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) strCommodityAttributeId
,ic.strCommodityCode
,dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) as strDescription
,um1.strUnitMeasure
,c.strCurrency strCurrency
,um.strUnitMeasure strForecastUnitMeasure 
,0 as [intConcurrencyId]
from tblRKFutureMarket m 
JOIN tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId
JOIN tblICCommodity ic on ic.intCommodityId=mm.intCommodityId
INNER JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
INNER JOIN tblICUnitMeasure um1 ON m.intUnitMeasureId = um1.intUnitMeasureId
LEFT JOIN tblICUnitMeasure um ON m.intForecastWeeklyConsumptionUOMId = um.intUnitMeasureId
