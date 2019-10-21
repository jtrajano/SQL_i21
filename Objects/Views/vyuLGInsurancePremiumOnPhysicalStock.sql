CREATE VIEW vyuLGInsurancePremiumOnPhysicalStock
AS
SELECT intContractHeaderId
	,intContractDetailId
	,strContractNumber
	,intContractSeq
	,strContractNumberSeq
	,strLotNumber
	,intItemId
	,strItemNo
	,strContractDescription
	,strFutMarketName
	,dblDifferential
	,dblMarketDifferential
	,dblMarketDifferentialUOM
	,dblDifferentialInKG
	,dblLatestClosingPrice
	,intUnitMeasureId
	,strWarehouse
	,dblStockQty
	,strStockQtyUOM
	,dblStockNetQtyKg
	,dblAdjustedPriceInKG
	,dblInsuranceRateInKG
	,dtmReceiptDate
	,(
		dblStockNetQtyKg * (
			CASE 
				WHEN dblAdjustedPriceInKG > dblInsuranceRateInKG
					THEN (dblAdjustedPriceInKG + dblInsurancePremiumPerKG)
				ELSE (dblInsuranceRateInKG + dblInsurancePremiumPerKG)
				END
			) * dblProfitMarkup
		) AS dblCurrentStockValue
	,(
		dblStockNetQtyKg * (
			CASE 
				WHEN dblAdjustedPriceInKG > dblInsuranceRateInKG
					THEN (dblAdjustedPriceInKG + dblInsurancePremiumPerKG)
				ELSE (dblInsuranceRateInKG + dblInsurancePremiumPerKG)
				END
			) * dblProfitMarkup
		) * dblInsurancePremiumFactor / 12 AS dblInsurancePremiumPerMonth
FROM (
	SELECT CH.intContractHeaderId
		,CD.intContractDetailId
		,CH.strContractNumber
		,CD.intContractSeq
		,LTRIM(CH.strContractNumber) + '/' + LTRIM(CD.intContractSeq) AS strContractNumberSeq
		,LOT.strLotNumber
		,I.intItemId
		,I.strItemNo
		,ISNULL(I.strDescription, '') + ' ' + ISNULL(CD.strItemSpecification, '') + ' ' + ISNULL(CY.strCropYear, '') strContractDescription
		,FUMAR.strFutMarketName
		,CD.dblBasis AS dblDifferential
		,BP.dblBasisOrDiscount AS dblMarketDifferential
		,BP.strUnitMeasure AS dblMarketDifferentialUOM
		,CASE 
			WHEN CD.dblBasis > BP.dblBasisOrDiscount
				THEN CD.dblBasis
			ELSE BP.dblBasisOrDiscount
			END / dbo.fnCTConvertQtyToTargetItemUOM(BP.intItemUOMId, (
				SELECT TOP 1 intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN ('KG')
				), 1) AS dblDifferentialInKG
		,dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GETDATE()) dblLatestClosingPrice
		,FUMAR.intUnitMeasureId
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
		,(
			CASE 
				WHEN CD.dblBasis > BP.dblBasisOrDiscount
					THEN CD.dblBasis
				ELSE BP.dblBasisOrDiscount
				END / dbo.fnCTConvertQtyToTargetItemUOM(BP.intItemUOMId, (
					SELECT TOP 1 intItemUOMId
					FROM tblICItemUOM IU
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					WHERE IU.intItemId = CD.intItemId
						AND UM.strUnitMeasure IN ('KG')
					), 1)
			) + (
			dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GETDATE()) / dbo.fnCTConvertQtyToTargetItemUOM((
					SELECT TOP 1 intItemUOMId
					FROM tblICUnitMeasure IU
					JOIN tblICItemUOM UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					WHERE IU.intUnitMeasureId = FUMAR.intUnitMeasureId
						AND UM.intItemId = CD.intItemId
					), (
					SELECT TOP 1 intItemUOMId
					FROM tblICItemUOM IU
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					WHERE IU.intItemId = CD.intItemId
						AND UM.strUnitMeasure IN ('KG')
					), 1)
			) AS dblAdjustedPriceInKG
		,ROUND(L.dblInsuranceValue / (
				(
					dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId, (
							SELECT TOP 1 intItemUOMId
							FROM tblICItemUOM IU
							JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
							WHERE IU.intItemId = CD.intItemId
								AND UM.strUnitMeasure IN ('KG')
							), SUM(LD.dblNet))
					)
				), 4) AS dblInsuranceRateInKG
		,IR.dtmReceiptDate
		,IPFD.dblCost
		,IPFD.intCostUOM
		,IPFD.dblCost / dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP 1 intItemUOMId
				FROM tblICUnitMeasure IU
				JOIN tblICItemUOM UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intUnitMeasureId = IPFD.intCostUOM
					AND CD.intItemId = UM.intItemId
				), (
				SELECT TOP 1 intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN ('KG')
				), 1) dblInsurancePremiumPerKG
		,IPFD.dblProfitMarkup
		,IPFD.dblInsurancePremiumFactor
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
	CROSS APPLY dbo.fnRKGetLatestBasisPrice(CD.intItemId, GETDATE()) BP
	LEFT JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblRKFutureMarket FUMAR ON FUMAR.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FUMON ON FUMON.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblLGInsurancePremiumFactor IPF ON IPF.intEntityId = L.intInsurerEntityId
	LEFT JOIN tblLGInsurancePremiumFactorDetail IPFD ON IPFD.intInsurancePremiumFactorId = IPF.intInsurancePremiumFactorId --AND GETDATE()
	GROUP BY CH.intContractHeaderId
		,CD.intContractDetailId
		,CH.strContractNumber
		,CD.intContractSeq
		,LOT.strLotNumber
		,I.strItemNo
		,I.intItemId
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
		,BP.dblBasisOrDiscount
		,BP.strUnitMeasure
		,BP.intItemUOMId
		,CD.intFutureMonthId
		,FUMAR.intUnitMeasureId
		,LD.intWeightItemUOMId
		,LD.dblNet
		,IPFD.dblCost
		,IPFD.intCostUOM
		,IPFD.dblProfitMarkup
		,IPFD.dblInsurancePremiumFactor
	) tbl