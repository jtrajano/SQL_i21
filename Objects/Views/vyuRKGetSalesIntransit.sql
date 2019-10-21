CREATE VIEW [dbo].[vyuRKGetSalesIntransit]

AS

SELECT isnull(dblQty,0)-isnull(dblInvoiceQty,0) as dblQty,isnull(dblInvoiceQty,0) as dblInvoiceQty,intContractDetailId from(
SELECT SUM(dblQty) dblQty, intContractDetailId,
	isnull((SELECT distinct (isnull(id.dblQtyShipped,0)) dblQtyShipped from tblARInvoice i
							JOIN tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 
							JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intSContractDetailId=id.intContractDetailId
							where pld.intPContractDetailId=t.intContractDetailId ),0) dblInvoiceQty
 FROM(
SELECT DISTINCT (cr.dblQty) dblQty,ct.intContractDetailId,cr.intLotId
FROM tblICInventoryShipment pl
Join tblICInventoryShipmentItem psi on pl.intInventoryShipmentId=psi.intInventoryShipmentId and pl.ysnPosted=1
LEFT JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intSContractDetailId=psi.intLineNo
JOIN tblCTContractDetail ct on ct.intContractHeaderId=pld.intPContractHeaderId and pld.intPContractDetailId=ct.intContractDetailId  and ct.intContractStatusId <> 3 
JOIN tblICStockReservation cr on ct.intItemId=cr.intItemId and cr.intTransactionId=pl.intInventoryShipmentId 
)t group by intContractDetailId )t1