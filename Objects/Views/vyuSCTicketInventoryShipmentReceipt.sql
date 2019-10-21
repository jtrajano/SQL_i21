CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentReceipt]  
AS   
SELECT distinct * FROM   
(  
 SELECT a.intTicketId  
 ,a.intContractId  
 ,a.intContractSequence  
 ,a.strTicketNumber  
 ,a.intInventoryShipmentId AS intInventoryShipmentReceiptId  
 ,a.strShipmentNumber AS strShipmentReceiptNumber  
 ,a.dblNetUnits
 ,a.strUnitMeasure  
 ,a.strContractNumber  
 ,a.dtmTicketDateTime  
 ,b.dblScheduleQty
 FROM vyuSCTicketInventoryShipmentView a, tblSCTicket b
 where b.intTicketId = a.intTicketId
 and b.intContractId = a.intContractId
   
 UNION ALL  
   
 SELECT a.intTicketId  
 ,a.intContractId  
 ,a.intContractSequence  
 ,a.strTicketNumber  
 ,a.intInventoryReceiptId AS intInventoryShipmentReceiptId  
 ,a.strReceiptNumber AS strShipmentReceiptNumber  
 ,a.dblNetUnits
 ,a.strUnitMeasure  
 ,a.strContractNumber  
 ,a.dtmTicketDateTime  
 ,b.dblScheduleQty
 FROM vyuSCTicketInventoryReceiptView a, tblSCTicket b
 where b.intTicketId = a.intTicketId
 and b.intContractId = a.intContractId
  
) tbl

/*
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
*/
