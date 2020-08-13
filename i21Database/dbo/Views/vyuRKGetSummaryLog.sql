CREATE VIEW [dbo].[vyuRKGetSummaryLog]

AS

SELECT SL.intSummaryLogId
	, SL.strBatchId
	, SL.dtmCreatedDate
	, SL.strBucketType
	, SL.intActionId
	, SL.strAction
	, SL.strTransactionType
	, SL.intTransactionRecordId
	, SL.intTransactionRecordHeaderId
	, SL.strDistributionType
	, SL.strTransactionNumber
	, SL.dtmTransactionDate
	, SL.intContractDetailId
	, SL.intContractHeaderId
	, CH.strContractNumber
	, CD.intContractSeq
	, strContractSeq = CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(10))
	, strContractType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase' WHEN CH.intContractTypeId  = 2 THEN 'Sale' ELSE NULL END) COLLATE Latin1_General_CI_AS
	, SL.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
	, SL.intFutureMonthId
	, fMon.strFutureMonth
	, fMon.dtmFutureMonthsDate
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
	, UOM.strUnitMeasure
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
	, t.strTicketNumber
	, SL.intUserId
	, strUserName = U.strName
	, SL.strNotes
	, SL.ysnNegate
	, SL.intRefSummaryLogId
	, SL.strMiscField
	, dtmStartDate
	, dtmEndDate
	, SL.intCurrencyId
	, strCurrency
FROM tblRKSummaryLog SL
LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = SL.intLocationId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = SL.intCommodityId
LEFT JOIN tblICItem Item ON Item.intItemId = SL.intItemId
LEFT JOIN tblICCategory Cat ON Cat.intCategoryId = Item.intCategoryId
LEFT JOIN tblCTBook Book ON Book.intBookId = SL.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = SL.intSubBookId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SL.intContractHeaderId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = SL.intContractDetailId
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = SL.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = SL.intFutureMonthId
LEFT JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
LEFT JOIN tblEMEntity U ON U.intEntityId = SL.intUserId
LEFT JOIN tblSCTicket t ON t.intTicketId = SL.intTicketId
LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cUOM.intUnitMeasureId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = SL.intCurrencyId