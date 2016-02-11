CREATE VIEW [dbo].[vyuAPRptAPTransactionByGLAccount]
AS
	SELECT
	 APV.intEntityVendorId
	,intTransactionType AS intTransactionId
	,APV.strVendorId + ' - ' + (SELECT strName FROM tblEntity WHERE intEntityId = APV.intEntityVendorId) AS strVendorID
    ,ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName 
	,strCompanyName = ( SELECT strName FROM tblEntity WHERE intEntityId = APV.intEntityVendorId)
	,APB.strVendorOrderNumber 
	,APB.strVendorOrderNumber AS strInvoiceNumber
	,APB.strBillId 
	,strAccountID = (SELECT strAccountId  FROM tblGLAccount WHERE intAccountId = APB.intAccountId)
	,strDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = APB.intAccountId)
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
	,APB.ysnPaid AS ysnPaid
	--,strSegment = ISNULL((Select strSegmentCode from tblGLAccount where strAccountID = tblAPBatchDetail.strAccountID),'')
	FROM  tblAPBill APB
	INNER JOIN tblAPVendor APV
		ON APB.intEntityVendorId = APV.intEntityVendorId
	LEFT JOIN dbo.tblEntity E
		ON E.intEntityId = APV.intEntityVendorId
	WHERE 
			APB.ysnForApproval != 1														   --Will not show For Approval Bills
		AND APB.ysnPosted = 1 OR (APB.dtmApprovalDate IS NOT NULL AND APB.ysnApproved = 1) --Will not show Rejected approval bills but show old Posted Transactions.
		AND APB.intTransactionType != 6													   --Will not show BillTemplate
