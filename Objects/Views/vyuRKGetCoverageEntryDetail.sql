CREATE VIEW [dbo].[vyuRKGetCoverageEntryDetail]

AS

SELECT Header.intCoverageEntryId
    , Header.strBatchName
    , Header.dtmDate
	, Header.intCommodityId
	, Header.strCommodity
    , Header.strUOMType
    , Header.intDecimal
	, Header.ysnPosted
	, Detail.intCoverageEntryDetailId
    , Detail.intProductTypeId
	, strProductType = Attribute.strDescription
    , Detail.intBookId
	, Book.strBook
    , Detail.intSubBookId
	, SubBook.strSubBook
    , Detail.dblOpenContract
    , Detail.dblInTransit
    , Detail.dblStock
	, dblTotalPhysical = (Detail.dblOpenContract + Detail.dblInTransit + Detail.dblStock)
    , Detail.dblOpenFutures
	, dblTotalPosition = (Detail.dblOpenContract + Detail.dblInTransit + Detail.dblStock + Detail.dblOpenFutures)
    , Detail.intMonthsCovered
    , Detail.dblAveragePrice
    , Detail.dblOptionsCovered
    , Detail.dblFuturesM2M
	, dblM2MPlus10 = Detail.dblFuturesM2M
	, dblM2MMinus10 = Detail.dblFuturesM2M
    , Detail.intConcurrencyId
FROM tblRKCoverageEntryDetail Detail
LEFT JOIN vyuRKGetCoverageEntry Header ON Header.intCoverageEntryId = Detail.intCoverageEntryId
LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId = Detail.intProductTypeId
LEFT JOIN tblCTBook Book ON Book.intBookId = Detail.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Detail.intSubBookId