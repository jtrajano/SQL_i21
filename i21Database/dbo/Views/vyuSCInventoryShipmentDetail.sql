CREATE VIEW [dbo].[vyuSCInventoryShipmentDetail]
AS 
SELECT 
	C.intTicketId
	,D.intContractDetailId
	,D.strContractNumber
	,B.intInventoryShipmentItemId
	,A.strShipmentNumber
	,E.strName
	,D.strPricingType
	,dblAvailableQty = ISNULL(D.dblAvailableQtyInItemStockUOM,0.0)
	,B.dblQuantity
FROM tblICInventoryShipmentItem B
INNER JOIN tblICInventoryShipment A
	ON A.intInventoryShipmentId = B.intInventoryShipmentId
INNER JOIN tblSCTicket C
	ON B.intSourceId = C.intTicketId
LEFT JOIN vyuCTContractDetailView D
	ON B.intLineNo = D.intContractDetailId
LEFT JOIN tblEMEntity E
	ON D.intEntityId = E.intEntityId
WHERE A.intSourceType = 1
