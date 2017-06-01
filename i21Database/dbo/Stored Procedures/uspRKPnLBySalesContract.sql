CREATE PROCEDURE uspRKPnLBySalesContract
		@intUOMId int = null,
		@intPriceUOMId int = null
AS
SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strSequenceNumber)) AS intRow,strSequenceNumber,strItemNo,
strEntityName,dblDetailQuantity,dblAllocatedQty,dblInvoiceQty,isnull(dblAllocatedQty,0)*(isnull(dblSaleBasis,0)-isnull(dblPurchaseBasis,0)-(isnull(dblPurchaseCost,0)- isnull(dblSaleCost,0))) as dblEstimatedProfit,
0.0 as dblActualProfit,  dblPurchaseBasis, dblSaleBasis, dblPurchaseCost, dblSaleCost,
ISNULL(dblAllocatedQty,0)-isnull(dblInvoiceQty,0) as dblBalanceToInvoice,intContractDetailId
 FROM (
SELECT  sa.strSequenceNumber,
		dv.strItemNo,
		dv.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dvp.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(sa.dblAllocatedQty,0) dblAllocatedQty,
		isnull(dblTotal,0) dblInvoiceQty,						
		(SELECT sum(isnull(pc.dblAmount,0)) from vyuCTContractCostEnquiryCost pc where pc.intContractDetailId=ad.intPContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) from vyuCTContractCostEnquiryCost sc where sc.intContractDetailId=ad.intSContractDetailId) dblSaleCost,
		0.0 as dblEstimatedProfit,
		0.0 as dblActualProfit,
		dv.intContractDetailId
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuRKPnLContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
JOIN vyuRKPnLContractDetailView dvp on dvp.intContractDetailId=ad.intPContractDetailId 
LEFT JOIN vyuCTContStsVendorInvoice vi on vi.intContractDetailId=ad.intPContractDetailId
WHERE  sa.strContractType='Sale'
) t