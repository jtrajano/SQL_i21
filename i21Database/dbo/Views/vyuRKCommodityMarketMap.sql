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
,CAST(CASE WHEN (SELECT TOP 1 intFutureSettlementPriceId FROM tblRKFuturesSettlementPrice fut WHERE fut.intFutureMarketId = m.intFutureMarketId and fut.intCommodityMarketId = mm.intCommodityId) IS NOT NULL 
			OR (SELECT TOP 1 intFutOptTransactionId FROM tblRKFutOptTransaction der WHERE der.intFutureMarketId = m.intFutureMarketId and der.intCommodityId = mm.intCommodityId) IS NOT NULL
	THEN
	1
 ELSE
  0
  END as bit) as ysnCommodityInUse
,0 as [intConcurrencyId]
from tblRKFutureMarket m 
JOIN tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId
JOIN tblICCommodity ic on ic.intCommodityId=mm.intCommodityId
INNER JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
INNER JOIN tblICUnitMeasure um1 ON m.intUnitMeasureId = um1.intUnitMeasureId
LEFT JOIN tblICUnitMeasure um ON m.intForecastWeeklyConsumptionUOMId = um.intUnitMeasureId
