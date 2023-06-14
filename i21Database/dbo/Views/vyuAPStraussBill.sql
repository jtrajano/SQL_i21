CREATE VIEW [dbo].[vyuAPStraussBill]
AS
SELECT
	bb.strBillBatchNumber,
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
		 WHEN 15 THEN 'Tax Adjustment'
		 WHEN 16 THEN 'Provisional Voucher'
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strVoucherType,
	A.intTransactionType,
	A.dtmDate,
	ST.strTerm,
	A.intTermsId,
	A.dtmDueDate,
	C.strAccountId,
	A.intAccountId,
	A.strBillId,
	A.intBillId,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	SV.strShipVia,
	A.intShipViaId,
	EN.strName AS strContactName,
	A.intContactId,
	A.strComment AS strCheckComments,
	B.strVendorId,
	B1.strName,
	A.intEntityVendorId,
	EL.strLocationName AS strVendorLocation,
	A.intShipFromId,
	SL.strLocationName AS strStoreLocation,
	A.intStoreLocationId,
	payee.strCheckPayeeName AS strPayeeName,
	A.intPayToAddressId,
	ysnRestricted = ISNULL((SELECT TOP 1 ysnRestricted FROM dbo.tblAPBillDetail H WHERE A.intBillId = H.intBillId),0),
	UEN.strName AS strOrderedBy,
	A.intOrderById,
	CUR.strCurrency,
	A.intCurrencyId,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2, 13) AND A.ysnPrepayHasPayment = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2, 13) AND A.ysnPrepayHasPayment = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblPayment,
	A.ysnPosted,
	A.ysnPrepayHasPayment,
	A.ysnPaid,
	Payment.dtmDateReconciled,
	A.dtmDatePaid,
	Payment.ysnCleared,
	Payment.strPaymentInfo,
	Payment.strBankAccountNo COLLATE Latin1_General_CI_AS AS strBankAccountNo,
	ISNULL(Payment.dblWithheld,0) AS dblWithheld,
	ISNULL(Payment.dblDiscount,0) AS dblDiscount,
	Approvals.strName as strApprover,
	Approvals.strApprovalStatus,
	Approvals.dtmApprovalDate,
	A.dtmDateCreated,
	F.strUserName AS strUserId,
	A.intEntityId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId
	INNER JOIN dbo.tblEMEntityLocation EL
		ON EL.intEntityLocationId = A.intShipFromId
	INNER JOIN dbo.tblEMEntityLocation payee
		ON payee.intEntityLocationId = A.intPayToAddressId
	INNER JOIN dbo.tblSMCurrency CUR 
		ON CUR.intCurrencyID = A.intCurrencyId
	INNER JOIN dbo.tblSMTerm ST
		ON ST.intTermID = A.intTermsId
	LEFT JOIN tblSMCompanyLocation SL
		ON SL.intCompanyLocationId = A.intStoreLocationId
	LEFT JOIN dbo.tblEMEntity UEN
		ON UEN.intEntityId = A.intOrderById
	OUTER APPLY (
		SELECT TOP 1 commodity.strCommodityCode
		FROM dbo.tblAPBillDetail detail
		LEFT JOIN dbo.tblICItem item ON detail.intItemId = item.intItemId
		LEFT JOIN dbo.tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
		WHERE detail.intBillId = A.intBillId
		ORDER BY detail.intLineNo
	) commodity
	LEFT JOIN dbo.tblSMShipVia SV
		ON SV.intEntityId = A.intShipViaId
	LEFT JOIN dbo.tblEMEntity EN
		ON EN.intEntityId = A.intContactId
	LEFT JOIN tblAPBillBatch bb
		ON A.intBillBatchId = bb.intBillBatchId
	OUTER APPLY dbo.fnAPGetVoucherLatestPayment(A.intBillId) Payment
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	OUTER APPLY [dbo].[fnAPGetVoucherApprovalStatus](A.intBillId) Approvals
