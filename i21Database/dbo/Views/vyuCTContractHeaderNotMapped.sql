CREATE VIEW [dbo].[vyuCTContractHeaderNotMapped]
	
AS 

	SELECT	*,
			CAST(CASE WHEN ISNULL(strPrepaidIds,'') = '' THEN 0 ELSE 1 END AS BIT) ysnPrepaid
	FROM	(
				SELECT	CH.intContractHeaderId,
						PF.intPriceFixationId, 
						CASE	WHEN	(	
											SELECT	COUNT(SA.intSpreadArbitrageId) 
											FROM	tblCTSpreadArbitrage SA  
											WHERE	SA.intPriceFixationId = PF.intPriceFixationId
										) > 0
								THEN	CAST(1 AS BIT) 
								ELSE	CAST(0 AS BIT)
						END		AS		ysnSpreadAvailable,

						dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intLoadUOMId,CH.intCommodityUOMId,1)	AS	dblCommodityUOMConversionFactor,
						dbo.fnCTGetPrepaidIds(CH.intContractHeaderId) strPrepaidIds,
						CY.ysnExchangeTraded

				FROM	tblCTContractHeader CH	LEFT
				JOIN	tblICCommodity		CY	ON	CY.intCommodityId	=	CH.intCommodityId		LEFT
				JOIN	tblCTPriceFixation	PF	ON	CH.intContractHeaderId = PF.intContractHeaderId AND CH.ysnMultiplePriceFixation = 1
			)t