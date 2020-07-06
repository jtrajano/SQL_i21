CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentView]  
AS 
SELECT   
SC.intTicketId,  
SC.strLoadNumber,  
SC.intEntityId,  
SC.strTicketNumber,  
ICSI.intInventoryShipmentId,  
ICSI.intInventoryShipmentItemId,  
ICSI.strShipmentNumber,  
ICSI.dtmShipDate,  
ICSI.strOrderType,  
ICSI.strSourceType,  
ICSI.strCustomerNumber,  
ICSI.strCustomerName,  
ICSI.ysnPosted,  
ICSI.strItemNo,  
ICSI.strItemDescription,  
ICSI.strSourceNumber,  
ICSI.strOrderNumber AS strContractNumber,
ICSI.strOrderNumber + '-' + CONVERT(varchar(20), SC.intContractSequence) AS strOrderNumber,  
ICSI.strUnitMeasure,  
ICSI.dblQtyToShip,  
ICSI.dblPrice,  
ICSI.dblLineTotal,   
(CASE   
WHEN ISNULL(ICSI.strOrderNumber, '') = '' THEN GRSC.strStorageTypeDescription  
END) AS strStorageTypeDescription,  
ISNULL(GRST.strStorageTypeDescription,   
CASE   
WHEN SC.strDistributionOption = 'CNT' THEN 'Contract'  
WHEN SC.strDistributionOption = 'LOD' THEN 'Load'  
WHEN SC.strDistributionOption = 'SPT' THEN 'Spot Sale'  
WHEN SC.strDistributionOption = 'SPL' THEN 'Split'  
WHEN SC.strDistributionOption = 'HLD' THEN 'Hold'  
END) AS strDistributionOption,  
SC.intScaleSetupId,
SC.intContractId,
SC.intContractSequence,
SC.dblNetUnits,
SC.dtmTicketDateTime
FROM tblSCTicket SC  
INNER JOIN vyuICGetInventoryShipmentItem ICSI ON SC.intInventoryShipmentId = ICSI.intInventoryShipmentId 
LEFT JOIN vyuGRGetStorageTickets GRSC ON SC.intTicketId = GRSC.intTicketId  
LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption