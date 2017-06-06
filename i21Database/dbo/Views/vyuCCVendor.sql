CREATE VIEW [dbo].[vyuCCVendor]

AS

SELECT DISTINCT VendorDefault.intVendorDefaultId
	, VendorDefault.intVendorId
	, intEntityId = Vendor.[intEntityId]
	, Vendor.strVendorId
	, Entity.strName
	, EntityLocation.strAddress
	, Vendor.intCurrencyId
	, VendorDefault.intBankAccountId
	, BankAccount.strCbkNo
	, BankAccount.strBankAccountNo
	, VendorDefault.intCompanyLocationId
	, Location.strLocationName
	, Term.intTermID
	, Term.strTerm
	, Vendor.intPaymentMethodId
	, F.strPaymentMethod
	, VendorDefault.strApType
	, VendorDefault.strEnterTotalsAsGrossOrNet
	, VendorDefault.strFileType
	, VendorDefault.strImportFileName
	, VendorDefault.strImportAuxiliaryFileName
	, VendorDefault.strImportFilePath
	, VendorDefault.intImportFileHeaderId
FROM tblCCVendorDefault VendorDefault
INNER JOIN tblCCSite DealerSite ON DealerSite.intVendorDefaultId = VendorDefault.intVendorDefaultId
INNER JOIN tblAPVendor Vendor ON VendorDefault.intVendorId = Vendor.[intEntityId]
INNER JOIN tblEMEntity Entity ON Vendor.[intEntityId] = Entity.intEntityId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = Entity.intEntityId AND EntityLocation.ysnActive = 1 AND EntityLocation.ysnDefaultLocation = 1
LEFT JOIN tblSMTerm Term ON Term.intTermID = EntityLocation.intTermsId
LEFT JOIN tblSMPaymentMethod F ON F.intPaymentMethodID = Vendor.intPaymentMethodId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = VendorDefault.intCompanyLocationId
LEFT JOIN vyuCMBankAccount BankAccount ON VendorDefault.intBankAccountId = BankAccount.intBankAccountId
--LEFT JOIN tblCMBankAccount BankAccount ON VendorDefault.intBankAccountId = BankAccount.intBankAccountId