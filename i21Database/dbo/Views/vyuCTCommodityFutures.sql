CREATE VIEW dbo.vyuCTCommodityFutures
AS
SELECT
	  c.intCommodityId
	, c.strCommodityCode
	, fm.dblContractSize
	, fm.dblConversionRate
	, fm.strFutMarketName strFuturesMarket
	, fm.strFutSymbol strFuturesSymbol
	, fm.intUnitMeasureId
	, m.strUnitMeasure
	, fm.intFutureMarketId intFuturesMarketId
FROM tblICCommodity c
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = c.intFutureMarketId
LEFT JOIN tblICUnitMeasure m ON m.intUnitMeasureId = fm.intUnitMeasureId
