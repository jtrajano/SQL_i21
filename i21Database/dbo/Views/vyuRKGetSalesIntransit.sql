CREATE VIEW [dbo].[vyuRKGetSalesIntransit]

AS
--SELECT DISTINCT cr.dblQty,ct.intContractDetailId  FROM tblICInventoryShipment pl
--Join tblICInventoryShipmentItem psi on pl.intInventoryShipmentId=psi.intInventoryShipmentId and pl.ysnPosted=1
--LEFT JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intSContractDetailId=psi.intLineNo
--JOIN tblCTContractDetail ct on ct.intContractHeaderId=pld.intPContractHeaderId and pld.intPContractDetailId=ct.intContractDetailId  and ct.intContractStatusId <> 3 
--JOIN tblICStockReservation cr on ct.intItemId=cr.intItemId and cr.intTransactionId=pl.intInventoryShipmentId

--union

SELECT isnull(dblShipmentQty,0)a,isnull(dblInvoiceQty,0) dblQty,
strLocationName,strItemNo,strContractNumber,intContractDetailId from
(SELECT isnull(si.dblQuantity,0) dblShipmentQty,
	isnull((select isnull(id.dblQtyShipped,0) from tblARInvoice i
	join tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intContractDetailId=dv.intContractDetailId),0) dblInvoiceQty
	,dv.strLocationName,dv.strItemNo,	dv.strContractNumber +'-' +Convert(nvarchar,dv.intContractSeq) strContractNumber,dv.intContractDetailId
 from tblICInventoryShipment s
JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and s.ysnPosted=1
JOIN vyuCTContractDetailView dv on dv.intContractHeaderId=si.intOrderId and dv.intContractDetailId=si.intLineNo)t
--JOIN tblICCommodity co on co.intCommodityId=dv.intCommodityId
--JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId )t