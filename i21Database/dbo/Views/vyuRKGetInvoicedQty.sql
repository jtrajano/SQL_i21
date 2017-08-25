CREATE VIEW vyuRKGetInvoicedQty

AS

SELECT dl.dblLotQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ad.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld ON d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoadDetailLot dl ON dl.intLoadDetailId=ld.intLoadDetailId
JOIN tblLGPickLotDetail pd on pd.intPickLotDetailId=ld.intPickLotDetailId
JOIN tblLGAllocationDetail ad on ad.intAllocationDetailId=pd.intAllocationDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=2
WHERE i.ysnPosted=1 

UNION

SELECT ld.dblQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ld.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i on i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld on d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=3
WHERE i.ysnPosted=1 

UNION

SELECT dl.dblLotQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ri.intLineNo intPContractDetailId  
FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld ON d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoadDetailLot dl ON dl.intLoadDetailId=ld.intLoadDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=2
JOIN tblICInventoryReceiptItemLot il on il.intLotId=dl.intLotId
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId
WHERE i.ysnPosted=1

UNION

SELECT sum(il.dblQuantityShipped) dblPurchaseInvoiceQty, sum(il.dblQuantityShipped) dblSalesInvoiceQty,s.intLineNo intSContractDetailId,ri.intLineNo intPContractDetailId  
FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
join tblICInventoryShipmentItem s on s.intInventoryShipmentItemId=d.intInventoryShipmentItemId 
JOIN tblICInventoryShipmentItemLot il on il.intInventoryShipmentItemId=s.intInventoryShipmentItemId
JOIN tblICInventoryReceiptItemLot ril on ril.intLotId=il.intLotId
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptItemId=ril.intInventoryReceiptItemId
WHERE i.ysnPosted=1 group by s.intLineNo,ri.intLineNo 