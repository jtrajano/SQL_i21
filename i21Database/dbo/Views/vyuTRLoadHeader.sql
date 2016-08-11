CREATE VIEW [dbo].[vyuTRLoadHeader]
	AS 

SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, strReceiptLink = TR.strReceiptLine
	, strRecordType = (CASE WHEN TR.intLoadReceiptId IS NULL THEN 'Header'
							ELSE 'Receipt' END)
	, strCustomer = NULL
	, strCustomerLocation = NULL
	, strCustomerCompanyLocation = NULL
	, SP.strFuelSupplier
	, SP.strSupplyPoint
	, strBOL = TR.strBillOfLading
	, strReceiptCompanyLocation = Location.strLocationName
	, strItem = Item.strItemNo
	, dblQuantity = CASE WHEN SP.strGrossOrNet = 'Gross' THEN TR.dblGross
						WHEN SP.strGrossOrNet = 'Net' THEN TR.dblNet END
	, dblPrice = NULL
	, dblCost = TR.dblUnitCost
	, dblMargin = NULL
	, dblTotalFreight = CASE WHEN SP.strGrossOrNet = 'Gross' THEN (dblGross * dblFreightRate * (1 + dblPurSurcharge / 100))
						WHEN SP.strGrossOrNet = 'Net' THEN (dblNet * dblFreightRate * (1 + dblPurSurcharge / 100)) END
	, strDriver = Driver.strName
	, dtmDateTime = TL.dtmLoadDateTime
	, TL.ysnPosted
	, strInventoryReceiptNo = Receipt.strReceiptNumber
	, strInventoryTransferNo = Transfer.strTransferNo
	, strInvoiceNo = NULL
FROM tblTRLoadHeader TL
LEFT JOIN tblTRLoadReceipt TR ON TL.intLoadHeaderId = TR.intLoadHeaderId
LEFT JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = TR.intSupplyPointId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = TR.intCompanyLocationId
LEFT JOIN tblICItem Item ON Item.intItemId = TR.intItemId
LEFT JOIN vyuEMSalesperson Driver ON Driver.strType = 'Driver' AND Driver.intEntitySalespersonId = TL.intDriverId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = TR.intInventoryReceiptId
LEFT JOIN tblICInventoryTransfer Transfer ON Transfer.intInventoryTransferId = TR.intInventoryTransferId

UNION ALL
SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, DD.strReceiptLink
	, strRecordType = 'Distribution'
	, strCustomer = CS.strName
	, strCustomerLocation = EL.strLocationName
	, strCustomerCompanyLocation = SM.strLocationName
	, Receipts.strFuelSupplier
	, Receipts.strSupplyPoint
	, strBOL = Receipts.strBillOfLading
	, Receipts.strReceiptCompanyLocation
	, strItem = Item.strItemNo
	, dblQuantity = DD.dblUnits
	, dblPrice = DD.dblPrice
	, dblCost = Receipts.dblUnitCost
	, dblMargin = DD.dblPrice - Receipts.dblUnitCost
	, dblTotalFreight = (dblUnits * dblFreightRate * (1 + dblDistSurcharge / 100))
	, strDriver = Driver.strName
	, dtmDateTime = DH.dtmInvoiceDateTime
	, TL.ysnPosted
	, strInventoryReceiptNo = Receipts.strReceiptNumber
	, strInventoryTransferNo = Receipts.strTransferNo
	, strInvoiceNo = Invoice.strInvoiceNumber
FROM tblTRLoadHeader TL
JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
LEFT JOIN vyuEMSalesperson Driver ON Driver.strType = 'Driver' AND Driver.intEntitySalespersonId = TL.intDriverId
LEFT JOIN tblICItem Item ON Item.intItemId = DD.intItemId
LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = DH.intInvoiceId
LEFT JOIN vyuEMEntity CS ON CS.intEntityId = DH.intEntityCustomerId AND CS.strType = 'Customer'
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = DH.intCompanyLocationId
LEFT JOIN(
	SELECT DISTINCT intLoadDistributionDetailId
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strFuelSupplier
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
					AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strFuelSupplier
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strSupplyPoint
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strSupplyPoint
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strBillOfLading
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strBillOfLading
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strReceiptCompanyLocation
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strReceiptCompanyLocation
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strReceiptNumber
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strReceiptNumber
		, STUFF(
				(SELECT	DISTINCT ', ' + CD.strTransferNo
				FROM vyuTRLinkedReceipts CD
				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
				FOR XML PATH('')), 1, 2, ''
				) strTransferNo
		, (SELECT AVG(CD.dblUnitCost)
			FROM vyuTRLinkedReceipts CD
			WHERE CD.intLoadHeaderId = CH.intLoadHeaderId AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId) dblUnitCost
	FROM vyuTRLinkedReceipts CH) Receipts ON Receipts.intLoadDistributionDetailId = DD.intLoadDistributionDetailId