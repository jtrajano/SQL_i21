CREATE View vyuRKGetBalanceToReceipt
AS
SELECT isnull(dblOpenReceive,0)-isnull(dblInvoiceQty,0) as dblOpenReceive,intContractDetailId,intInventoryReceiptId,isnull(dblInvoiceQty,0) dblInvoiceQty from(
SELECT DISTINCT ct.dblOpenReceive,ct.intLineNo as intContractDetailId,intInventoryReceiptId,
	isnull((select isnull(id.dblQtyShipped,0) from tblARInvoice i
	join tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intContractDetailId=pld.intSContractDetailId),0) dblInvoiceQty
FROM tblICInventoryShipment pl
Join tblICInventoryShipmentItem psi on pl.intInventoryShipmentId=psi.intInventoryShipmentId and pl.ysnPosted=1
LEFT JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intSContractDetailId=psi.intLineNo
JOIN tblICInventoryReceiptItem ct on pld.intPContractDetailId=ct.intLineNo
)t