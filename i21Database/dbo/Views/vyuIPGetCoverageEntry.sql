CREATE VIEW vyuIPGetCoverageEntry
AS
SELECT C.intCoverageEntryId
	,C.strBatchName
	,C.dtmDate
	,C.intUOMId
	,C.intBookId
	,C.intSubBookId
	,C.intCommodityId
	,C.strUOMType
	,C.intDecimal
	,C.ysnPosted
	,C.intCoverageEntryRefId
	,C.intConcurrencyId
	,UOM.strUnitMeasure
	,B.strBook
	,SB.strSubBook
	,COM.strCommodityCode
FROM tblRKCoverageEntry C WITH (NOLOCK)
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = C.intUOMId
LEFT JOIN tblCTBook B WITH (NOLOCK) ON B.intBookId = C.intBookId
LEFT JOIN tblCTSubBook SB WITH (NOLOCK) ON SB.intSubBookId = C.intSubBookId
LEFT JOIN tblICCommodity COM WITH (NOLOCK) ON COM.intCommodityId = C.intCommodityId
