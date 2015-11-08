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
		RY.strCountry AS strOrigin
		
FROM	tblCTContractDetail CD	LEFT
JOIN	tblICItemContract	IC	ON	IC.intItemContractId	=	CD.intItemContractId	LEFT
JOIN	tblSMCountry		RY	ON	RY.intCountryID			=	IC.intCountryId			LEFT
JOIN	tblICItemUOM		WM	ON	WM.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
JOIN	tblICUnitMeasure	WU	ON	WU.intUnitMeasureId		=	WM.intUnitMeasureId		LEFT		
JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId	=	PF.intContractDetailId	LEFT
JOIN	(
			SELECT	 intPriceFixationId,
					 COUNT(intPriceFixationDetailId) intPFDCount,
					 SUM(dblQuantity) dblQuantityPriceFixed,
					 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
			FROM	 tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
		)					PD	ON	PD.intPriceFixationId	=	PF.intPriceFixationId
