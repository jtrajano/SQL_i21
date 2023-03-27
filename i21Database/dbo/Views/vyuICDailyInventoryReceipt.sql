CREATE VIEW [dbo].[vyuICDailyInventoryReceipt]
AS

SELECT 
	Receipt.strReceiptNumber
	, Receipt.dtmReceiptDate		
	, Receipt.strReceiptType
	, Book.strBook	
	, strVendorName = Vendor.strName
	, [Location].strLocationName
	, Receipt.strBillOfLading
	, Currency.strCurrency 
	, Receipt.ysnPosted
	, strSourceType = (
		CASE 
			WHEN Receipt.intSourceType = 0 THEN 'None'
			WHEN Receipt.intSourceType = 1 THEN 'Scale'
			WHEN Receipt.intSourceType = 2 THEN 'Inbound Shipment'
			WHEN Receipt.intSourceType = 3 THEN 'Transport'
			WHEN Receipt.intSourceType = 5 THEN 'Delivery Sheet'
			WHEN Receipt.intSourceType = 6 THEN 'Purchase Order'
			WHEN Receipt.intSourceType = 7 THEN 'Store'
			WHEN Receipt.intSourceType = 9 THEN 'Transfer Shipment'
		END) COLLATE Latin1_General_CI_AS
	, Vendor.strVendorId
	, Receipt.strVendorRefNo
	, Receipt.strWarehouseRefNo
	, strShipFromEntityId = ShipFromEntity.strVendorId
	, strShipFrom = ShipFrom.strLocationName
	, strReceiver = Receiver.strUserName
	, Receipt.strVessel
	, FreightTerm.strFreightTerm
	, FreightTerm.strFobPoint
	, Receipt.intShiftNumber
	, SubBook.strSubBook
	, Receipt.dblInvoiceAmount
	, Receipt.ysnPrepaid
	, Receipt.ysnInvoicePaid
	, strEntityName = Entity.strName
	, Receipt.strActualCostId
	, Receipt.dtmDateCreated
	, dblSubTotal = ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 1),0)
	, dblTax = ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 2),0)
	, dblCharges = ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 3),0)
	, dblGross = ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 4),0)
	, dblNet =  ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 5),0)
	, dblTotal =  ISNULL(dbo.fnICGetReceiptTotals(Receipt.intInventoryReceiptId, 6),0)
FROM tblICInventoryReceipt Receipt
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = Receipt.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation [Location] ON [Location].intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Receipt.intCurrencyId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Receipt.intFreightTermId
	LEFT JOIN tblSMUserSecurity Receiver ON Receiver.[intEntityId] = Receipt.intReceiverId
	LEFT JOIN vyuEMEntity Entity ON Entity.intEntityId = Receipt.intEntityId AND Entity.strType = 'User'
	LEFT JOIN [tblEMEntityLocation] ShipFrom ON ShipFrom.intEntityLocationId = Receipt.intShipFromId
	LEFT JOIN tblCTBook Book ON Book.intBookId = Receipt.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Receipt.intSubBookId
	LEFT JOIN vyuAPVendor ShipFromEntity ON ShipFromEntity.[intEntityId] = Receipt.intShipFromEntityId
	
