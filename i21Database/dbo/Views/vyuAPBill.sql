﻿CREATE VIEW vyuAPBill
WITH SCHEMABINDING
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.intSubCurrencyCents,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (33,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
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
	Payment.strBankAccountNo,
	Payment.ysnCleared,
	Payment.dtmDateReconciled,
	F.strUserName AS strUserId,
	Payment.ysnPrinted,
	Payment.ysnVoid,
	Payment.intPaymentId,
	strApprovalStatus = CASE WHEN (A.ysnForApproval = 1 OR A.dtmApprovalDate IS NOT NULL) AND A.ysnForApprovalSubmitted = 1
							THEN (
								CASE WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 1 THEN 'Approved'
									WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 0 THEN 'Rejected'
									ELSE 'Awaiting approval' END
							)
							WHEN A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
								THEN 'Ready for submit'
							ELSE NULL END,
	--strApprover = (SELECT TOP 1 strUserName FROM dbo.tblSMApprovalListUserSecurity F
	--					INNER JOIN dbo.tblSMUserSecurity G ON F.intUserSecurityId = G.intUserSecurityID WHERE B.intApprovalListId = F.intApprovalListId),
	CASE WHEN A.ysnForApproval = 1 THEN G.strApprovalList ELSE NULL END AS strApprover,
	dtmApprovalDate,
	GL.strBatchId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityVendorId] = B1.intEntityId)
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
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	LEFT JOIN dbo.tblSMApprovalList G ON G.intApprovalListId = ISNULL(B.intApprovalListId , (SELECT intApprovalListId FROM dbo.tblAPCompanyPreference))
	OUTER APPLY 
	(
		SELECT TOP 1 strBatchId FROM dbo.tblGLDetail H WHERE A.intBillId = H.intTransactionId AND A.strBillId = H.strTransactionId AND H.ysnIsUnposted = 0
	) GL