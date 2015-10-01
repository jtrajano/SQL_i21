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
		PF.intLotsFixed
		
FROM	tblCTContractDetail CD	LEFT
JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId	=	PF.intContractDetailId	LEFT
JOIN	(
			SELECT	 intPriceFixationId,
					 COUNT(intPriceFixationDetailId) intPFDCount,
					 SUM(dblQuantity) dblQuantityPriceFixed,
					 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
			FROM	 tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
		)					PD	ON	PD.intPriceFixationId	=	PF.intPriceFixationId
