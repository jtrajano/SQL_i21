CREATE VIEW [dbo].[vyuSCTicketInventoryReceiptView]
	AS SELECT 
	SC.intTicketId,
	ICRI.intInventoryReceiptId,
	ICRI.intInventoryReceiptItemId,
	ICRI.strReceiptNumber,
	ICRI.strReceiptType,
	ICRI.strItemNo,
	ICRI.strItemDescription,
	
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
	SC.strLoadNumber,
	(CASE 
		WHEN SC.intContractId > 0 THEN SC.strContractNumber + '-' + CONVERT(varchar(20), SC.intContractSequence)
	END) COLLATE Latin1_General_CI_AS AS strOrderNumber,
	(CASE 
		WHEN ISNULL(ICRI.strOrderNumber, '') = '' THEN GRSC.strStorageTypeDescription
	END) COLLATE Latin1_General_CI_AS AS strStorageTypeDescription,
	(CASE 
		WHEN SC.strDistributionOption = 'CNT' THEN 'Contract'
		WHEN SC.strDistributionOption = 'LOD' THEN 'Load'
		WHEN SC.strDistributionOption = 'SPT' THEN 'Spot Sale'
		WHEN SC.strDistributionOption = 'SPL' THEN 'Split'
		WHEN SC.strDistributionOption = 'HLD' THEN 'Hold'
	END) COLLATE Latin1_General_CI_AS AS strDistributionOption,
	SC.intScaleSetupId
	FROM tblSCTicket SC 
	INNER JOIN tblICInventoryReceipt ICR ON SC.intInventoryReceiptId = ICR.intInventoryReceiptId
	INNER JOIN vyuICGetInventoryReceiptItem ICRI ON SC.strTicketNumber = ICRI.strSourceNumber
	LEFT JOIN vyuGRGetStorageTickets GRSC ON SC.intTicketId = GRSC.intTicketId
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption