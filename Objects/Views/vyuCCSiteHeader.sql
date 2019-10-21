CREATE VIEW [dbo].[vyuCCSiteHeader]

AS 

SELECT SiteHeader.intSiteHeaderId
	, SiteHeader.intVendorDefaultId
	, Vendor.intVendorId
	, strVendorName = Vendor.strName
	, Vendor.intBankAccountId
	, Vendor.strBankAccountNo
	, SiteHeader.strApType
	, Vendor.intCompanyLocationId
	, Vendor.strLocationName
	, SiteHeader.dtmDate
	, SiteHeader.strReference
	, SiteHeader.dblGross
	, SiteHeader.dblFees
	, SiteHeader.dblNet
	, SiteHeader.strCcdReference
	, SiteHeader.strInvoice
	, SiteHeader.strPayReference
	, SiteHeader.ysnPosted
	, SiteHeader.intCMBankTransactionId
FROM tblCCSiteHeader SiteHeader
INNER JOIN vyuCCVendor Vendor ON Vendor.intVendorDefaultId = SiteHeader.intVendorDefaultId