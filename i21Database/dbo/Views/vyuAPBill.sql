CREATE VIEW vyuAPBill
WITH SCHEMABINDING
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.intSubCurrencyCents,
	CUR.strCurrency,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	A.ysnPosted,
	A.ysnPaid,
	A.ysnReadyForPayment,
	ysnRestricted = ISNULL((SELECT TOP 1 ysnRestricted FROM dbo.tblAPBillDetail H WHERE A.intBillId = H.intBillId),0),
	A.dtmDate,
	A.dtmBillDate,
	A.dtmDueDate,
	A.strVendorOrderNumber,
	A.strReference,
	A.dtmDateCreated,
	A.intTransactionType,
	A.intEntityVendorId,
	B1.strName,
	C.strAccountId,
	Payment.strPaymentInfo,
	dbo.fnAESDecryptASym(Payment.strBankAccountNo) AS strBankAccountNo,
	Payment.ysnCleared,
	Payment.dtmDateReconciled,
	F.strUserName AS strUserId,
	Payment.ysnPrinted,
	Payment.ysnVoid,
	Payment.intPaymentId,
	--strApprovalStatus = CASE WHEN (A.ysnForApproval = 1 OR A.dtmApprovalDate IS NOT NULL) AND A.ysnForApprovalSubmitted = 1
	--						THEN (
	--							CASE WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 1 THEN 'Approved'
	--								WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 0 THEN 'Rejected'
	--								ELSE 'Awaiting approval' END
	--						)
	--						WHEN A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
	--							THEN 'Ready for submit'
	--						ELSE NULL END,
	Approvals.strApprovalStatus,
	--strApprover = (SELECT TOP 1 strUserName FROM dbo.tblSMApprovalListUserSecurity F
	--					INNER JOIN dbo.tblSMUserSecurity G ON F.intUserSecurityId = G.intUserSecurityID WHERE B.intApprovalListId = F.intApprovalListId),
	--CASE WHEN A.ysnForApproval = 1 THEN G.strApprovalList ELSE NULL END AS strApprover,
	Approvals.strName as strApprover,
	Approvals.dtmApprovalDate,
	GL.strBatchId,
	EL.strLocationName AS strVendorLocation,
	ISNULL(Payment.dblWithheld,0) AS dblWithheld,
	ISNULL(Payment.dblDiscount,0) AS dblDiscount
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityVendorId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId
	INNER JOIN dbo.tblEMEntityLocation EL
		ON EL.intEntityLocationId = A.intShipFromId
	INNER JOIN dbo.tblSMCurrency CUR 
		ON CUR.intCurrencyID = A.intCurrencyId
	OUTER APPLY
	(
		SELECT TOP 1
			D.intBillId
			,D.intPaymentId
			,D.strPaymentInfo
			,CONVERT(NVARCHAR(MAX),DecryptByKey(CAST(N'' as XML).value('xs:base64Binary(sql:column(''strBankAccountNo''))', 'varbinary(128)')))	 AS strBankAccountNo
			,D.ysnPrinted
			,D.ysnVoid
			,D.ysnCleared
			,D.dtmDateReconciled
			,D.dblWithheld
			,D.dblDiscount
		FROM dbo.vyuAPBillPayment D
		WHERE A.intBillId = D.intBillId
		ORDER BY D.intPaymentId DESC --get only the latest payment
	) Payment
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	--LEFT JOIN dbo.tblSMApprovalList G ON G.intApprovalListId = ISNULL(B.intApprovalListId , (SELECT intApprovalListId FROM dbo.tblAPCompanyPreference))
	OUTER APPLY (
		SELECT TOP 1
			I.strApprovalStatus
			,K.strName
			,CASE WHEN I.strApprovalStatus = 'Approved' THEN J.dtmDate ELSE NULL END AS dtmApprovalDate
		FROM dbo.tblSMScreen H
		INNER JOIN dbo.tblSMTransaction I ON H.intScreenId = I.intScreenId
		INNER JOIN dbo.tblSMApproval J ON I.intTransactionId = J.intTransactionId
		INNER JOIN dbo.tblEMEntity K ON J.intApproverId = K.intEntityId
		WHERE H.strScreenName = 'Voucher' AND H.strModule = 'Accounts Payable' AND J.ysnCurrent = 1
		AND A.intBillId = I.intRecordId
	) Approvals
	OUTER APPLY 
	(
		SELECT TOP 1 strBatchId FROM dbo.tblGLDetail H WHERE A.intBillId = H.intTransactionId AND A.strBillId = H.strTransactionId AND H.ysnIsUnposted = 0
	) GL