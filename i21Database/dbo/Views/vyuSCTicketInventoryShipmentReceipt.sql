CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentReceipt]
AS 
SELECT * FROM 
(
	SELECT intTicketId
	,intContractId
	,intContractSequence
	,strTicketNumber
	,intInventoryShipmentId AS intInventoryShipmentReceiptId
	,strShipmentNumber AS strShipmentReceiptNumber
	,dblNetUnits
	,strUnitMeasure
	,strContractNumber
	,dtmTicketDateTime
	FROM vyuSCTicketInventoryShipmentView
	
	UNION ALL
	
	SELECT intTicketId
	,intContractId
	,intContractSequence
	,strTicketNumber
	,intInventoryReceiptId AS intInventoryShipmentReceiptId
	,strReceiptNumber AS strShipmentReceiptNumber
	,dblNetUnits
	,strUnitMeasure
	,strContractNumber
	,dtmTicketDateTime
	FROM vyuSCTicketInventoryReceiptView

) tbl
