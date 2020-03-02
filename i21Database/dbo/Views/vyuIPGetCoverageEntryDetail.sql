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
FROM tblRKCoverageEntryDetail CD WITH (NOLOCK)
LEFT JOIN tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = CD.intProductTypeId
LEFT JOIN tblCTBook B WITH (NOLOCK) ON B.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SB WITH (NOLOCK) ON SB.intSubBookId = CD.intSubBookId
