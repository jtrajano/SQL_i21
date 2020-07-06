CREATE VIEW vyuAPBill
WITH SCHEMABINDING
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.intSubCurrencyCents,
	CUR.strCurrency,
	CASE A.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2, 13) AND A.ysnPrepayHasPayment = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2, 13) AND A.ysnPrepayHasPayment = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	A.ysnPosted,
	A.ysnPaid,
	A.ysnReadyForPayment,
	ysnRestricted = ISNULL((SELECT TOP 1 ysnRestricted FROM dbo.tblAPBillDetail H WHERE A.intBillId = H.intBillId),0),
	A.dtmDate,
	FP.strPeriod,
	A.dtmDatePaid,
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
	Payment.strBankAccountNo COLLATE Latin1_General_CI_AS AS strBankAccountNo,
	Payment.ysnCleared,
	Payment.dtmDateReconciled,
	Payment.ysnPrinted,
	Payment.ysnVoid,
	Payment.intPaymentId,
	ISNULL(Payment.dblWithheld,0) AS dblWithheld,
	ISNULL(Payment.dblDiscount,0) AS dblDiscount,
	F.strUserName AS strUserId,
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
	'' AS strBatchId,--GL.strBatchId,
	EL.strLocationName AS strVendorLocation,
	strPayeeName = (SELECT EL2.strCheckPayeeName FROM dbo.tblEMEntityLocation EL2 WHERE EL2.intEntityLocationId = A.intPayToAddressId),
	A.strComment,
	ST.strTerm,
	SV.strShipVia,
	EN.strName AS strContactName,
	CL.strLocationName AS strReceivingLocation,
	strStoreLocation = (SELECT SCL.strLocationName FROM dbo.tblSMCompanyLocation SCL WHERE SCL.intCompanyLocationId = A.intStoreLocationId),
	strOrderedBy = (SELECT UEN.strName FROM dbo.tblEMEntity UEN WHERE UEN.intEntityId = A.intOrderById),
	B.strVendorId,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblPayment,
	A.ysnPrepayHasPayment,
	A.intShipToId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId
	INNER JOIN dbo.tblEMEntityLocation EL
		ON EL.intEntityLocationId = A.intShipFromId
	INNER JOIN dbo.tblSMCurrency CUR 
		ON CUR.intCurrencyID = A.intCurrencyId
	INNER JOIN dbo.tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = A.intShipToId
	INNER JOIN dbo.tblSMTerm ST
		ON ST.intTermID = A.intTermsId
	OUTER APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
	LEFT JOIN dbo.tblSMShipVia SV
		ON SV.intEntityId = A.intShipViaId
	LEFT JOIN dbo.tblEMEntity EN
		ON EN.intEntityId = A.intContactId
	LEFT JOIN dbo.tblGLFiscalYearPeriod FP
			ON A.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR A.dtmDate = FP.dtmStartDate OR A.dtmDate = FP.dtmEndDate	
	OUTER APPLY dbo.fnAPGetVoucherLatestPayment(A.intBillId) Payment
	-- LEFT JOIN
	-- (
	-- 	SELECT TOP 1
	-- 		D.intBillId
	-- 		,D.intPaymentId
	-- 		,D.strPaymentInfo
	-- 		,dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(D.strBankAccountNo)) AS strBankAccountNo
	-- 		,D.ysnPrinted
	-- 		,D.ysnVoid
	-- 		,D.ysnCleared
	-- 		,D.dtmDateReconciled
	-- 		,D.dblWithheld
	-- 		,D.dblDiscount
	-- 	FROM dbo.vyuAPBillPayment D
	-- 	-- WHERE A.intBillId = D.intBillId
	-- 	ORDER BY D.intPaymentId DESC --get only the latest payment
	-- ) Payment ON Payment.intBillId = A.intBillId
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	--LEFT JOIN dbo.tblSMApprovalList G ON G.intApprovalListId = ISNULL(B.intApprovalListId , (SELECT intApprovalListId FROM dbo.tblAPCompanyPreference))
	-- OUTER APPLY (
	-- 	SELECT TOP 1
	-- 		I.strApprovalStatus
	-- 		,K.strName
	-- 		,CASE WHEN I.strApprovalStatus = 'Approved' THEN J.dtmDate ELSE NULL END AS dtmApprovalDate
	-- 	FROM dbo.tblSMScreen H
	-- 	INNER JOIN dbo.tblSMTransaction I ON H.intScreenId = I.intScreenId
	-- 	INNER JOIN dbo.tblSMApproval J ON I.intTransactionId = J.intTransactionId
	-- 	LEFT JOIN dbo.tblEMEntity K ON J.intApproverId = K.intEntityId
	-- 	WHERE H.strScreenName = 'Voucher' AND H.strModule = 'Accounts Payable' AND J.ysnCurrent = 1
	-- 	AND A.intBillId = I.intRecordId
	OUTER APPLY [dbo].[fnAPGetVoucherApprovalStatus](A.intBillId) Approvals
	-- OUTER APPLY 
	-- (
	-- 	SELECT TOP 1 strBatchId FROM dbo.tblGLDetail H WHERE A.intBillId = H.intTransactionId AND A.strBillId = H.strTransactionId AND H.ysnIsUnposted = 0
	-- ) GL
