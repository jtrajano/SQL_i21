PRINT '--START: Fix Net Settlement for Settle Storage against Basis Contracts--'
IF (SELECT TOP 1 1 FROM tblGRSettleContractPriceFixationDetail WHERE intPriceFixationDetailId NOT IN (SELECT intPriceFixationDetailId FROM tblCTPriceFixationDetail)) = 1
BEGIN
	UPDATE tblGRSettleContractPriceFixationDetail SET intPriceFixationDetailId = NULL WHERE intPriceFixationDetailId NOT IN (SELECT intPriceFixationDetailId FROM tblCTPriceFixationDetail)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME ='FK_tblGRSettleContractPriceFixationDetail_tblCTPriceFixationDetail_intPriceFixationDetailId')
BEGIN	
	ALTER TABLE tblGRSettleContractPriceFixationDetail
	ADD CONSTRAINT [FK_tblGRSettleContractPriceFixationDetail_tblCTPriceFixationDetail_intPriceFixationDetailId] 
		FOREIGN KEY ([intPriceFixationDetailId]) REFERENCES [dbo].[tblCTPriceFixationDetail] ([intPriceFixationDetailId]) ON DELETE CASCADE
END

IF EXISTS(SELECT TOP 1 1 FROM tblGRSettleContractPriceFixationDetail)
	AND (SELECT TOP 1 1 FROM tblGRSettleContractPriceFixationDetail WHERE intPriceFixationDetailId IS NULL) = 1
BEGIN
	TRUNCATE TABLE tblGRSettleContractPriceFixationDetail

	INSERT INTO tblGRSettleContractPriceFixationDetail
	(
		intSettleStorageId 
		,intSettleContractId
		,intPriceFixationDetailId
		,dblUnits
		,dblCashPrice
		,intContractDetailId
	)
	SELECT SS.intSettleStorageId
		,SC.intSettleContractId
		,PFD2.intPriceFixationDetailId
		,ABD.dblQtyReceived
		,PFD2.dblCashPrice
		,ABD.intContractDetailId
	FROM tblGRSettleStorage SS
	INNER JOIN tblGRSettleStorageBillDetail SBD	
		ON SBD.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblGRSettleContract SC
		ON SC.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractDetailId
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
			AND CH.intPricingTypeId = 2 --BASIS
	INNER JOIN tblAPBill AP
		ON AP.intBillId = SBD.intBillId
	INNER JOIN tblAPBillDetail ABD
		ON ABD.intBillId = SBD.intBillId
			AND ABD.intItemId = SS.intItemId
			AND ABD.intContractDetailId = SC.intContractDetailId
	INNER JOIN tblCTPriceFixationDetailAPAR PFD1
		ON PFD1.intBillDetailId = ABD.intBillDetailId
	INNER JOIN tblCTPriceFixationDetail PFD2
		ON PFD2.intPriceFixationDetailId = PFD1.intPriceFixationDetailId
	ORDER BY intSettleStorageId

	UPDATE SS
	SET SS.dblNetSettlement = B.CALC
	FROM tblGRSettleStorage SS
	INNER JOIN (
	SELECT * FROM (
		SELECT SS.intSettleStorageId
			,SS.strStorageTicket
			,SS.dblNetSettlement
			,CALC = SUM(P.TOTAL - ISNULL(SS.dblDiscountsDue,0))
		FROM tblGRSettleStorage SS
		INNER JOIN tblGRSettleContract SC
			ON SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN (
			SELECT intSettleStorageId
				,intSettleContractId
				,TOTAL = SUM(dblUnits * dblCashPrice)
			FROM tblGRSettleContractPriceFixationDetail	
			GROUP BY intSettleStorageId
				,intSettleContractId
		) P
			ON P.intSettleStorageId = SS.intSettleStorageId
				AND P.intSettleContractId = SC.intSettleContractId
		WHERE ISNULL(SS.dblDiscountsDue ,0) <> 0
		GROUP BY SS.intSettleStorageId
			,SS.strStorageTicket
			,SS.dblNetSettlement
	) A
	WHERE dblNetSettlement <> CALC
	) B ON B.intSettleStorageId = SS.intSettleStorageId
END

PRINT '--END: Fix Net Settlement for Settle Storage against Basis Contracts--'