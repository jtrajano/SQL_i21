CREATE VIEW [dbo].[vyuRKGetSalesIntransit]

AS
SELECT DISTINCT cr.dblQty,ct.intContractDetailId  FROM tblICInventoryShipment pl
Join tblICInventoryShipmentItem psi on pl.intInventoryShipmentId=psi.intInventoryShipmentId and pl.ysnPosted=1
JOIN vyuLGDeliveryOpenPickLotDetails pld on pld.intPickLotHeaderId=psi.intLineNo
JOIN tblCTContractDetail ct on ct.intContractHeaderId=pld.intPContractHeaderId and pld.intPContractDetailId=ct.intContractDetailId  and ct.intContractStatusId <> 3 
JOIN tblICStockReservation cr on ct.intItemId=cr.intItemId and cr.intTransactionId=intPickLotDetailId
