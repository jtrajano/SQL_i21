﻿CREATE VIEW [dbo].[vyuICInventoryReceiptLookUp]
	AS

SELECT 
	Receipt.intInventoryReceiptId
	, strVendorName = Vendor.strName
	, Receipt.intEntityId
	, FreightTerm.strFobPoint
	, [Location].strLocationName
	, Currency.strCurrency
	, strFromLocation = FromLocation.strLocationName
	, UserSecurity.strUserName
	, strShipFrom = ShipFrom.strLocationName
	, ShipVia.strShipVia
	, FreightTerm.strFreightTerm
	, Book.strBook
	, SubBook.strSubBook
	, strShipFromEntity = ShipFromEntity.strName
	, bank.strBankName
	, bankAccount.strBankAccountNo
	, borrowingFacility.strBorrowingFacilityId
	, strLimit = limit.strBorrowingFacilityLimit
	, strSublimit = sublimit.strLimitDescription
	, strOverrideFacilityValuation = overrideFacilityValuation.strBankValuationRule
FROM tblICInventoryReceipt Receipt LEFT JOIN vyuAPVendor Vendor 
		ON Vendor.[intEntityId] = Receipt.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation [Location] 
		ON [Location].intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblSMFreightTerms FreightTerm 
		ON FreightTerm.intFreightTermId = Receipt.intFreightTermId
	LEFT JOIN tblSMCurrency Currency
		ON Currency.intCurrencyID = Receipt.intCurrencyId
	LEFT JOIN tblSMCompanyLocation FromLocation 
		ON FromLocation.intCompanyLocationId = Receipt.intTransferorId
	LEFT JOIN tblSMUserSecurity UserSecurity
		ON UserSecurity.[intEntityId] = Receipt.intReceiverId
	LEFT JOIN tblEMEntityLocation ShipFrom
		ON ShipFrom.intEntityLocationId = Receipt.intShipFromId
	LEFT JOIN tblSMShipVia ShipVia
		ON ShipVia.[intEntityId] = Receipt.intShipViaId
	LEFT JOIN tblCTBook Book
		ON Book.intBookId = Receipt.intBookId
	LEFT JOIN tblCTSubBook SubBook
		ON SubBook.intSubBookId = Receipt.intSubBookId
	LEFT JOIN vyuAPVendor ShipFromEntity 
		ON ShipFromEntity.[intEntityId] = Receipt.intShipFromEntityId
	LEFT JOIN tblCMBank bank 
		ON bank.intBankId = Receipt.intBankId
	LEFT JOIN vyuCMBankAccount bankAccount
		ON bankAccount.intBankAccountId = Receipt.intBankAccountId
	LEFT JOIN tblCMBorrowingFacility borrowingFacility
		ON borrowingFacility.intBorrowingFacilityId = Receipt.intBorrowingFacilityId
	LEFT JOIN tblCMBorrowingFacilityLimit limit 
		ON limit.intBorrowingFacilityLimitId = Receipt.intLimitTypeId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit 
		ON sublimit.intBorrowingFacilityLimitDetailId = Receipt.intSublimitTypeId
	LEFT JOIN tblCMBankValuationRule overrideFacilityValuation
		ON overrideFacilityValuation.intBankValuationRuleId = Receipt.intOverrideFacilityValuation

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