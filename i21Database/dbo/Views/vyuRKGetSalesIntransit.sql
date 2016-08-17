CREATE VIEW [dbo].[vyuRKGetSalesIntransit]

AS

SELECT isnull(dblQty,0)-isnull(dblInvoiceQty,0) as dblQty,intContractDetailId from(
SELECT DISTINCT cr.dblQty,ct.intContractDetailId,
	isnull((select isnull(id.dblQtyShipped,0) from tblARInvoice i
	join tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intContractDetailId=pld.intSContractDetailId),0) dblInvoiceQty
FROM tblICInventoryShipment pl
Join tblICInventoryShipmentItem psi on pl.intInventoryShipmentId=psi.intInventoryShipmentId and pl.ysnPosted=1
LEFT JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intSContractDetailId=psi.intLineNo
JOIN tblCTContractDetail ct on ct.intContractHeaderId=pld.intPContractHeaderId and pld.intPContractDetailId=ct.intContractDetailId  and ct.intContractStatusId <> 3 
JOIN tblICStockReservation cr on ct.intItemId=cr.intItemId and cr.intTransactionId=pl.intInventoryShipmentId
)t