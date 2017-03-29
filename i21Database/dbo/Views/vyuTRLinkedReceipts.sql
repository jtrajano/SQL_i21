CREATE VIEW [dbo].[vyuTRLinkedReceipts]
	AS 

SELECT TR.intLoadHeaderId
	, DD.intLoadDistributionDetailId
	, TR.strBillOfLading
	, SP.intEntityVendorId
	, strFuelSupplier = Terminal.strName
	, SP.intEntityLocationId
	, SP.strSupplyPoint
	, intReceiptCompanyLocationId = SM.intCompanyLocationId
	, strReceiptCompanyLocation = SM.strLocationName
	, TR.intInventoryReceiptId
	, Receipt.strReceiptNumber
	, TR.intInventoryTransferId
	, Transfer.strTransferNo
	, TR.dblUnitCost
FROM tblTRLoadDistributionHeader DH
JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
LEFT JOIN tblTRLoadReceipt TR ON DH.intLoadHeaderId = TR.intLoadHeaderId
	AND TR.strReceiptLine IN (SELECT Item FROM fnTRSplit(DD.strReceiptLink,','))
LEFT JOIN vyuTRTerminal Terminal ON Terminal.[intEntityId] = TR.intTerminalId
LEFT JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = TR.intSupplyPointId
LEFT JOIN tblICInventoryReceipt Receipt ON TR.intInventoryReceiptId = Receipt.intInventoryReceiptId
	AND TR.intLoadReceiptId = TR.intLoadReceiptId
LEFT JOIN tblICInventoryTransfer Transfer ON TR.intInventoryTransferId = Transfer.intInventoryTransferId
	AND TR.intLoadReceiptId = TR.intLoadReceiptId
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = TR.intCompanyLocationId