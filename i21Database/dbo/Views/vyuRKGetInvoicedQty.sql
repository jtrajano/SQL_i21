CREATE VIEW vyuRKGetInvoicedQty

AS

SELECT dl.dblLotQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ad.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i ON i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld ON d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
JOIN tblLGLoadDetailLot dl ON dl.intLoadDetailId=ld.intLoadDetailId
join tblLGPickLotDetail pd on pd.intPickLotDetailId=ld.intPickLotDetailId
join tblLGAllocationDetail ad on ad.intAllocationDetailId=pd.intAllocationDetailId
join tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=2
WHERE i.ysnPosted=1 

UNION

SELECT ld.dblQuantity dblPurchaseInvoiceQty, ld.dblQuantity dblSalesInvoiceQty,ld.intSContractDetailId,ld.intPContractDetailId  FROM tblARInvoiceDetail d
JOIN tblARInvoice i on i.intInvoiceId=d.intInvoiceId
JOIN tblLGLoadDetail ld on d.intLoadDetailId=ld.intLoadDetailId and ld.intSContractDetailId=d.intContractDetailId
join tblLGLoad l on l.intLoadId=ld.intLoadId and l.intPurchaseSale=3
WHERE i.ysnPosted=1 