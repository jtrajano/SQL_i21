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
		WU.strUnitMeasure strNetWeightUOM,
		RY.strCountry AS strOrigin,
		CASE	WHEN	CH.ysnCategory = 1
				THEN	dbo.fnCTConvertQtyToTargetCategoryUOM(CD.intCategoryUOMId,GU.intCategoryUOMId,1)
				ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CM.intItemUOMId,1) 
		END		AS		dblConversionFactor,
		ISNULL(QM.strUnitMeasure,YM.strUnitMeasure)	AS	strUOM

FROM	tblCTContractDetail			CD	
JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	CD.intContractHeaderId		LEFT
JOIN	tblICItemContract			IC	ON	IC.intItemContractId			=	CD.intItemContractId		LEFT
JOIN	tblSMCountry				RY	ON	RY.intCountryID					=	IC.intCountryId				LEFT
JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=	CD.intItemUOMId				LEFT
JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=	QU.intUnitMeasureId			LEFT
JOIN	tblICItemUOM				WM	ON	WM.intItemUOMId					=	CD.intNetWeightUOMId		LEFT
JOIN	tblICUnitMeasure			WU	ON	WU.intUnitMeasureId				=	WM.intUnitMeasureId			LEFT
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
