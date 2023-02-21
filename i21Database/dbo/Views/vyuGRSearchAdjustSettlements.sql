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
	,strBillNumbers = ISNULL(CAST(ASTR.intBillId AS NVARCHAR),_strBillIds.strBillIds) 
	,strBillId = CASE 
					WHEN ASTR.intTypeId = 1 THEN 
						ISNULL(AP.strBillId,STUFF(_strVoucherNumbers.strVoucherNumbers,1,1,'')) 
					ELSE ISNULL(AR.strInvoiceNumber,STUFF(_strInvoiceNumbers.strInvoiceNumbers,1,1,''))
				END
	,ysnBillPosted = CASE WHEN ASTR.intTypeId = 1 THEN ISNULL(AP.ysnPosted,SPLIT.ysnPosted) ELSE AR.ysnPosted END
	,ysnBillPaid = CAST(CASE 
						WHEN ASTR.intTypeId = 1 THEN 
							ISNULL(CASE 
								WHEN ASTR.intAdjustmentTypeId = 1 THEN
									CASE WHEN PD.intPaymentId IS NOT NULL THEN 1 ELSE 0 END
								ELSE AP.ysnPaid 
							END,SPLIT.ysnPaymentExists)
						ELSE AR.ysnPaid END
					AS BIT)
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
LEFT JOIN tblAPPaymentDetail PD
	ON PD.intBillId = AP.intBillId
LEFT JOIN (
	SELECT TOP 1 A.intAdjustSettlementId
		,B.ysnPosted
		,ysnPaymentExists = CASE WHEN C.intBillId IS NULL THEN 0 ELSE 1 END
	FROM tblGRAdjustSettlementsSplit A
	INNER JOIN tblAPBill B
		ON B.intBillId = A.intBillId
	LEFT JOIN tblAPPaymentDetail C
		ON C.intBillId = B.intBillId
	WHERE B.ysnPosted = 1 AND C.intBillId IS NOT NULL
) SPLIT ON SPLIT.intAdjustSettlementId = ASTR.intAdjustSettlementId
LEFT JOIN tblARInvoice AR
	ON (AR.intInvoiceId = ASTR.intBillId AND ASTR.intTypeId = 2)
OUTER APPLY (
	SELECT (
		SELECT CONVERT(VARCHAR(40), intBillId) + '|^|'
		FROM tblGRAdjustSettlementsSplit
		WHERE intAdjustSettlementId = ASTR.intAdjustSettlementId
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS as strBillIds
) AS _strBillIds
OUTER APPLY (
	SELECT (
		SELECT ',' + AP.strBillId
		FROM tblGRAdjustSettlementsSplit ADJS
		INNER JOIN tblAPBill AP
			ON AP.intBillId = ADJS.intBillId
		WHERE ADJS.intAdjustSettlementId = ASTR.intAdjustSettlementId
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS as strVoucherNumbers
) AS _strVoucherNumbers
OUTER APPLY (
	SELECT (
		SELECT ',' + AR.strInvoiceNumber
		FROM tblGRAdjustSettlementsSplit ADJS
		INNER JOIN tblARInvoice AR
			ON AR.intInvoiceId = ADJS.intBillId
		WHERE ADJS.intAdjustSettlementId = ASTR.intAdjustSettlementId
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS as strInvoiceNumbers
) AS _strInvoiceNumbers
GO


