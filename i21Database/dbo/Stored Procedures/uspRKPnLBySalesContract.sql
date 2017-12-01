CREATE PROCEDURE uspRKPnLBySalesContract
		@intUOMId int = null,
		@intPriceUOMId int = null
AS

DECLARE @ysnPnLWithOutAllocation bit
DECLARE @strAllocationType nvarchar(100)
SELECT TOP 1 @ysnPnLWithOutAllocation =ysnPnLWithOutAllocation from tblRKCompanyPreference 
if isnull(@ysnPnLWithOutAllocation,0)=0
set @strAllocationType='With Allocation'
else
set @strAllocationType = 'Without Allocation'
	
DECLARE @Result TABLE (intContractDetailId int,dblInvoiceQty numeric(24,10))
INSERT INTO @Result(dblInvoiceQty,intContractDetailId)
SELECT	DISTINCT 
			SUM(dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intPriceUOMId, ID.dblQtyShipped)) AS dblInvoiceQty
			,ID.intContractDetailId
	FROM	tblARInvoiceDetail		ID 
	JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	ID.intItemUOMId	
	WHERE ID.intContractDetailId IS NOT NULL
	GROUP BY ID.intContractDetailId

SELECT  CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strSequenceNumber)) AS intRow,strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,sum(dblAllocatedQty) dblAllocatedQty,dblActualProfit
,ISNULL(sum(dblAllocatedQty),0) - isnull(sum(dblInvoiceQty),0) dblBalanceToInvoice,intContractDetailId,sum(dblInvoiceQty) dblInvoiceQty,
0.0 as dblEstimatedProfit 
FROM(
SELECT Distinct strSequenceNumber,strItemNo,
		strEntityName,dblDetailQuantity,--isnull(dblAllocatedQty,0)*(isnull(dblSaleBasis,0)-isnull(dblPurchaseBasis,0)-(isnull(dblPurchaseCost,0)- isnull(dblSaleCost,0))) as dblEstimatedProfit,
		0.0 as dblActualProfit, 
		sum(dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intUnitMeasureId,@intPriceUOMId, ISNULL(dblAllocatedQty,0))) over (Partition by intContractDetailId)  dblAllocatedQty,
		dblInvoiceQty  as dblInvoiceQty,		
		intContractDetailId
FROM(
	SELECT strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,dblPurchaseBasis,dblSaleBasis,dblAllocatedQty,						
		   dblPurchaseCost,dblSaleCost,0.0 as dblActualProfit,d.intContractDetailId,intPContractDetailId, d.intItemId,u.intUnitMeasureId,
		   r.dblInvoiceQty dblInvoiceQty
	FROM vyuRKPnLGetAllocationDetail d 
	JOIN tblICItemUOM u on u.intItemUOMId=d.intPItemUOMId
	LEFT JOIN @Result r on d.intContractDetailId=r.intContractDetailId
	WHERE strAllocationType=@strAllocationType
) t
 )t1 GROUP BY strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,intContractDetailId,dblActualProfit