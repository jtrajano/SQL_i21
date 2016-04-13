CREATE VIEW [dbo].[vyuSCTicketInventoryReceiptView]
	AS SELECT 
	ICRI.intInventoryReceiptId,
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
	ICRI.strVendorName,
	ICRI.strLocationName,
	ICRI.ysnPosted,
	SC.strTicketNumber,
	ISNULL(GRST.strStorageTypeDescription, 
	   CASE 
			WHEN SC.strDistributionOption = 'CNT' THEN 'Contract'
			WHEN SC.strDistributionOption = 'LOD' THEN 'Load'
			WHEN SC.strDistributionOption = 'SPT' THEN 'Spot Sale'
			WHEN SC.strDistributionOption = 'SPL' THEN 'Split'
			WHEN SC.strDistributionOption = 'HLD' THEN 'Hold'
		END) AS strStorageTypeDescription
	FROM tblSCTicket SC
	INNER JOIN vyuICGetInventoryReceiptItem ICRI ON SC.intInventoryReceiptId = ICRI.intInventoryReceiptId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption