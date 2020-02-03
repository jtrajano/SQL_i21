CREATE VIEW vyuIPGetCoverageEntryDetail
AS
SELECT CD.intCoverageEntryDetailId
	,CD.intCoverageEntryId
	,CD.intProductTypeId
	,CD.intBookId
	,CD.intSubBookId
	,CD.dblOpenContract
	,CD.dblInTransit
	,CD.dblStock
	,CD.dblOpenFutures
	,CD.dblMonthsCovered
	,CD.dblAveragePrice
	,CD.dblOptionsCovered
	,CD.dblFuturesM2M
	,CD.intCoverageEntryDetailRefId
	,CD.intConcurrencyId
	,B.strBook
	,SB.strSubBook
	,CA.strDescription AS strProductType
FROM tblRKCoverageEntryDetail CD
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = CD.intProductTypeId
LEFT JOIN tblCTBook B ON B.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
