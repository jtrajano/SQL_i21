CREATE VIEW [dbo].[vyuRKGetMarketCommodity]
AS  
SELECT 
	mm.intCommodityMarketId,
	fm.intFutureMarketId,
	c.intCommodityId,
	c.strCommodityCode,
	fm.strFutMarketName,	
	mm.strFutSymbol,
	mm.dblContractSize,
	um.intUnitMeasureId,
	um.strUnitMeasure,
	sm.intCurrencyID,
	sm.strCurrency,
	strCommodityAttributeId =  dbo.fnRKRKConvertProductTypeKeyToName(mm.strCommodityAttributeId)
FROM tblICCommodity c
JOIN tblRKCommodityMarketMapping mm on c.intCommodityId=mm.intCommodityId
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=mm.intFutureMarketId
JOIN tblICUnitMeasure um on mm.intUnitMeasureId=um.intUnitMeasureId
JOIN tblSMCurrency sm on sm.intCurrencyID= mm.intCurrencyId

