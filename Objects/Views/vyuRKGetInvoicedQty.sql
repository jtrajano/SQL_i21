CREATE VIEW vyuRKGetInvoicedQty

AS

SELECT ld.intLoadDetailId, dl.dblLotQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ad.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld ON d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoadDetailLot dl ON dl.intLoadDetailId=ld.intLoadDetailId
JOIN tblLGPickLotDetail pd on pd.intPickLotDetailId=ld.intPickLotDetailId
JOIN tblLGAllocationDetail ad on ad.intAllocationDetailId=pd.intAllocationDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=2
WHERE i.ysnPosted=1

UNION

SELECT ld.intLoadDetailId, ld.dblQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ld.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i on i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld on d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=3
WHERE i.ysnPosted=1

UNION

SELECT ld.intLoadDetailId, dl.dblLotQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ri.intLineNo intPContractDetailId  
FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld ON d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoadDetailLot dl ON dl.intLoadDetailId=ld.intLoadDetailId
JOIN tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=2
JOIN tblICInventoryReceiptItemLot il on il.intLotId=dl.intLotId
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId
WHERE i.ysnPosted=1