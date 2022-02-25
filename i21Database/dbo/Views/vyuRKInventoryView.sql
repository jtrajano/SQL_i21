CREATE VIEW [dbo].[vyuRKInventoryView]

AS

	SELECT 
		strContractNumber = Spot.strContractNumber
		,intContractSeq = Spot.intContractSeq
		,strCommodity = Spot.strCommodity
		,strItemNo = Spot.strItemNo
		,dblInventoryQty = Spot.dblQty
		,strStockUOM = Spot.strItemUOM
		,strFutureMarket = strFutMarketName
		,strFutureMonth
		,dblBasis = Spot.dblBasis
		,dblFutures = Spot.dblFutures
		,dblCashPrice = Spot.dblCashPrice
		,UM.strUnitMeasure
		,CU.strCurrency
		,CD.intFutureMarketId
		,CD.intFutureMonthId
		,Spot.intCommodityId
		,CD.intContractHeaderId
		,Spot.intContractDetailId
	FROM vyuLGPickOpenInventoryLots Spot
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Spot.intContractDetailId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
	--LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
	LEFT JOIN tblICItemUOM IUM ON   IUM.intItemUOMId =  CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
	INNER JOIN tblRKFutureMarket M ON M.intFutureMarketId = CD.intFutureMarketId
	INNER JOIN tblRKFuturesMonth FM ON FM.intFutureMonthId = CD.intFutureMonthId
	WHERE Spot.dblQty > 0.0
