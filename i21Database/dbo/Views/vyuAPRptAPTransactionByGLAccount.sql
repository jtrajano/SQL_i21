CREATE VIEW [dbo].[vyuAPRptAPTransactionByGLAccount]
AS
	SELECT
	 APV.[intEntityId]
	,strMainCompanyName = compSetup.strCompanyName
	,APB.intTransactionType AS intTransactionId
	,APV.strVendorId + ' - ' + E.strName AS strVendorID
    ,ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName 
	,strCompanyName = E.strName
	,APB.strVendorOrderNumber 
	,APB.strVendorOrderNumber AS strInvoiceNumber
	,APB.intBillId
	,APB.strBillId 
	,strAccountID = accnt.strAccountId
	,strDescription = accnt.strDescription
	,strAccount = accnt.strAccountId + ' - ' + accnt.strDescription
	,strTerms = (SELECT strTerm FROM tblSMTerm WHERE intTermID = APB.intTermsId)
	,APB.strReference
	,APB.strBillId AS strBillBatchNumber
	,APB.dtmBillDate
	,APB.dtmDate
	,Cast(APB.dtmDueDate AS Date )AS dtmDueDate
	,APB.dblAmountDue AS dblAmountDue
	,APB.dblInterest AS dblInterest
	,APB.dblWithheld AS dblWithheld
	,APB.dblDiscount AS dblDiscount
	,APB.dblTotal * ISNULL(APD.dblRate,0) AS dblTotal
	,(CASE WHEN APB.intTransactionType = 1 THEN 'Voucher'
								WHEN APB.intTransactionType = 2 THEN 'Vendor Prepayment'
								WHEN APB.intTransactionType = 3 THEN 'Debit Memo'
								WHEN APB.intTransactionType = 4 THEN 'Payable'
								WHEN APB.intTransactionType = 5 THEN 'Purchase Order'
								WHEN APB.intTransactionType = 6 THEN 'Bill Template'
								WHEN APB.intTransactionType = 8 THEN 'Overpayment'
								WHEN APB.intTransactionType = 9 THEN '1099 Adjustment'
								WHEN APB.intTransactionType = 10 THEN 'Patronage'
								WHEN APB.intTransactionType = 12 THEN 'Prepayment Reversal'
								WHEN APB.intTransactionType = 13 THEN 'Basis Advance'
							ELSE ''
						  END) COLLATE Latin1_General_CI_AS AS strTransactionType
	,'' COLLATE Latin1_General_CI_AS AS dblAmountPaid
	,'' COLLATE Latin1_General_CI_AS AS dblCost--tblAPBatchDetail.dblCost
	,'' COLLATE Latin1_General_CI_AS AS strTaxCode --tblAPBatchDetail.strTaxID AS strSalesTaxCode
	,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = APD.intItemId) AS strItem
	,APD.strMiscDescription
	,APD.intBillDetailId AS  intBillDetailId
	,APD.dblCost AS dblDetailCost
	,APD.dblTotal AS dblDetailTotalCost
	,APD.dblDiscount AS dblDetailDiscount
	,strDetailAccountID = accntDetail.strAccountId
	,strDetailDescription = accntDetail.strDescription
	,strtPrepaidAccountId = (SELECT TOP 1
									prepaidAccnt.strDescription
							 FROM tblAPAppliedPrepaidAndDebit B
							 INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
							 LEFT JOIN tblGLAccount prepaidAccnt ON prepaidAccnt.intAccountId = C.intAccountId
							 WHERE B.ysnApplied = 1 AND APB.intBillId = B.intBillId)
	,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) COLLATE Latin1_General_CI_AS as strCompanyAddress
	,APB.ysnPaid AS ysnPaid
	--,strSegment = ISNULL((Select strSegmentCode from tblGLAccount where strAccountID = tblAPBatchDetail.strAccountID),'')
	,Payment.strPaymentInfo	
	,Payment.dtmDatePaid
	FROM  tblAPBill APB
	INNER JOIN dbo.tblAPBillDetail APD ON APB.intBillId = APD.intBillId
	INNER JOIN tblAPVendor APV
		ON APB.intEntityVendorId = APV.[intEntityId]
	CROSS JOIN tblSMCompanySetup compSetup
	LEFT JOIN tblGLAccount accntDetail ON accntDetail.intAccountId = APD.intAccountId
	LEFT JOIN tblGLAccount accnt ON accnt.intAccountId = APB.intAccountId
	LEFT JOIN dbo.tblEMEntity E
		ON E.intEntityId = APV.[intEntityId]
	OUTER APPLY
	(
		SELECT TOP 1
			B.strPaymentInfo,
			B.dtmDatePaid,
			B.intPaymentId
		FROM dbo.tblAPPayment B 
		LEFT JOIN dbo.tblAPPaymentDetail C 
			ON B.intPaymentId = C.intPaymentId
		WHERE C.intBillId = APB.intBillId
			AND B.ysnPosted = 1
		ORDER BY B.intPaymentId DESC
	) Payment
	WHERE 
			APB.ysnForApproval != 1														   --Will not show For Approval Bills
		AND APB.ysnPosted = 1 OR (APB.dtmApprovalDate IS NOT NULL AND APB.ysnApproved = 1) --Will not show Rejected approval bills but show old Posted Transactions.
		AND APB.intTransactionType != 6													   --Will not show BillTemplate 
