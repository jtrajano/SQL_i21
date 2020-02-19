CREATE VIEW [dbo].[vyuRKGetSummaryLog]

AS

SELECT SL.intSummaryLogId
	, SL.strBatchId
	, SL.dtmCreatedDate
	, SL.strBucketType
	, SL.strTransactionType
	, SL.intTransactionRecordId
	, SL.intTransactionRecordHeaderId
	, SL.strDistributionType
	, SL.strTransactionNumber
	, SL.dtmTransactionDate
	, SL.intContractDetailId
	, SL.intContractHeaderId
	, CH.strContractNumber
	, SL.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
	, SL.intFutureMonthId
	, fMon.strFutureMonth
	, SL.intFutOptTransactionId
	, SL.intCommodityId
	, Commodity.strCommodityCode
	, SL.intItemId
	, Item.strItemNo
	, Item.intCategoryId
	, Cat.strCategoryCode
	, strItemDescription = Item.strDescription
	, SL.intProductTypeId
	, SL.intOrigUOMId
	, SL.intBookId
	, Book.strBook
	, SL.intSubBookId
	, SubBook.strSubBook
	, SL.intLocationId
	, Loc.strLocationName 
	, SL.strInOut
	, SL.dblOrigNoOfLots
	, SL.dblContractSize
	, SL.dblOrigQty
	, SL.dblPrice
	, SL.intEntityId
	, strEntityName = E.strName
	, SL.intTicketId
	, SL.intUserId
	, SL.strNotes
	, SL.ysnNegate
	, SL.intRefSummaryLogId
	, SL.strMiscField
FROM tblRKSummaryLog SL
LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = SL.intLocationId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = SL.intCommodityId
LEFT JOIN tblICItem Item ON Item.intItemId = SL.intItemId
LEFT JOIN tblICCategory Cat ON Cat.intCategoryId = Item.intCategoryId
LEFT JOIN tblCTBook Book ON Book.intBookId = SL.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = SL.intSubBookId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SL.intContractHeaderId
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = SL.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = SL.intFutureMonthId
LEFT JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId