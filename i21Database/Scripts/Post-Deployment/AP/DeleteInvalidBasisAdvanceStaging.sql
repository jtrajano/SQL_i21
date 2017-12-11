--THIS WILL DELETE INVALID BASIS ADVANCE STAGING SELECTED
IF EXISTS(SELECT TOP 1 1 
			FROM tblAPBasisAdvanceStaging A
			INNER JOIN vyuAPBasisAdvance B ON A.intTicketId = B.intTicketId AND A.intContractDetailId = B.intContractDetailId
			WHERE B.dblAmountToAdvance <= 0)
BEGIN
	DELETE A 
	FROM tblAPBasisAdvanceStaging A
	INNER JOIN vyuAPBasisAdvance B ON A.intTicketId = B.intTicketId AND A.intContractDetailId = B.intContractDetailId
	WHERE B.dblAmountToAdvance <= 0
END