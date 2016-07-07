CREATE VIEW [dbo].[vyuCTContractCostEnquiryMain]

AS
SELECT *,
	ISNULL(dblCashPrice,0) + ISNULL(dblAmountPer,0) - ISNULL(dblNetImpactPer,0) dblAdjEstimated,
	ISNULL(dblCashPrice,0) + ISNULL(dblActualPer,0) - ISNULL(dblNetImpactPer,0) dblAdjActual
FROM (
	SELECT cd.intContractDetailId, cd.strContractNumber + ' - ' + LTRIM(cd.intContractSeq) strContractSeq, cd.strEntityName, cd.dtmContractDate,
		cd.strContractBasis, cd.strINCOLocation, cd.strCountry, cd.strPosition, cd.dtmStartDate, cd.dtmEndDate, cd.strPricingType, cd.strTerm,
		cd.strGrade, cd.strWeight, i.strItemNo, c.strCountry strOrigin, cp.strDescription strProductType, pl.strDescription strProductLine,
		cg.strDescription strItemGrade, cd.strLoadingPointType, cd.strLoadingPoint, cd.strDestinationPointType, cd.strDestinationPoint,
		cd.strDestinationCity, cd.strFutMarketName, cd.strFutureMonth, cd.dblDetailQuantity, cd.strItemUOM, ri.dblOpenReceive, cd.strItemUOM strReceivedUOM,
		cd.dblCashPrice * ISNULL(dbo.fnCTGetCurrencyExchangeRate(cd.intContractDetailId, 0), 1) dblCashPrice,
		cd.strPriceUOM, cc.dblAmount, cc.dblAmountPer, cc.dblActual, cc.dblActualPer, he.dblNetImpactInDefCurrency dblNetImpact,
		CASE WHEN ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, cd.intPriceUnitMeasureId, cd.intUnitMeasureId, cd.dblDetailQuantity), 0) = 0 
			THEN NULL ELSE he.dblNetImpactInDefCurrency / dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, cd.intUnitMeasureId, cd.intPriceUnitMeasureId, cd.dblDetailQuantity)
		END	dblNetImpactPer
	FROM vyuCTContractDetailView cd
		INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
		LEFT OUTER JOIN tblSMCountry c ON c.intCountryID = i.intOriginId
		LEFT OUTER JOIN tblICCommodityProductLine pl ON pl.intCommodityProductLineId = i.intProductLineId
		LEFT OUTER JOIN tblICCommodityAttribute cp ON cp.intCommodityAttributeId = i.intProductTypeId
		LEFT OUTER JOIN tblICCommodityAttribute cg ON cg.intCommodityAttributeId = i.intGradeId
		LEFT OUTER JOIN (
			SELECT ri.intLineNo intContractDetailId, SUM(dbo.fnCTConvertQtyToTargetItemUOM(iri.intUnitMeasureId, cd.intItemUOMId, iri.dblOpenReceive)) dblOpenReceive
			FROM tblICInventoryReceiptItem ri
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
				INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem iri ON iri.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			WHERE r.strReceiptType = 'Purchase Contract' AND r.ysnPosted = 1
			GROUP BY ri.intLineNo
		) ri ON ri.intContractDetailId = cd.intContractDetailId
		LEFT OUTER JOIN (
			SELECT intContractDetailId, SUM(dblAmount) dblAmount, SUM(dblAmountPer) dblAmountPer, SUM(dblActual) dblActual, SUM(dblActualPer) dblActualPer 
			FROM vyuCTContractCostEnquiryCost
			GROUP BY intContractDetailId
		) cc ON cc.intContractDetailId = cd.intContractDetailId
		LEFT OUTER JOIN (
			SELECT intContractDetailId, SUM(dblNetImpactInDefCurrency) dblNetImpactInDefCurrency
			FROM vyuCTContractCostEnquiryHedge
			GROUP BY intContractDetailId
		) he ON he.intContractDetailId = cd.intContractDetailId
	) t