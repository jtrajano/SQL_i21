CREATE VIEW vyuRKPnLGetAllocationDetail
			
AS

SELECT  dv.strSequenceNumber,dv.intItemId,
		dv.strItemNo,
		dv.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dv.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(ad.dblSAllocatedQty,0) dblAllocatedQty,
		(SELECT	DISTINCT SUM(ID.dblQtyShipped) FROM	tblARInvoiceDetail		ID 
		 WHERE ID.intContractDetailId =ad.intSContractDetailId)	dblInvoiceQty,					
		(SELECT sum(isnull(pc.dblAmount,0)) FROM vyuCTContractCostEnquiryCost pc WHERE pc.intContractDetailId=ad.intPContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) FROM vyuCTContractCostEnquiryCost sc WHERE sc.intContractDetailId=ad.intSContractDetailId) dblSaleCost,
		0.0 as dblActualProfit,
		dv.intContractDetailId,
		ad.intPContractDetailId,
		dv.intContractTypeId,dv.intContractHeaderId intContractHeaderId,dv.dblBasis,dv.intItemUOMId intPItemUOMId,
		dv.intPriceUomId intSItemUOMId
		,dv.intPriceUomId,dv.ysnSubCurrency
		,'With Allocation' strAllocationType
		,dv.strSalespersonName
FROM tblLGAllocationDetail ad 
JOIN vyuRKPnLContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId and dv.intContractTypeId=2
union 
select dvp.strSequenceNumber,dvp.intItemId,
		dvp.strItemNo,
		dvp.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dvp.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(ad.dblSAllocatedQty,0) dblAllocatedQty,
		(SELECT	DISTINCT SUM(ID.dblQtyShipped) FROM	tblARInvoiceDetail		ID 
		 WHERE ID.intContractDetailId =ad.intSContractDetailId)	dblInvoiceQty,					
		(SELECT sum(isnull(pc.dblAmount,0)) FROM vyuCTContractCostEnquiryCost pc WHERE pc.intContractDetailId=ad.intPContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) FROM vyuCTContractCostEnquiryCost sc WHERE sc.intContractDetailId=ad.intSContractDetailId) dblSaleCost,
		0.0 as dblActualProfit,
		dv.intContractDetailId,
		ad.intPContractDetailId,
		dvp.intContractTypeId,dvp.intContractHeaderId intContractHeaderId,dvp.dblBasis,dvp.intItemUOMId intPItemUOMId,
		dvp.intPriceUomId intSItemUOMId
		,dvp.intPriceUomId,dvp.ysnSubCurrency
		,'With Allocation' strAllocationType
		,dvp.strSalespersonName
FROM tblLGAllocationDetail ad 
JOIN vyuRKPnLContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
JOIN vyuRKPnLContractDetailView dvp on dvp.intContractDetailId=ad.intPContractDetailId and dvp.intContractTypeId=1

UNION

SELECT  dv.strSequenceNumber,dv.intItemId,
		dv.strItemNo,
		dv.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dv.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(DL.dblLotQuantity,0) dblAllocatedQty,
		(SELECT	DISTINCT sum(ID.dblQtyShipped) FROM	tblARInvoiceDetail		ID 
			where ID.intContractDetailId =ad.intSContractDetailId)	dblInvoiceQty,					
		(SELECT sum(isnull(pc.dblAmount,0)) from vyuCTContractCostEnquiryCost pc where pc.intContractDetailId=ad.intPContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) from vyuCTContractCostEnquiryCost sc where sc.intContractDetailId=ad.intSContractDetailId) dblSaleCost,
		0.0 as dblActualProfit,
		intSContractDetailId intContractDetailId,
		ad.intPContractDetailId,
		dv.intContractTypeId,dv.intContractHeaderId intContractHeaderId,dv.dblBasis,dv.intItemUOMId intPItemUOMId,
		dv.intPriceUomId intSItemUOMId
		,dv.intPriceUomId,dv.ysnSubCurrency
		,'Without Allocation' strAllocationType
		,dv.strSalespersonName
FROM  tblLGLoadDetail					ad
		JOIN	tblLGLoadDetailLot				DL	ON	ad.intLoadDetailId				=	DL.intLoadDetailId
		JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	DL.intItemUOMId
		JOIN	tblICInventoryReceiptItemLot	IL	ON	IL.intLotId						=	DL.intLotId
		JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId	=	IL.intInventoryReceiptItemId
		JOIN	vyuRKPnLContractDetailView		dv  on dv.intContractDetailId=RI.intLineNo 
		WHERE  intContractTypeId=1

UNION


SELECT  dv.strSequenceNumber,dv.intItemId,
		dv.strItemNo,
		dv.strEntityName,
		isnull(dv.dblDetailQuantity,0) as dblDetailQuantity,
		dv.dblBasis dblPurchaseBasis,
		dv.dblBasis dblSaleBasis,
		isnull(LD.dblQuantity,0) dblAllocatedQty,
		(SELECT	DISTINCT sum(ID.dblQtyShipped) FROM	tblARInvoiceDetail		ID 
			where ID.intContractDetailId =LD.intSContractDetailId)	dblInvoiceQty,					
		(SELECT sum(isnull(pc.dblAmount,0)) from vyuCTContractCostEnquiryCost pc where pc.intContractDetailId=dv.intContractDetailId) dblPurchaseCost,
		(SELECT sum(isnull(sc.dblAmount,0)) from vyuCTContractCostEnquiryCost sc where sc.intContractDetailId=dv.intContractDetailId) dblSaleCost,
		0.0 as dblActualProfit,
		dv.intContractDetailId,
		LD.intSContractDetailId ,
		dv.intContractTypeId,dv.intContractHeaderId intContractHeaderId,dv.dblBasis,dv.intItemUOMId intPItemUOMId,
		dv.intPriceUomId intSItemUOMId
		,dv.intPriceUomId,dv.ysnSubCurrency
		,'Without Allocation' strAllocationType
		,dv.strSalespersonName
FROM  tblLGLoadDetail	AD
		JOIN tblLGLoadDetail LD on AD.intLoadId=LD.intLoadId 
		JOIN vyuRKPnLContractDetailView dv ON dv.intContractDetailId = LD.intSContractDetailId 
		where  intContractTypeId=2
