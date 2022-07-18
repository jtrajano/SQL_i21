CREATE VIEW [dbo].[vyuTRLoadHeader]
	AS 

SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, strReceiptLink = TR.strReceiptLine
	, strRecordType = (CASE WHEN TR.intLoadReceiptId IS NULL THEN 'Header'
							ELSE 'Receipt' END) COLLATE Latin1_General_CI_AS
	, intEntityCustomerId = NULL
	, strCustomer = NULL
	, intCustomerLocationId = NULL
	, strCustomerLocation = NULL
	, intCustomerCompanyLocationId = NULL
	, strCustomerCompanyLocation = NULL
	, intEntityVendorId = CAST(SP.intEntityVendorId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strFuelSupplier = Terminal.strName
	, intVendorLocationId = CAST(SP.intEntityLocationId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, SP.strSupplyPoint
	, strBOL = TR.strBillOfLading
	, intReceiptCompanyLocationId = CAST(Location.intCompanyLocationId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strReceiptCompanyLocation = Location.strLocationName
	, Item.intItemId
	, strItem = Item.strItemNo
	, strCostMethodFreight = Item.strCostMethod
	, dblQuantity = CASE WHEN SP.strGrossOrNet = 'Gross' THEN TR.dblGross
						WHEN SP.strGrossOrNet = 'Net' THEN TR.dblNet
						ELSE TR.dblGross END
	, dblPrice = NULL
	, dblCost = TR.dblUnitCost
	, dblMargin = NULL
	, dblTotalFreight = CASE WHEN SP.strGrossOrNet = 'Gross' THEN (TR.dblGross * TR.dblFreightRate * (1 + TR.dblPurSurcharge / 100))
						WHEN SP.strGrossOrNet = 'Net' THEN (TR.dblNet * TR.dblFreightRate * (1 + TR.dblPurSurcharge / 100)) 
						ELSE (TR.dblGross * TR.dblFreightRate * (1 + TR.dblPurSurcharge / 100)) END
	, strDriver = Driver.strName
	, dtmDateTime = TL.dtmLoadDateTime
	, TL.ysnPosted
	, intInventoryReceiptId = CAST(Receipt.intInventoryReceiptId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strInventoryReceiptNo = Receipt.strReceiptNumber
	, intInventoryTransferId = CAST(Transfer.intInventoryTransferId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strInventoryTransferNo = Transfer.strTransferNo
	, intInvoiceId = ''
	, strInvoiceNo = NULL
	, strLoadNumber = isnull(b.strExternalLoadNumber, b.strLoadNumber)
	, strShipVia = c.strName
	, strSeller = d.strName
	, strStateName = e.strStateName
	, strTractor = dr.strData
	, strSalesUnit = NULL
	, strInvoiceType = NULL
FROM tblTRLoadHeader TL
LEFT JOIN tblTRLoadReceipt TR ON TL.intLoadHeaderId = TR.intLoadHeaderId
LEFT JOIN vyuTRTerminal Terminal ON Terminal.[intEntityVendorId] = TR.intTerminalId
LEFT JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = TR.intSupplyPointId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = TR.intCompanyLocationId
LEFT JOIN tblICItem Item ON Item.intItemId = TR.intItemId
LEFT JOIN vyuEMSalesperson Driver ON Driver.strType = 'Driver' AND Driver.[intEntityId] = TL.intDriverId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = TR.intInventoryReceiptId
LEFT JOIN tblICInventoryTransfer Transfer ON Transfer.intInventoryTransferId = TR.intInventoryTransferId
left join tblLGLoad b on b.intLoadId = TL.intLoadId
left join tblEMEntity c on c.intEntityId = TL.intShipViaId
left join tblEMEntity d on d.intEntityId = TL.intSellerId
left join tblTRState e on e.intStateId = TL.intStateId
left join tblSCTruckDriverReference dr on dr.intTruckDriverReferenceId = TL.intTruckDriverReferenceId


UNION ALL
SELECT TL.intLoadHeaderId
	, TL.strTransaction
	, DD.strReceiptLink
	, strRecordType = 'Distribution'
	, intEntityCustomerId = CS.intEntityId
	, strCustomer = CS.strName
	, intCustomerLocationId = EL.intEntityLocationId
	, strCustomerLocation = EL.strLocationName
	, intCustomerCompanyLocationId = SM.intCompanyLocationId
	, strCustomerCompanyLocation = SM.strLocationName
	, intEntityVendorId = CAST(Receipts.intEntityVendorId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	, Receipts.strFuelSupplier
	, intVendorLocationId = CAST(Receipts.intEntityLocationId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, Receipts.strSupplyPoint
	--, strBOL = Receipts.strBillOfLading
	, strBOL = DD.strBillOfLading
	, intReceiptCompanyLocationId = CAST(Receipts.intReceiptCompanyLocationId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, Receipts.strReceiptCompanyLocation
	, Item.intItemId
	, strItem = Item.strItemNo
	, strCostMethodFreight = Item.strCostMethod
	, dblQuantity = DD.dblUnits
	, dblPrice = DD.dblPrice
	, dblCost = Receipts.dblUnitCost
	, dblMargin = DD.dblPrice - Receipts.dblUnitCost
	, dblTotalFreight = (DD.dblUnits * DD.dblFreightRate * (1 + DD.dblDistSurcharge / 100))
	, strDriver = Driver.strName
	, dtmDateTime = DH.dtmInvoiceDateTime
	, TL.ysnPosted
	, intInventoryReceiptId = CAST(Receipts.intInventoryReceiptId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strInventoryReceiptNo = Receipts.strReceiptNumber
	, intInventoryTransferId = CAST(Receipts.intInventoryTransferId AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	, strInventoryTransferNo = Receipts.strTransferNo
	, Invoice.intInvoiceId
	, strInvoiceNo = Invoice.strInvoiceNumber
	, strLoadNumber = isnull(b.strExternalLoadNumber, b.strLoadNumber)
	, strShipVia = c.strName
	, strSeller = d.strName
	, strStateName = e.strStateName
	, strTractor = dr.strData
	, strSalesUnit = EL.strSaleUnits
	, strInvoiceType = Invoice.strType
FROM tblTRLoadHeader TL
JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
LEFT JOIN vyuEMSalesperson Driver ON Driver.strType = 'Driver' AND Driver.[intEntityId] = TL.intDriverId
LEFT JOIN tblICItem Item ON Item.intItemId = DD.intItemId
LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = DH.intInvoiceId
LEFT JOIN vyuEMEntity CS ON CS.intEntityId = DH.intEntityCustomerId AND CS.strType = 'Customer'
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = DH.intCompanyLocationId
left join tblLGLoad b on b.intLoadId = TL.intLoadId
left join tblEMEntity c on c.intEntityId = TL.intShipViaId
left join tblEMEntity d on d.intEntityId = TL.intSellerId
left join tblTRState e on e.intStateId = TL.intStateId
left join tblSCTruckDriverReference dr on dr.intTruckDriverReferenceId = TL.intTruckDriverReferenceId
left join vyuTRLinkedReceipts Receipts ON Receipts.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
-- LEFT JOIN(
-- 	SELECT DISTINCT intLoadDistributionDetailId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CAST(CD.intEntityVendorId AS NVARCHAR(10))
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 					AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) intEntityVendorId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strFuelSupplier
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 					AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strFuelSupplier
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CAST(CD.intEntityLocationId AS NVARCHAR(10))
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) intEntityLocationId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strSupplyPoint
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strSupplyPoint
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strBillOfLading
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId 
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strBillOfLading
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CAST(CD.intReceiptCompanyLocationId AS NVARCHAR(10))
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) intReceiptCompanyLocationId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strReceiptCompanyLocation
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strReceiptCompanyLocation
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CAST(CD.intInventoryReceiptId AS NVARCHAR(10))
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) intInventoryReceiptId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strReceiptNumber
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strReceiptNumber
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CAST(CD.intInventoryTransferId AS NVARCHAR(10))
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) intInventoryTransferId
-- 		, STUFF(
-- 				(SELECT	DISTINCT ', ' + CD.strTransferNo
-- 				FROM vyuTRLinkedReceipts CD
-- 				WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
-- 				AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
-- 				FOR XML PATH('')), 1, 2, ''
-- 				) strTransferNo
-- 		, (SELECT AVG(CD.dblUnitCost)
-- 			FROM vyuTRLinkedReceipts CD
-- 			WHERE CD.intLoadHeaderId = CH.intLoadHeaderId AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId) dblUnitCost
-- 	FROM vyuTRLinkedReceipts CH) Receipts ON Receipts.intLoadDistributionDetailId = DD.intLoadDistributionDetailId