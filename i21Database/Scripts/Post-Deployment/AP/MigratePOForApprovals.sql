GO
DECLARE @screenId INT;
SELECT TOP 1 @screenId = intScreenId FROM tblSMScreen WHERE strScreenName = 'Purchase Order' AND strModule = 'Accounts Payable';

IF EXISTS(SELECT 1 FROM tblPOPurchase A WHERE (ysnApproved = 1 OR ysnForApproval = 1 OR dtmApprovalDate IS NOT NULL)
				AND NOT EXISTS(SELECT 1 FROM tblSMTransaction B WHERE A.intPurchaseId = CAST(B.strRecordNo AS INT) AND B.intScreenId = @screenId))
BEGIN

	IF OBJECT_ID(N'tempdb..#tmpPOApproval') IS NOT NULL DROP TABLE #tmpPOApproval
	CREATE TABLE #tmpPOApproval
	(
		intPurchaseId INT NOT NULL
	)

	IF OBJECT_ID(N'tempdb..#tmpPOApprovalSMTransaction') IS NOT NULL DROP TABLE #tmpPOApprovalSMTransaction
	CREATE TABLE #tmpPOApprovalSMTransaction
	(
		intSMTransaction INT NOT NULL,
		intPurchaseId INT NOT NULL,
		dblTotal DECIMAL(18, 6),
		dtmDueDate DATETIME,
		dtmDate DATETIME,
		strPurchaseOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		strApprovalNotes NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		intEntityId	INT
	)

	INSERT INTO #tmpPOApproval
	SELECT intPurchaseId
	FROM tblPOPurchase A 
	WHERE (ysnApproved = 1 OR ysnForApproval = 1 OR dtmApprovalDate IS NOT NULL)
	AND NOT EXISTS(SELECT 1 FROM tblSMTransaction B WHERE A.intPurchaseId = CAST(B.strRecordNo AS INT) AND B.intScreenId = @screenId)

	MERGE INTO tblSMTransaction as destination
	USING (
		SELECT
			[intScreenId]		=	@screenId, 
			[strRecordNo]		=	A.intPurchaseId, 
			[strApprovalStatus]	=	CASE WHEN B.ysnForApprovalSubmitted = 0 AND B.ysnForApproval = 1
											THEN 'For Submit'
										WHEN B.ysnForApprovalSubmitted = 1 AND B.ysnForApproval = 1
											THEN 'Waiting for Approval'
										WHEN B.ysnApproved = 1 AND B.dtmApprovalDate IS NOT NULL
											THEN 'Approved'
										WHEN B.ysnApproved = 0 AND B.dtmApprovalDate IS NOT NULL
											THEN 'Rejected'
									END,
			[intPurchaseId]			=	A.intPurchaseId,
			[intEntityId]		=	B.intEntityId,
			[dblTotal]			=	B.dblTotal,
			[strPurchaseOrderNumber]			=	B.strPurchaseOrderNumber,
			[dtmDueDate]		=	NULL,
			[dtmDate]			=	B.dtmDate,
			[strApprovalNotes]	=	B.strApprovalNotes
		FROM #tmpPOApproval A
		INNER JOIN tblPOPurchase B ON A.intPurchaseId = B.intPurchaseId
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
		SourceData.intPurchaseId,
		SourceData.dblTotal,
		SourceData.dtmDueDate, 
		SourceData.dtmDate,
		SourceData.strPurchaseOrderNumber,
		SourceData.strApprovalNotes,
		SourceData.intEntityId
	INTO #tmpPOApprovalSMTransaction;

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
		[strTransactionNumber]		=	B.strPurchaseOrderNumber,
		[intSubmittedById]			=	B.intEntityId,
		[dblAmount]					=	B.dblTotal,
		[dtmDueDate]				=	B.dtmDueDate,
		[strStatus]					=	A.strApprovalStatus,
		[strComment]				=	B.strApprovalNotes,
		[dtmDate]					=	B.dtmDate,
		[ysnCurrent]				=	CASE WHEN CurrentApprover.intApproverId IS NULL OR C.intApproverId = CurrentApprover.intApproverId THEN 1 ELSE 0 END,
		[ysnEmail]					=	CASE WHEN CurrentApprover.intApproverId IS NULL OR C.intApproverId = CurrentApprover.intApproverId THEN 1 ELSE 0 END
	FROM tblSMTransaction A
	INNER JOIN #tmpPOApprovalSMTransaction B ON A.intTransactionId = B.intSMTransaction
	INNER JOIN tblPOApprover C ON B.intPurchaseId = C.intPurchaseId
	OUTER APPLY (
		SELECT 
			TOP 1 D.intApproverId
		FROM tblPOApprover D
		WHERE D.intPurchaseId = B.intPurchaseId
		AND (D.ysnApproved = 0 AND D.ysnAlternateApproved = 0)
		ORDER BY D.intApproverLevel
	) CurrentApprover
	
END

GO