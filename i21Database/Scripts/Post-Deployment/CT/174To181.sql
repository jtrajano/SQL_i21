PRINT('CT - 174To181 Started')

GO
UPDATE  CH SET CH.intWarehouseId =  CH.intINCOLocationTypeId 
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE   strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

GO
UPDATE  CH SET CH.intINCOLocationTypeId =  NULL
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE	strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

PRINT('CT - 174To181 End')

GO
PRINT('CT - 183')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationDetailAPAR)
BEGIN
	INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
	SELECT intPriceFixationDetailId,intBillId,intBillDetailId,intInvoiceId,intInvoiceDetailId,1 FROM tblCTPriceFixationDetail WHERE (intInvoiceId IS NOT NULL OR intBillId IS NOT NULL) AND intInvoiceId NOT IN (SELECT intInvoiceId FROM tblCTPriceFixationDetailAPAR)
END
PRINT('End CT - 183')
GO

GO
PRINT('Udate existing sequence History')
 
EXEC uspCTUpdateExistingSequenceHistory
 
PRINT('End Udate existing sequence History')
 GO