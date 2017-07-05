CREATE PROCEDURE uspRKPnLBySalesContract
		@intUOMId int = null,
		@intPriceUOMId int = null
AS

SELECT  CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strSequenceNumber)) AS intRow,strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,sum(dblAllocatedQty) dblAllocatedQty,dblEstimatedProfit,dblActualProfit
,ISNULL(sum(dblAllocatedQty),0) - isnull(sum(dblInvoiceQty),0) dblBalanceToInvoice,intContractDetailId,
0.0 as dblInvoiceQty
FROM(
SELECT strSequenceNumber,strItemNo,
		strEntityName,dblDetailQuantity,isnull(dblAllocatedQty,0)*(isnull(dblSaleBasis,0)-isnull(dblPurchaseBasis,0)-(isnull(dblPurchaseCost,0)- isnull(dblSaleCost,0))) as dblEstimatedProfit,
		0.0 as dblActualProfit, 
		ISNULL(dblAllocatedQty,0) dblAllocatedQty,isnull(dblInvoiceQty,0) as dblInvoiceQty,intContractDetailId
FROM(
	SELECT strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,dblPurchaseBasis,dblSaleBasis,dblAllocatedQty,dblInvoiceQty,						
		   dblPurchaseCost,dblSaleCost,0.0 as dblActualProfit,intContractDetailId,intPContractDetailId 
	FROM vyuRKPnLGetAllocationDetail
) t )t1 GROUP BY strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,dblEstimatedProfit,intContractDetailId,dblActualProfit
