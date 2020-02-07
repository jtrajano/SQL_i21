CREATE VIEW [dbo].[vyuRKGetCoverageEntry]

AS

SELECT Header.intCoverageEntryId
    , Header.strBatchName
    , Header.dtmDate
	, Header.intUOMId
	, UOM.strUnitMeasure
    , Header.intBookId
	, Book.strBook
    , Header.intSubBookId
	, SubBook.strSubBook
    , Header.intCommodityId
	, strCommodity = Commodity.strCommodityCode
    , Header.strUOMType
    , Header.intDecimal
	, Header.ysnPosted
    , Header.intConcurrencyId
FROM tblRKCoverageEntry Header
LEFT JOIN tblCTBook Book ON Book.intBookId = Header.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Header.intSubBookId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Header.intCommodityId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = Header.intUOMId