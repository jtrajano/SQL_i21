CREATE VIEW [dbo].[vyuRKGetMarketCommodity]
AS  
SELECT 
	mm.intCommodityMarketId,
	fm.intFutureMarketId,
	c.intCommodityId,
	c.strCommodityCode,
	fm.strFutMarketName,	
	fm.strFutSymbol,
	fm.dblContractSize,
	um.intUnitMeasureId,
	um.strUnitMeasure,
	sm.intCurrencyID,
	sm.strCurrency,
	mm.strCommodityAttributeId
FROM tblICCommodity c
JOIN tblRKCommodityMarketMapping mm on c.intCommodityId=mm.intCommodityId
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=mm.intFutureMarketId
JOIN tblICUnitMeasure um on fm.intUnitMeasureId=um.intUnitMeasureId
JOIN tblSMCurrency sm on sm.intCurrencyID= fm.intCurrencyId
