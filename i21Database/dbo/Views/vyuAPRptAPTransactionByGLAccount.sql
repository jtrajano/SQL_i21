CREATE VIEW [dbo].[vyuAPRptAPTransactionByGLAccount]
AS
	SELECT
	APV.strVendorId + ' - ' + (SELECT strName
									   FROM tblEntity
									   WHERE intEntityId = APV.intEntityVendorId) AS strVendorID
    ,APV.intEntityVendorId
	,strCompanyName = ( SELECT strName
						FROM tblEntity
						WHERE intEntityId = APV.intEntityVendorId)
	,APB.strVendorOrderNumber
	,APB.dtmBillDate
	,strAccountID = (SELECT strAccountId 
					 FROM tblGLAccount 
					 WHERE intAccountId = APB.intAccountId)
	,strDescription = (SELECT strDescription 
					   FROM tblGLAccount 
					   WHERE intAccountId = APB.intAccountId)
	,'' AS dblCost--tblAPBatchDetail.dblCost
	,APB.strReference
	,APB.dblTotal
	,APB.strBillId AS strBillBatchNumber
	,strTerms = (SELECT strTerm 
				 FROM tblSMTerm 
				 WHERE intTermID = APB.intTermsId)
	,Cast(APB.dtmDueDate AS Date )AS dtmDueDate
	,'' AS strTaxCode --tblAPBatchDetail.strTaxID AS strSalesTaxCode
	--,strSegment = ISNULL((Select strSegmentCode from tblGLAccount where strAccountID = tblAPBatchDetail.strAccountID),'')
	FROM  tblAPBill APB
	INNER JOIN tblAPVendor APV
		ON APB.intEntityVendorId = APV.intEntityVendorId
	WHERE 
			APB.ysnForApproval != 1														   --Will not show For Approval Bills
		AND APB.ysnPosted = 1 OR (APB.dtmApprovalDate IS NOT NULL AND APB.ysnApproved = 1) --Will not show Rejected approval bills but show old Posted Transactions.
		AND APB.intTransactionType != 6													   --Will not show BillTemplate
