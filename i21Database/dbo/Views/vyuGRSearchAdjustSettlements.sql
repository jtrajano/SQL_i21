CREATE VIEW [dbo].[vyuGRSearchAdjustSettlements]
AS 
SELECT 
	ASTR.intAdjustSettlementId	
	,ASTR.intTypeId
	,strType = CASE WHEN ASTR.intTypeId = 1 THEN 'Purchase' ELSE 'Sales' END COLLATE Latin1_General_CI_AS
	,ASTR.strAdjustSettlementNumber
	,ASTR.intEntityId
	,strEntityName = EM.strName
	,ASTR.intCompanyLocationId
	,strAdjLocationName = CL.strLocationName
	,ASTR.intItemId
	,IC.strItemNo
	,ASTR.intTicketId
	,ASTR.strTicketNumber
	,ysnManualTicket = CAST(CASE WHEN ASTR.intTicketId IS NULL THEN 1 ELSE 0 END AS BIT)
	,ASTR.intAdjustmentTypeId
	,AST.strAdjustmentType
	,ASTR.intSplitId
	,ES.strSplitNumber
	,ASTR.dtmAdjustmentDate
	,ASTR.dblAdjustmentAmount
	,dblWithholdAmount = ISNULL(ASTR.dblWithholdAmount,0)
	,dblCkoffAdjustment = ISNULL(ASTR.dblCkoffAdjustment,0)
	,dblTotalAdjustment = ISNULL(ASTR.dblTotalAdjustment,0)
	,ASTR.strRailReferenceNumber
	,ASTR.strCustomerReference
	,ASTR.strComments
	,ASTR.intGLAccountId
	,AD.strAccountId
	,ASTR.ysnTransferSettlement
	,ASTR.intTransferEntityId
	,EM_TRANSFER.strName
	,ASTR.strTransferComments
	,ASTR.ysnPosted
	,dblFreightUnits = ISNULL(ASTR.dblFreightUnits,0)
	,dblFreightRate = ISNULL(ASTR.dblFreightRate,0)
	,dblFreightSettlement = ISNULL(ASTR.dblFreightSettlement,0)
	,ASTR.intContractLocationId
	,strContractLocationName = CL_CD.strLocationName
	,ASTR.intContractDetailId
	,ASTR.intContractHeaderId
	,CH.strContractNumber
	,ASTR.dtmDateCreated
	,ASTR.intConcurrencyId
	,ASTR.intCreatedUserId
	,ASTR.intParentAdjustSettlementId
	,intBillId = CASE WHEN ASTR.intTypeId = 1 THEN AP.intBillId ELSE AR.intInvoiceId END
	,strBillId = CASE WHEN ASTR.intTypeId = 1 THEN AP.strBillId ELSE AR.strInvoiceNumber END
	,ysnBillPosted = CASE WHEN ASTR.intTypeId = 1 THEN AP.ysnPosted ELSE AR.ysnPosted END
	,ysnBillPaid = CASE WHEN ASTR.intTypeId = 1 THEN AP.ysnPaid ELSE AR.ysnPaid END
FROM tblGRAdjustSettlements ASTR
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = ASTR.intEntityId
INNER JOIN tblSMCompanyLocation CL	
	ON CL.intCompanyLocationId = ASTR.intCompanyLocationId
INNER JOIN tblICItem IC
	ON IC.intItemId = ASTR.intItemId
LEFT JOIN tblEMEntitySplit ES
	ON ES.intSplitId = ASTR.intSplitId
INNER JOIN tblGLAccount AD
	ON AD.intAccountId = ASTR.intGLAccountId
LEFT JOIN tblEMEntity EM_TRANSFER
	ON EM_TRANSFER.intEntityId = ASTR.intTransferEntityId
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblSMCompanyLocation CL_CD
		ON CL_CD.intCompanyLocationId = CD.intCompanyLocationId
	) ON CD.intContractDetailId = ASTR.intContractDetailId
INNER JOIN tblGRAdjustmentType AST
	ON AST.intAdjustmentTypeId = ASTR.intAdjustmentTypeId
LEFT JOIN tblAPBill AP
	ON (AP.intBillId = ASTR.intBillId AND ASTR.intTypeId = 1)
LEFT JOIN tblARInvoice AR
	ON (AR.intInvoiceId = ASTR.intBillId AND ASTR.intTypeId = 2)
GO