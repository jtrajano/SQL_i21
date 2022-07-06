CREATE VIEW dbo.vyuCTGetRawToWipConversion
AS
SELECT
	  r.intRawToWipConversionId
	, r.intBookId
	, r.intSubBookId
	, r.intFuturesMarketId
	, CAST(ISNULL(r.dblQuantityPerLot, 0.0) AS NUMERIC(38, 20)) dblQuantityPerLot
	, c.intCommodityId
	, c.strCommodityCode
	, fm.dblContractSize
	, fm.dblConversionRate
	, fm.strFutMarketName strFuturesMarket
	, fm.strFutSymbol strFuturesSymbol
	, fm.intUnitMeasureId
	, m.strUnitMeasure
	, b.strBook
	, b.strBookDescription
	, sb.strSubBook
	, sb.strSubBookDescription
	, r.intConcurrencyId
	, intCommodityUOMId = cu.intCommodityUnitMeasureId
FROM tblCTRawToWipConversion r
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = r.intFuturesMarketId
JOIN tblRKCommodityMarketMapping cmm ON cmm.intFutureMarketId = fm.intFutureMarketId
JOIN tblICCommodity c ON c.intCommodityId = cmm.intCommodityId
JOIN tblICUnitMeasure m ON m.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId = c.intCommodityId and cu.intUnitMeasureId = m.intUnitMeasureId
JOIN tblCTBook b ON b.intBookId = r.intBookId
JOIN tblCTSubBook sb ON sb.intSubBookId = r.intSubBookId AND sb.intBookId = b.intBookId