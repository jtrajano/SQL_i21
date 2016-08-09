GO
DECLARE @screenId INT;
SELECT TOP 1 @screenId = intScreenId FROM tblSMScreen WHERE strScreenName = 'Voucher' AND strModule = 'Accounts Payable';

IF EXISTS(SELECT 1 FROM tblAPBill A WHERE (ysnApproved = 1 OR ysnForApproval = 1 OR dtmApprovalDate IS NOT NULL)
				AND NOT EXISTS(SELECT 1 FROM tblSMTransaction B WHERE A.intBillId = CAST(B.strRecordNo AS INT) AND B.intScreenId = @screenId))
BEGIN

	IF OBJECT_ID(N'tempdb..#tmpVouchersApproval') IS NOT NULL DROP TABLE #tmpVouchersApproval
	CREATE TABLE #tmpVouchersApproval
	(
		intBillId INT NOT NULL
	)

	IF OBJECT_ID(N'tempdb..#tmpVouchersApprovalSMTransaction') IS NOT NULL DROP TABLE #tmpVouchersApprovalSMTransaction
	CREATE TABLE #tmpVouchersApprovalSMTransaction
	(
		intSMTransaction INT NOT NULL,
		intBillId INT NOT NULL,
		dblTotal DECIMAL(18, 6),
		dtmDueDate DATETIME,
		dtmDate DATETIME,
		strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		strApprovalNotes NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		intEntityId	INT
	)

	INSERT INTO #tmpVouchersApproval
	SELECT intBillId
	FROM tblAPBill A 
	WHERE (ysnApproved = 1 OR ysnForApproval = 1 OR dtmApprovalDate IS NOT NULL)
	AND NOT EXISTS(SELECT 1 FROM tblSMTransaction B WHERE A.intBillId = CAST(B.strRecordNo AS INT) AND B.intScreenId = @screenId)

	MERGE INTO tblSMTransaction as destination
	USING (
		SELECT
			[intScreenId]		=	@screenId, 
			[strRecordNo]		=	A.intBillId, 
			[strApprovalStatus]	=	CASE WHEN B.ysnForApprovalSubmitted = 0 AND B.ysnForApproval = 1
											THEN 'For Submit'
										WHEN B.ysnForApprovalSubmitted = 1 AND B.ysnForApproval = 1
											THEN 'Waiting for Approval'
										WHEN B.ysnApproved = 1 AND B.dtmApprovalDate IS NOT NULL
											THEN 'Approved'
										WHEN B.ysnApproved = 0 AND B.dtmApprovalDate IS NOT NULL
											THEN 'Rejected'
									END,
			[intBillId]			=	A.intBillId,
			[intEntityId]		=	B.intEntityId,
			[dblTotal]			=	B.dblTotal,
			[strBillId]			=	B.strBillId,
			[dtmDueDate]		=	B.dtmDueDate,
			[dtmDate]			=	B.dtmDate,
			[strApprovalNotes]	=	B.strApprovalNotes
		FROM #tmpVouchersApproval A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	) AS SourceData
	ON (1=0)
	WHEN NOT MATCHED THEN
	INSERT (
		[intScreenId], 
		[strRecordNo], 
		[strApprovalStatus]
	)
	VALUES (
		[intScreenId], 
		[strRecordNo], 
		[strApprovalStatus]
	)
	OUTPUT
		inserted.intTransactionId,
		SourceData.intBillId,
		SourceData.dblTotal,
		SourceData.dtmDueDate, 
		SourceData.dtmDate,
		SourceData.strBillId,
		SourceData.strApprovalNotes,
		SourceData.intEntityId
	INTO #tmpVouchersApprovalSMTransaction;

	INSERT INTO tblSMApproval(
		[intTransactionId],
		[intApproverId],
		[intAlternateApproverId],
		[strTransactionNumber],
		[intSubmittedById],
		[dblAmount],
		[dtmDueDate],
		[strStatus],
		[strComment],
		[dtmDate],
		[ysnCurrent],
		[ysnEmail]
	)
	SELECT
		[intTransactionId]			=	A.intTransactionId,
		[intApproverId]				=	C.intApproverId,
		[intAlternateApproverId]	=	C.intAlternateApproverId,
		[strTransactionNumber]		=	B.strBillId,
		[intSubmittedById]			=	B.intEntityId,
		[dblAmount]					=	B.dblTotal,
		[dtmDueDate]				=	B.dtmDueDate,
		[strStatus]					=	A.strApprovalStatus,
		[strComment]				=	B.strApprovalNotes,
		[dtmDate]					=	B.dtmDate,
		[ysnCurrent]				=	CASE WHEN CurrentApprover.intApproverId IS NULL OR C.intApproverId = CurrentApprover.intApproverId THEN 1 ELSE 0 END,
		[ysnEmail]					=	CASE WHEN CurrentApprover.intApproverId IS NULL OR C.intApproverId = CurrentApprover.intApproverId THEN 1 ELSE 0 END
	FROM tblSMTransaction A
	INNER JOIN #tmpVouchersApprovalSMTransaction B ON A.intTransactionId = B.intSMTransaction
	INNER JOIN tblAPVoucherApprover C ON B.intBillId = C.intVoucherId
	OUTER APPLY (
		SELECT 
			TOP 1 D.intApproverId
		FROM tblAPVoucherApprover D
		WHERE D.intVoucherId = B.intBillId
		AND (D.ysnApproved = 0 AND D.ysnAlternateApproved = 0)
		ORDER BY D.intApproverLevel
	) CurrentApprover
	
END

GO