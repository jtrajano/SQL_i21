CREATE VIEW [dbo].[vyuCTContractHeaderNotMapped]
	
AS 
	
SELECT	CH.intContractHeaderId,
		PF.intPriceFixationId, 
		CASE WHEN	(	
						SELECT	COUNT(SA.intSpreadArbitrageId) 
						FROM	tblCTSpreadArbitrage SA  
						WHERE	SA.intPriceFixationId = PF.intPriceFixationId
					) > 0
		THEN	CAST(1 AS BIT) 
		ELSE	CAST(0 AS BIT)
		END		AS ysnSpreadAvailable
		
FROM	tblCTContractHeader CH	LEFT
JOIN	tblCTPriceFixation	PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
WHERE	PF.intContractDetailId	IS	NULL
