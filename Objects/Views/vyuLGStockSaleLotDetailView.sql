CREATE VIEW vyuLGStockSaleLotDetailView
AS
SELECT SSH.intStockSalesHeaderId
	,SSH.strStockSalesNumber
	,SSLD.intStockSalesLotDetailId
	,SSLD.intPickLotDetailId
	,PLD.intPickLotHeaderId
	,PLD.intAllocationDetailId
	,ALD.intAllocationHeaderId
	,ALD.intSContractDetailId
	,intFutureMarketId = CD.intFutureMarketId
	,intFutureMonthId = CD.intFutureMonthId
	,strFixationBy = CD.strFixationBy
	,dblCashPrice = CD.dblCashPrice
	,intCurrencyId = CD.intCurrencyId
	,strCurrency = C.strCurrency
	,ysnSubCurrency = C.ysnSubCurrency
	,intSubCurrencyCents = C.intCent
	,intPriceItemUOMId = PUOM.intItemUOMId
	,intPriceUnitMeasureId = PUOM.intUnitMeasureId
	,strPriceUOM = PUOM.strUnitMeasure
	,dblValue = CD.dblTotalCost 
FROM tblLGStockSalesHeader SSH
JOIN tblLGStockSalesLotDetail SSLD ON SSLD.intStockSalesHeaderId = SSH.intStockSalesHeaderId
JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = SSLD.intPickLotDetailId
JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = ALD.intSContractDetailId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
OUTER APPLY (SELECT TOP 1 PU.intItemUOMId, U2.intUnitMeasureId, U2.strUnitMeasure
				FROM tblICItemUOM PU
				LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
				WHERE PU.intItemUOMId = CD.intPriceItemUOMId
			) PUOM