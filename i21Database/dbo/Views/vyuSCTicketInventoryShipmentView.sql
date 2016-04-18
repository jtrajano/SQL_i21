CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentView]
	AS SELECT 
	SC.intTicketId,
	ICSI.intInventoryShipmentId,
	ICSI.strShipmentNumber,
	ICSI.dtmShipDate,
	ICSI.strOrderType,
	ICSI.strSourceType,
	SC.intEntityId,
	ICSI.strCustomerNumber,
	ICSI.strCustomerName,
	ICSI.ysnPosted,
	ICSI.strItemNo,
	ICSI.strItemDescription,
	ICSI.strOrderNumber,
	ICSI.strSourceNumber,
	ICSI.strUnitMeasure,
	ICSI.dblQtyToShip,
	ICSI.dblPrice,
	ICSI.dblLineTotal,
	SC.strTicketNumber,
	SC.strLoadNumber,
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
		END) AS strDistributionOption
	FROM tblSCTicket SC
	INNER JOIN vyuICGetInventoryShipmentItem ICSI ON SC.intTicketId = ICSI.intSourceId
	LEFT JOIN vyuGRGetStorageTransferTicket GRSC ON SC.intTicketId = GRSC.intTicketId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption
	