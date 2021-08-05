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
FROM tblCTRawToWipConversion r
JOIN tblICCommodity c ON c.intFutureMarketId = r.intFuturesMarketId
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = c.intFutureMarketId
LEFT JOIN tblICUnitMeasure m ON m.intUnitMeasureId = fm.intUnitMeasureId
JOIN tblCTBook b ON b.intBookId = r.intBookId
LEFT JOIN tblCTSubBook sb ON sb.intSubBookId = r.intSubBookId
	AND sb.intBookId = b.intBookId