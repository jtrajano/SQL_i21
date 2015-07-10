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
			APB.ysnPosted = 1 
		AND	APB.ysnForApproval != 1									   --Will not show For Approval Bills
		AND (APB.ysnApproved != 0 AND APB.dtmApprovalDate IS NOT NULL) --Will not show Rejected approval bills
		AND APB.intTransactionType != 6                                --Will not show BillTemplate
