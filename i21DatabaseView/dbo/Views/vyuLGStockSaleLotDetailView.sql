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
	,CD.intFutureMarketId AS intFutureMarketId
	,CD.intFutureMonthId AS intFutureMonthId
	,CD.strFixationBy AS strFixationBy
	,CD.dblCashPrice AS dblCashPrice
	,CD.intCurrencyId AS intCurrencyId
	,C.strCurrency AS strCurrency
	,(
		SELECT TOP 1 U2.intUnitMeasureId
		FROM tblICItemUOM PU
		LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
		WHERE PU.intItemUOMId = CD.intPriceItemUOMId
		) AS intPriceUnitMeasureId
	,(
		SELECT TOP 1 U2.strUnitMeasure
		FROM tblICItemUOM PU
		LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
		WHERE PU.intItemUOMId = CD.intPriceItemUOMId
		) AS strPriceUOM
FROM tblLGStockSalesHeader SSH
JOIN tblLGStockSalesLotDetail SSLD ON SSLD.intStockSalesHeaderId = SSH.intStockSalesHeaderId
JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = SSLD.intPickLotDetailId
JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = ALD.intSContractDetailId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId