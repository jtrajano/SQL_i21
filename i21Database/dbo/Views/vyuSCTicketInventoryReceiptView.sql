CREATE VIEW [dbo].[vyuSCTicketInventoryReceiptView]
	AS SELECT 
	SC.intTicketId,
	ICRI.intInventoryReceiptId,
	ICRI.intInventoryReceiptItemId,
	ICRI.strReceiptNumber,
	ICRI.strReceiptType,
	ICRI.strItemNo,
	ICRI.strItemDescription,
	ICRI.strOrderNumber,
	ICRI.strSourceNumber,
	ICRI.strUnitMeasure,
	ICRI.dblQtyToReceive,
	ICRI.dblUnitCost,
	ICRI.dblTax,
	ICRI.dblLineTotal,
	ICRI.strCostUOM,
	ICRI.dtmReceiptDate,
	SC.intEntityId,
	ICRI.strVendorName,
	ICRI.strLocationName,
	ICRI.ysnPosted,
	SC.strTicketNumber,
	GRST.strStorageTypeDescription
	FROM tblSCTicket SC
	INNER JOIN vyuICGetInventoryReceiptItem ICRI ON SC.intInventoryReceiptId = ICRI.intInventoryReceiptId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption