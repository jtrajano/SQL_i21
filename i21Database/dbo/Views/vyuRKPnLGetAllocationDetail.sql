CREATE VIEW vyuRKPnLGetAllocationDetail
			
AS

SELECT  dv.strSequenceNumber,dv.intItemId,
		dv.strItemNo,
		dv.strEntityName,
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
		dv.intContractTypeId,dv.intContractHeaderId intContractHeaderId,dvp.dblBasis,dv.intItemUOMId intPItemUOMId,
		dvp.intPriceUomId intSItemUOMId
		,dv.intPriceUomId,dv.ysnSubCurrency
		,'With Allocation' strAllocationType
		,dv.strSalespersonName
FROM tblLGAllocationDetail ad 
JOIN vyuRKPnLContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
JOIN vyuRKPnLContractDetailView dvp on dvp.intContractDetailId=ad.intPContractDetailId 

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
		dv.intContractDetailId,
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
		JOIN	vyuRKPnLContractDetailView		dv  on dv.intContractDetailId=ad.intSContractDetailId 