﻿CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentReceipt]  
AS   
with contracts as
(
select
b.intContractHeaderId, a.intContractDetailId, b.ysnLoad, b.dblQuantityPerLoad
from
tblCTContractDetail a inner join tblCTContractHeader b on b.intContractHeaderId = a.intContractHeaderId
)
SELECT distinct * FROM   
(  
 SELECT a.intTicketId  
 ,a.intContractId  
 ,a.intContractSequence  
 ,a.strTicketNumber  
 ,a.intInventoryShipmentId AS intInventoryShipmentReceiptId  
 ,a.strShipmentNumber AS strShipmentReceiptNumber  
 ,a.dblNetUnits
 ,dblQuantity = a.dblNetUnits
 ,a.strUnitMeasure  
 ,a.strContractNumber  
 ,a.dtmTicketDateTime  
 ,dblScheduleQty = isnull(b.dblScheduleQty,a.dblNetUnits)
 ,dblLoad = (case when isnull(contracts.ysnLoad,0) = 0 then 0.00 else (case when isnull(b.dblScheduleQty,a.dblNetUnits)/contracts.dblQuantityPerLoad < 1 then 1 else convert(int,isnull(b.dblScheduleQty,a.dblNetUnits)/contracts.dblQuantityPerLoad) end) end)
 ,contracts.ysnLoad
 FROM vyuSCTicketInventoryShipmentView a
 inner join tblSCTicket b on b.intTicketId = a.intTicketId
 inner join contracts on contracts.intContractDetailId = b.intContractId
 where b.intContractId = a.intContractId
 
   
 UNION ALL  
   
 SELECT a.intTicketId  
 ,a.intContractId  
 ,a.intContractSequence  
 ,a.strTicketNumber  
 ,a.intInventoryReceiptId AS intInventoryShipmentReceiptId  
 ,a.strReceiptNumber AS strShipmentReceiptNumber  
 ,a.dblNetUnits
 ,dblQuantity = a.dblNetUnits
 ,a.strUnitMeasure  
 ,a.strContractNumber  
 ,a.dtmTicketDateTime  
 ,dblScheduleQty = isnull(b.dblScheduleQty,a.dblNetUnits)
 ,dblLoad = (case when isnull(contracts.ysnLoad,0) = 0 then 0.00 else (case when isnull(b.dblScheduleQty,a.dblNetUnits)/contracts.dblQuantityPerLoad < 1 then 1 else convert(int,isnull(b.dblScheduleQty,a.dblNetUnits)/contracts.dblQuantityPerLoad) end) end)
 ,contracts.ysnLoad
 FROM vyuSCTicketInventoryReceiptView a 
 inner join tblSCTicket b on b.intTicketId = a.intTicketId
 inner join contracts on contracts.intContractDetailId = b.intContractId
 where b.intContractId = a.intContractId
   
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
