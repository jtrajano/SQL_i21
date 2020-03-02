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
FROM tblRKFuturesSettlementPrice FSP WITH (NOLOCK)
LEFT JOIN tblRKFutureMarket M WITH (NOLOCK) ON M.intFutureMarketId = FSP.intFutureMarketId
LEFT JOIN tblRKCommodityMarketMapping MM WITH (NOLOCK) ON MM.intCommodityMarketId = FSP.intCommodityMarketId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = MM.intCommodityId
