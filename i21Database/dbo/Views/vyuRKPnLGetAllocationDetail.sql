CREATE VIEW vyuRKPnLGetAllocationDetail
			
AS

SELECT  dv.strSequenceNumber,
		dv.strItemNo,
		dv.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dvp.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(ad.dblSAllocatedQty,0) dblAllocatedQty,
		isnull(dblTotal,0) dblInvoiceQty,						
		(SELECT sum(isnull(pc.dblAmount,0)) from vyuCTContractCostEnquiryCost pc where pc.intContractDetailId=ad.intPContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) from vyuCTContractCostEnquiryCost sc where sc.intContractDetailId=ad.intSContractDetailId) dblSaleCost,
		0.0 as dblActualProfit,
		dv.intContractDetailId,
		ad.intPContractDetailId,
		dv.intContractTypeId,dv.intContractHeaderId intContractHeaderId,dvp.dblBasis
FROM  tblLGAllocationDetail ad 
JOIN vyuRKPnLContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
JOIN vyuRKPnLContractDetailView dvp on dvp.intContractDetailId=ad.intPContractDetailId 
LEFT JOIN vyuCTContStsVendorInvoice vi on vi.intContractDetailId=ad.intPContractDetailId
