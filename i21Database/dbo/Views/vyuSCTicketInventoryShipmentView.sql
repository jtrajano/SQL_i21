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
	GRST.strStorageTypeDescription
	FROM tblSCTicket SC
	INNER JOIN vyuICGetInventoryShipmentItem ICSI ON SC.intTicketId = ICSI.intSourceId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption
	