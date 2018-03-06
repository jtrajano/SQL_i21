CREATE VIEW vyuLGInsurancePremiumOnPhysicalStock
AS
SELECT CH.intContractHeaderId
	,CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,LTRIM(CH.strContractNumber) + '/' + LTRIM(CD.intContractSeq) AS strContractNumberSeq
	,LOT.strLotNumber
	,'COMPANY NAME' strCompanyName
	,I.strItemNo
	,ISNULL(I.strDescription, '') + ' ' + ISNULL(CD.strItemSpecification, '') + ' ' + ISNULL(CY.strCropYear, '') strContractDescription
	,FUMAR.strFutMarketName
	,CD.dblBasis AS dblDifferential
	,0 AS dblMarketDifferential
	--,dbo.fnRKGetFutureAndBasisPrice(CH.intContractTypeId, CH.intCommodityId, FUMON.strFutureMonth, CD.intPricingTypeId, CD.intFutureMarketId, CD.intCompanyLocationId, NULL, NULL, NULL, NULL) AS dblMarketDifferential
	,'KG' AS dblMarketDifferentialUOM
	,1.00 AS dblDifferentialPerKG
	,CD.dblBasis AS dblAverageClosingPricePerMonth
	,CLSL.strSubLocationName AS strWarehouse
	,LOT.dblQty AS dblStockQty
	,LQUM.strUnitMeasure AS strStockQtyUOM
	,dbo.fnCTConvertQtyToTargetItemUOM(LOT.intWeightUOMId, (
			SELECT TOP 1 intItemUOMId
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE IU.intItemId = CD.intItemId
				AND UM.strUnitMeasure IN ('KG')
			), 1) * LOT.dblWeight dblStockNetQtyKg
	,0.223 AS dblAdjustedPriceInKG
	,L.dblInsuranceValue / (SUM(LD.dblNet)) AS  dblInsuranceRateInKG 
	,IR.dtmReceiptDate
	,L.dblInsuranceValue / (SUM(LD.dblNet)) AS dblCurrentStockValue
	,ROUND((L.dblInsuranceValue / (SUM(LD.dblNet))) / 12, 2) AS dblInsurancePremiumPerMonth
	,'' AS strBlankColumn
FROM tblICLot LOT
JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LOT.intLotId
JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = IRI.intLineNo
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = LOT.intItemId
JOIN tblCTCropYear CY ON CY.intCropYearId = CH.intCropYearId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
JOIN tblICItemUOM LQIU ON LQIU.intItemUOMId = LOT.intItemUOMId
JOIN tblICUnitMeasure LQUM ON LQUM.intUnitMeasureId = LQIU.intUnitMeasureId
JOIN tblICItemUOM LWIU ON LWIU.intItemUOMId = LOT.intWeightUOMId
JOIN tblICUnitMeasure LWUM ON LWUM.intUnitMeasureId = LWIU.intUnitMeasureId
LEFT JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblRKFutureMarket FUMAR ON FUMAR.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FUMON ON FUMON.intFutureMonthId = CD.intFutureMonthId
GROUP BY CH.intContractHeaderId
	,CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,LOT.strLotNumber
	,I.strItemNo
	,I.strDescription
	,CD.strItemSpecification
	,CY.strCropYear
	,FUMAR.strFutMarketName
	,CD.dblBasis
	,CH.intContractTypeId
	,CH.intCommodityId
	,FUMON.strFutureMonth
	,CD.intPricingTypeId
	,CD.intFutureMarketId
	,CD.intCompanyLocationId
	,CLSL.strSubLocationName
	,LOT.dblQty
	,LQUM.strUnitMeasure
	,CD.intItemId
	,LOT.intWeightUOMId
	,LOT.dblWeight
	,L.dblInsuranceValue
	,IR.dtmReceiptDate