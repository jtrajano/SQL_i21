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
FROM tblRKCoverageEntry C
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = C.intUOMId
LEFT JOIN tblCTBook B ON B.intBookId = C.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = C.intSubBookId
LEFT JOIN tblICCommodity COM ON COM.intCommodityId = C.intCommodityId
