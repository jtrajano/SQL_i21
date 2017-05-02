CREATE VIEW [dbo].[vyuAPRptAPTransactionByGLAccount]
AS
	SELECT
	 APV.intEntityVendorId
	,strMainCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)  
	,APB.intTransactionType AS intTransactionId
	,APV.strVendorId + ' - ' + (SELECT strName FROM tblEMEntity WHERE intEntityId = APV.intEntityVendorId) AS strVendorID
    ,ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName 
	,strCompanyName = ( SELECT strName FROM tblEMEntity WHERE intEntityId = APV.intEntityVendorId)
	,APB.strVendorOrderNumber 
	,APB.strVendorOrderNumber AS strInvoiceNumber
	,APB.intBillId
	,APB.strBillId 
	,strAccountID = (SELECT strAccountId  FROM tblGLAccount WHERE intAccountId = APB.intAccountId)
	,strDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = APB.intAccountId)
	,strAccount = (SELECT strAccountId  FROM tblGLAccount WHERE intAccountId = APB.intAccountId) + ' - ' + (SELECT strDescription FROM tblGLAccount WHERE intAccountId = APB.intAccountId)
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
	,APB.dblTotal
	,(CASE WHEN APB.intTransactionType = 1 THEN 'Voucher'
								WHEN APB.intTransactionType = 2 THEN 'Vendor Prepayment'
								WHEN APB.intTransactionType = 3 THEN 'Debit Memo'
								WHEN APB.intTransactionType = 4 THEN 'Payable'
								WHEN APB.intTransactionType = 5 THEN 'Purchase Order'
								WHEN APB.intTransactionType = 6 THEN 'Bill Template'
								WHEN APB.intTransactionType = 8 THEN 'Overpayment'
								WHEN APB.intTransactionType = 9 THEN '1099 Adjustment'
								WHEN APB.intTransactionType = 10 THEN 'Patronage'
							ELSE ''
						  END) AS strTransactionType
	,'' AS dblAmountPaid
	,'' AS dblCost--tblAPBatchDetail.dblCost
	,'' AS strTaxCode --tblAPBatchDetail.strTaxID AS strSalesTaxCode
	,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = APD.intItemId) AS strItem
	,APD.strMiscDescription
	,APD.intBillDetailId AS  intBillDetailId
	,APD.dblCost AS dblDetailCost
	,APD.dblTotal AS dblDetailTotalCost
	,APD.dblDiscount AS dblDetailDiscount
	,strDetailAccountID = (SELECT strAccountId  FROM tblGLAccount WHERE intAccountId = APD.intAccountId)
	,strDetailDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = APD.intAccountId)
	,strtPrepaidAccountId = (SELECT TOP 1
									(SELECT strDescription FROM tblGLAccount WHERE intAccountId = C.intAccountId) 
							 FROM tblAPAppliedPrepaidAndDebit B
							 INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
							 WHERE B.ysnApplied = 1 AND APB.intBillId = B.intBillId)
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,APB.ysnPaid AS ysnPaid
	--,strSegment = ISNULL((Select strSegmentCode from tblGLAccount where strAccountID = tblAPBatchDetail.strAccountID),'')
	FROM  tblAPBill APB
	INNER JOIN dbo.tblAPBillDetail APD ON APB.intBillId = APD.intBillId
	INNER JOIN tblAPVendor APV
		ON APB.intEntityVendorId = APV.intEntityVendorId
	LEFT JOIN dbo.tblEMEntity E
		ON E.intEntityId = APV.intEntityVendorId
	WHERE 
			APB.ysnForApproval != 1														   --Will not show For Approval Bills
		AND APB.ysnPosted = 1 OR (APB.dtmApprovalDate IS NOT NULL AND APB.ysnApproved = 1) --Will not show Rejected approval bills but show old Posted Transactions.
		AND APB.intTransactionType != 6													   --Will not show BillTemplate 