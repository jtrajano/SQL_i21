CREATE VIEW vyuIPGetFuturesSettlementPrice
AS
SELECT FSP.intFutureSettlementPriceId
	,FSP.intFutureMarketId
	,FSP.intCommodityMarketId
	,FSP.dtmPriceDate
	,FSP.strPricingType
	,FSP.intConcurrencyId
	,FSP.intFutureSettlementPriceRefId
	,M.strFutMarketName
	,C.strCommodityCode
FROM tblRKFuturesSettlementPrice FSP
JOIN tblRKFutureMarket M ON M.intFutureMarketId = FSP.intFutureMarketId
JOIN tblRKCommodityMarketMapping MM ON MM.intCommodityMarketId = FSP.intCommodityMarketId
JOIN tblICCommodity C ON C.intCommodityId = MM.intCommodityId
