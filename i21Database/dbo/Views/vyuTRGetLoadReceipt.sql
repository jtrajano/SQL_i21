CREATE VIEW [dbo].[vyuTRGetLoadReceipt]
	AS

SELECT Receipt.intLoadReceiptId
	, Receipt.intLoadHeaderId
	, Header.strTransaction
	, Header.dtmLoadDateTime
	, Receipt.strOrigin
	, Receipt.intTerminalId
	, strTerminal = Terminal.strName
	, strTerminalId = Terminal.strVendorId
	, Receipt.intSupplyPointId
	, strSupplyPoint = SupplyPoint.strSupplyPoint
	, Receipt.intCompanyLocationId
	, CompanyLocation.strLocationName
	, Receipt.strBillOfLading
	, Receipt.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strType
	, Item.strLotTracking
	, Receipt.intContractDetailId
	, Contract.strContractNumber
	, Receipt.dblGross
	, Receipt.dblNet
	, Receipt.dblUnitCost
	, Receipt.dblFreightRate
	, Receipt.dblPurSurcharge
	, Receipt.intInventoryReceiptId
	, IR.strReceiptNumber
	, Receipt.ysnFreightInPrice
	, Receipt.intTaxGroupId
	, TaxGroup.strTaxGroup
	, Receipt.intInventoryTransferId
	, IT.strTransferNo
	, Receipt.strReceiptLine
	, Receipt.intLoadDetailId
	, LoadSchedule.strLoadNumber
	, strZipCode = (CASE WHEN ISNULL(Receipt.intSupplyPointId, '') <> '' THEN ISNULL(SupplyPoint.strZipCode, CompanyLocation.strZipPostalCode)
						ELSE CompanyLocation.strZipPostalCode END)
FROM tblTRLoadReceipt Receipt
LEFT JOIN tblTRLoadHeader Header ON Header.intLoadHeaderId = Receipt.intLoadHeaderId
LEFT JOIN vyuTRTerminal Terminal ON Terminal.intEntityVendorId = Receipt.intTerminalId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = Receipt.intSupplyPointId
LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = Receipt.intCompanyLocationId
LEFT JOIN tblICItem Item ON Item.intItemId = Receipt.intItemId
LEFT JOIN vyuCTContractDetailView Contract ON Contract.intContractDetailId = Receipt.intContractDetailId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = Receipt.intInventoryTransferId
LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = Receipt.intTaxGroupId
LEFT JOIN vyuLGLoadDetailView LoadSchedule ON LoadSchedule.intLoadDetailId = Receipt.intLoadDetailId