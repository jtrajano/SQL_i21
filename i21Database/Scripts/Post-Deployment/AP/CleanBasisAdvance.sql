GO
/**
	THIS WILL CLEAN THE tblAPBasisAdvanceFuture and tblAPBasisAdvanceCommodity
	IF TICKET IS NOT SELECTED (tblAPBasisAdvanceStaging), it should not list (if there are no other same commodity of futures)
*/

PRINT('START CLEAN BASIS ADVANCE')
--tblAPBasisAdvanceFuture
DELETE A
FROM tblAPBasisAdvanceFuture A
OUTER APPLY (
	SELECT
		1 AS ysnSelected
	FROM tblAPBasisAdvanceStaging staging
	INNER JOIN vyuAPBasisAdvance basisAdvance 
		ON staging.intTicketId = basisAdvance.intTicketId 
			AND staging.intContractDetailId = basisAdvance.intContractDetailId
	WHERE basisAdvance.intFutureMarketId = A.intFutureMarketId AND basisAdvance.intFutureMonthId = A.intMonthId
) ticketSelected
WHERE ticketSelected.ysnSelected IS NULL

--tblAPBasisAdvanceCommodity
DELETE A
FROM tblAPBasisAdvanceCommodity A
OUTER APPLY (
	SELECT
		1 AS ysnSelected
	FROM tblAPBasisAdvanceStaging staging
	INNER JOIN vyuAPBasisAdvance basisAdvance 
		ON staging.intTicketId = basisAdvance.intTicketId 
			AND staging.intContractDetailId = basisAdvance.intContractDetailId
	WHERE basisAdvance.intCommodityId = A.intCommodityId
) ticketSelected
WHERE ticketSelected.ysnSelected IS NULL

PRINT('END CLEANING BASIS ADVANCE')