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
	, intEntityVendorId = SP.intEntityVendorId
	, strFuelSupplier = Terminal.strName
	, intVendorLocationId = SP.intEntityLocationId
	, SP.strSupplyPoint
	, strBOL = TR.strBillOfLading
	, intReceiptCompanyLocationId = Location.intCompanyLocationId
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
	, intInventoryReceiptId = Receipt.intInventoryReceiptId
	, strInventoryReceiptNo = Receipt.strReceiptNumber
	, intInventoryTransferId = Transfer.intInventoryTransferId
	, strInventoryTransferNo = Transfer.strTransferNo
	, intInvoiceId = ''
	, strInvoiceNo = NULL
	, strLoadNumber = ISNULL(b.strExternalLoadNumber, b.strLoadNumber)
	, TL.intDispatchOrderId
	, strDispatchId = LGD.strDispatchOrderNumber
	, intTMOId = NULL
	, strTMOrder = ''
	, strShipVia = c.strName
	, strSeller = d.strName
	, strStateName = e.strStateName
	, strTractor = smtr.strTruckNumber
	, strSalesUnit = NULL
	, strInvoiceType = NULL
	, strSiteNumber = ''  
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
left join tblSMShipViaTruck smtr on smtr.intEntityShipViaTruckId = TL.intTruckId
LEFT JOIN tblLGDispatchOrder LGD ON LGD.intDispatchOrderId = TL.intDispatchOrderId


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
	, intEntityVendorId = Receipts.intEntityVendorId
	, Receipts.strFuelSupplier
	, intVendorLocationId = Receipts.intEntityLocationId
	, Receipts.strSupplyPoint
	, strBOL = DD.strBillOfLading
	, intReceiptCompanyLocationId = Receipts.intReceiptCompanyLocationId
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
	, intInventoryReceiptId = Receipts.intInventoryReceiptId
	, strInventoryReceiptNo = Receipts.strReceiptNumber
	, intInventoryTransferId = Receipts.intInventoryTransferId
	, strInventoryTransferNo = Receipts.strTransferNo
	, Invoice.intInvoiceId
	, strInvoiceNo = Invoice.strInvoiceNumber
	, strLoadNumber = ISNULL(b.strExternalLoadNumber, b.strLoadNumber)
	, TL.intDispatchOrderId
	, strDispatchId = LGD.strDispatchOrderNumber
	, intTMOId = DD.intTMOId
	, strTMOrder = ISNULL(TMD.strOrderNumber, TMH.strOrderNumber)
	, strShipVia = c.strName
	, strSeller = d.strName
	, strStateName = e.strStateName
	, strTractor = smtr.strTruckNumber
	, strSalesUnit = EL.strSaleUnits
	, strInvoiceType = Invoice.strType
	, strSiteNumber = RIGHT('000' + CAST(site.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS
FROM tblTRLoadHeader TL
JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
LEFT JOIN vyuEMSalesperson Driver ON Driver.strType = 'Driver' AND Driver.[intEntityId] = TL.intDriverId
LEFT JOIN tblICItem Item ON Item.intItemId = DD.intItemId
LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = DH.intInvoiceId
LEFT JOIN vyuEMEntity CS ON CS.intEntityId = DH.intEntityCustomerId AND CS.strType = 'Customer'
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = DH.intCompanyLocationId
LEFT JOIN tblLGLoad b on b.intLoadId = TL.intLoadId
LEFT JOIN tblEMEntity c on c.intEntityId = TL.intShipViaId
LEFT JOIN tblEMEntity d on d.intEntityId = TL.intSellerId
LEFT JOIN tblTRState e on e.intStateId = TL.intStateId
LEFT JOIN tblSCTruckDriverReference dr on dr.intTruckDriverReferenceId = TL.intTruckDriverReferenceId
LEFT JOIN tblSMShipViaTruck smtr on smtr.intEntityShipViaTruckId = TL.intTruckId
LEFT JOIN vyuTRLinkedReceipts Receipts ON Receipts.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
LEFT JOIN tblTMDispatch TMD ON TMD.intDispatchID = DD.intTMOId
LEFT JOIN tblTMDispatchHistory TMH ON TMH.intDispatchId = DD.intTMOId
LEFT JOIN tblLGDispatchOrder LGD ON LGD.intDispatchOrderId = TL.intDispatchOrderId
LEFT JOIN tblTMSite site ON DD.intSiteId = site.intSiteID