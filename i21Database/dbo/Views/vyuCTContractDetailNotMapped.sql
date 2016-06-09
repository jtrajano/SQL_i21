CREATE VIEW [dbo].[vyuCTContractDetailNotMapped]
	
AS 

SELECT	CD.intContractDetailId,
		PF.intPriceFixationId, 
		CASE WHEN (SELECT COUNT(SA.intSpreadArbitrageId) FROM tblCTSpreadArbitrage SA  WHERE SA.intPriceFixationId = PF.intPriceFixationId) > 0
		THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)END AS ysnSpreadAvailable, 
		CASE WHEN intPFDCount > 0
		THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)END AS ysnFixationDetailAvailable,
		PD.dblQuantityPriceFixed,
		PD.dblPFQuantityUOMId,
		PF.intTotalLots,
		PF.intLotsFixed,
		IC.strContractItemName,
		WM.strUnitMeasure strNetWeightUOM,
		PM.strUnitMeasure strPriceUOM,
		RY.strCountry AS strOrigin,
		CASE	WHEN	CH.ysnCategory = 1
				THEN	dbo.fnCTConvertQtyToTargetCategoryUOM(CD.intCategoryUOMId,GU.intCategoryUOMId,1)
				ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CM.intItemUOMId,1) 
		END		AS		dblConversionFactor,
		ISNULL(QM.strUnitMeasure,YM.strUnitMeasure)	AS	strUOM,
		CY.strCurrency	strMainCurrency,
		CU.ysnSubCurrency,
		CASE	WHEN	CH.ysnLoad = 1
					THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalance,0)
					ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
		END		AS	dblAppliedQty,
		dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)	AS	dblExchangeRate

FROM	tblCTContractDetail			CD	
JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	CD.intContractHeaderId		LEFT
JOIN	tblICItemContract			IC	ON	IC.intItemContractId			=	CD.intItemContractId		LEFT
JOIN	tblSMCountry				RY	ON	RY.intCountryID					=	IC.intCountryId				LEFT
JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID				=	CD.intCurrencyId			LEFT
JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CU.intMainCurrencyId		LEFT

JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=	CD.intItemUOMId				LEFT
JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=	QU.intUnitMeasureId			LEFT

JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId					=	CD.intNetWeightUOMId		LEFT
JOIN	tblICUnitMeasure			WM	ON	WM.intUnitMeasureId				=	WU.intUnitMeasureId			LEFT

JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=	CD.intPriceItemUOMId		LEFT
JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId			LEFT

JOIN	tblICCommodityUnitMeasure	CO	ON	CO.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		LEFT
JOIN	tblICItemUOM				CM	ON	CM.intItemId					=	CD.intItemId				AND
											CM.intUnitMeasureId				=	CO.intUnitMeasureId			LEFT
JOIN	tblICCategoryUOM			YU	ON	YU.intCategoryUOMId				=	CD.intCategoryUOMId			LEFT
JOIN	tblICUnitMeasure			YM	ON	YM.intUnitMeasureId				=	YU.intUnitMeasureId			LEFT
JOIN	tblICCategoryUOM			GU	ON	GU.intCategoryId				=	CD.intCategoryId			AND
											GU.intUnitMeasureId				=	CH.intCategoryUnitMeasureId	LEFT	
JOIN	tblCTPriceFixation			PF	ON	CD.intContractDetailId			=	PF.intContractDetailId		LEFT
JOIN	(
			SELECT	 intPriceFixationId,
					 COUNT(intPriceFixationDetailId) intPFDCount,
					 SUM(dblQuantity) dblQuantityPriceFixed,
					 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
			FROM	 tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
		)							PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
