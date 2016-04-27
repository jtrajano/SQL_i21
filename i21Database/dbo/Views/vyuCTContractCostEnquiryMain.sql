CREATE VIEW [dbo].[vyuCTContractCostEnquiryMain]

AS
	SELECT	*,
			ISNULL(dblCashPrice,0) + ISNULL(dblAmountPer,0) - ISNULL(dblNetImpactPer,0) dblAdjEstimated,
			ISNULL(dblCashPrice,0) + ISNULL(dblActualPer,0) - ISNULL(dblNetImpactPer,0) dblAdjActual
	FROM	(
				SELECT	CD.intContractDetailId,
						strContractNumber + ' - ' + LTRIM(intContractSeq) strContractSeq,
						CD.strEntityName,
						CD.dtmContractDate,
						CD.strContractBasis,
						CD.strINCOLocation,
						CD.strCountry ,
						CD.strPosition ,
						CD.dtmStartDate,
						CD.dtmEndDate,
						CD.strPricingType,
						CD.strTerm,
						CD.strGrade,
						CD.strWeight,
						IM.strItemNo,
						RY.strCountry strOrigin,
						CP.strDescription AS strProductType,
						PL.strDescription AS strProductLine,
						CG.strDescription AS strItemGrade,
						CD.strLoadingPointType,
						CD.strLoadingPoint,
						CD.strDestinationPointType,
						CD.strDestinationPoint,
						CD.strDestinationCity,
						CD.strFutMarketName,
						CD.strFutureMonth,
						CD.dblDetailQuantity,
						CD.strItemUOM,
						RI.dblOpenReceive,
						CD.strItemUOM strReceivedUOM,
						CD.dblCashPrice * ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0),1) dblCashPrice,
						CD.strPriceUOM,
						CC.dblAmount,
						CC.dblAmountPer,
						CC.dblActual,
						CC.dblActualPer,
						HE.dblNetImpactInDefCurrency dblNetImpact,
						CASE	WHEN ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intPriceUnitMeasureId,CD.intUnitMeasureId,CD.dblDetailQuantity),0) = 0 
								THEN NULL
								ELSE HE.dblNetImpactInDefCurrency / dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intUnitMeasureId,CD.intPriceUnitMeasureId,CD.dblDetailQuantity)
						END	 	dblNetImpactPer
				FROM	vyuCTContractDetailView		CD
				JOIN	tblICItem					IM	ON	IM.intItemId					=	CD.intItemId		LEFT
				JOIN	tblSMCountry				RY	ON	RY.intCountryID					=	IM.intOriginId		LEFT
				JOIN	tblICCommodityProductLine	PL	ON	PL.intCommodityProductLineId	=	IM.intProductLineId	LEFT
				JOIN	tblICCommodityAttribute		CP	ON	CP.intCommodityAttributeId		=	IM.intProductTypeId	LEFT
				JOIN	tblICCommodityAttribute		CG	ON	CG.intCommodityAttributeId		=	IM.intGradeId		LEFT
				JOIN	(
							SELECT		RI.intLineNo intContractDetailId,
										SUM(dbo.fnCTConvertQtyToTargetItemUOM(PT.intUnitMeasureId,DL.intItemUOMId,PT.dblOpenReceive)) dblOpenReceive
							FROM		vyuICGetInventoryReceiptItem	RI
							JOIN		tblCTContractDetail				DL	ON	DL.intContractDetailId			=	RI.intLineNo
							JOIN		tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId		=	RI.intInventoryReceiptId
							JOIN		tblICInventoryReceiptItem		PT	ON	PT.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
							WHERE		IR.strReceiptType = 'Purchase Contract' AND IR.ysnPosted = 1
							GROUP BY	RI.intLineNo
						)RI	ON RI.intContractDetailId	=	CD.intContractDetailId	LEFT
				JOIN	(
							SELECT		intContractDetailId,
										SUM(dblAmount) dblAmount,SUM(dblAmountPer) dblAmountPer,SUM(dblActual) dblActual,SUM(dblActualPer) dblActualPer 
							FROM		vyuCTContractCostEnquiryCost
							GROUP BY	intContractDetailId
						)CC ON CC.intContractDetailId = CD.intContractDetailId		LEFT
				JOIN	(
							SELECT		intContractDetailId,
										SUM(dblNetImpactInDefCurrency) dblNetImpactInDefCurrency
							FROM		vyuCTContractCostEnquiryHedge
							GROUP BY	intContractDetailId
						)HE ON HE.intContractDetailId = CD.intContractDetailId		
			)t