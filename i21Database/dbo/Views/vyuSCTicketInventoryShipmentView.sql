CREATE VIEW [dbo].[vyuSCTicketInventoryShipmentView]
	AS SELECT 
	ICSI.intInventoryShipmentId,
	ICSI.strShipmentNumber,
	ICSI.dtmShipDate,
	ICSI.strOrderType,
	ICSI.strSourceType,
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
	ISNULL(GRST.strStorageTypeDescription, 
	   CASE 
			WHEN SC.strDistributionOption = 'CNT' THEN 'Contract'
			WHEN SC.strDistributionOption = 'LOD' THEN 'Load'
			WHEN SC.strDistributionOption = 'SPT' THEN 'Spot Sale'
			WHEN SC.strDistributionOption = 'SPL' THEN 'Split'
			WHEN SC.strDistributionOption = 'HLD' THEN 'Hold'
		END ) AS strStorageTypeDescription
	FROM tblSCTicket SC
	INNER JOIN vyuICGetInventoryShipmentItem ICSI ON SC.intTicketId = ICSI.intSourceId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption
	