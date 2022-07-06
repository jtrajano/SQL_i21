CREATE VIEW vyuMFGetContractDetail
AS
SELECT CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,CD.dtmStartDate
	,CD.dtmEndDate
	,FM.intFutureMarketId
	,FM.strFutMarketName
	,CD.dblNoOfLots
	,CD.dblQuantity
	,CD.dblFutures
	,CD.dblFXPrice
	,CD.dblRefFuturesQty AS dblRefPrice
	,CH.intBookId
	,B.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,NULL AS intSequenceNo
	,CH.intEntityId
	,CD.intContractStatusId
	,CH.ysnEnableFutures
	,[dbo].[fnCTCalculateAmountBetweenCurrency](CD.intRefFuturesCurrencyId, CD.intCurrencyId, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intRefFuturesItemUOMId,CD.dblRefFuturesQty), 0) dblRefPriceInPriceUOM
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
JOIN tblCTBook B ON B.intBookId = CH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
