CREATE VIEW [dbo].[vyuICInventoryReceiptLookUp]
	AS

SELECT 
	Receipt.intInventoryReceiptId
	, strVendorName = Vendor.strName
	, Receipt.intEntityId
	, FreightTerm.strFobPoint
	, Location.strLocationName
	, Currency.strCurrency

FROM tblICInventoryReceipt Receipt LEFT JOIN vyuAPVendor Vendor 
		ON Vendor.intEntityVendorId = Receipt.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation Location 
		ON Location.intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblSMFreightTerms FreightTerm 
		ON FreightTerm.intFreightTermId = Receipt.intFreightTermId
	LEFT JOIN tblSMCurrency Currency
		ON Currency.intCurrencyID = Receipt.intCurrencyId

	--LEFT JOIN tblSMCompanyLocation Transferor 
	--	ON Transferor.intCompanyLocationId = Receipt.intTransferorId
	--LEFT JOIN tblSMCurrency Currency 
	--	ON Currency.intCurrencyID = Receipt.intCurrencyId
	--LEFT JOIN tblSMShipVia ShipVia 
	--	ON ShipVia.intEntityShipViaId = Receipt.intShipViaId
	--LEFT JOIN tblSMUserSecurity Receiver 
	--	ON Receiver.intEntityUserSecurityId = Receipt.intReceiverId
	--LEFT JOIN vyuEMEntity Entity 
	--	ON Entity.intEntityId = Receipt.intEntityId 
	--	AND Entity.strType = 'User'
	--LEFT JOIN tblEMEntityLocation ShipFrom 
	--	ON ShipFrom.intEntityLocationId = Receipt.intShipFromId
	--LEFT JOIN tblSMTaxGroup TaxGroup 
		--ON TaxGroup.intTaxGroupId = Receipt.intTaxGroupId