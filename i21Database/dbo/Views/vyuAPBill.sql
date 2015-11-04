CREATE VIEW vyuAPBill
WITH SCHEMABINDING
AS
SELECT
	A.intBillId,
	A.strBillId,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	A.ysnPosted,
	A.ysnPaid,
	A.ysnReadyForPayment,
	A.dtmDate,
	A.dtmBillDate,
	A.dtmDueDate,
	A.strVendorOrderNumber,
	A.dtmDateCreated,
	A.intTransactionType,
	A.intEntityVendorId,
	B1.strName,
	C.strAccountId,
	Payment.strPaymentInfo,
	Payment.strBankAccountNo,
	Payment.ysnCleared,
	Payment.dtmDateReconciled,
	F.strUserName AS strUserId,
	Payment.ysnPrinted,
	Payment.ysnVoid,
	Payment.intPaymentId,
	strApprovalStatus = CASE WHEN A.ysnForApproval = 1 OR A.dtmApprovalDate IS NOT NULL
							THEN (
								CASE WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 1 THEN 'Approved'
									WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 0 THEN 'Rejected'
									ELSE 'Awaiting approval' END
							)
							ELSE NULL END,
	--strApprover = (SELECT TOP 1 strUserName FROM dbo.tblSMApprovalListUserSecurity F
	--					INNER JOIN dbo.tblSMUserSecurity G ON F.intUserSecurityId = G.intUserSecurityID WHERE B.intApprovalListId = F.intApprovalListId),
	G.strApprovalList AS strApprover,
	dtmApprovalDate
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEntity B1 ON B.[intEntityVendorId] = B1.intEntityId)
	ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId
	OUTER APPLY
	(
		SELECT TOP 1
			D.intBillId
			,D.intPaymentId
			,D.strPaymentInfo
			,D.strBankAccountNo
			,D.ysnPrinted
			,D.ysnVoid
			,D.ysnCleared
			,D.dtmDateReconciled
		FROM dbo.vyuAPBillPayment D
		WHERE A.intBillId = D.intBillId
		ORDER BY D.intPaymentId DESC --get only the latest payment
	) Payment
	LEFT JOIN dbo.tblEntityCredential F ON A.intEntityId = F.intEntityId
	LEFT JOIN dbo.tblSMApprovalList G ON B.intApprovalListId = G.intApprovalListId
