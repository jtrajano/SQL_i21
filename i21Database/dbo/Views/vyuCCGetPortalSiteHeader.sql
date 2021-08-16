CREATE VIEW [dbo].[vyuCCGetPortalSiteHeader]
AS
SELECT        
	  SiteDetail.intSiteHeaderId
	, Site.intCustomerId
	, Vendor.intVendorId
	, Vendor.strName AS strVendorName
	, SiteHeader.strCcdReference
	, SUM(SiteDetail.dblGross) AS dblGross
	, SUM(SiteDetail.dblFees) AS dblFees
	, SUM(SiteDetail.dblNet) AS dblNet
	, Site.strCustomerName, SiteHeader.dtmDate
	, SiteHeader.strReference
	, SiteHeader.intVendorDefaultId
	, SiteHeader.strApType
	, Vendor.strBankAccountNo
	, Vendor.intBankAccountId
	, SiteHeader.intCompanyLocationId
	, Vendor.strLocationName
	, SiteHeader.strInvoice
	, SiteHeader.ysnPosted
	, SiteHeader.intCMBankTransactionId
	, SiteHeader.strPayReference
	, Vendor.strVendorId

FROM            
	dbo.tblCCSiteDetail AS SiteDetail 
	INNER JOIN dbo.tblCCSiteHeader AS SiteHeader ON SiteDetail.intSiteHeaderId = SiteHeader.intSiteHeaderId 
	LEFT OUTER JOIN dbo.vyuCCSite AS Site ON Site.intSiteId = SiteDetail.intSiteId 
	LEFT OUTER JOIN dbo.vyuCCVendor AS Vendor ON Vendor.intVendorDefaultId = SiteHeader.intVendorDefaultId

GROUP BY 
	  SiteHeader.strCcdReference
	, SiteHeader.dtmDate
	, Site.intCustomerId
	, Site.strCustomerName
	, SiteDetail.intSiteHeaderId
	, Vendor.strName
	, SiteHeader.strReference
	, SiteHeader.intVendorDefaultId
	, SiteHeader.strApType
	, Vendor.strBankAccountNo
	, Vendor.intBankAccountId
	, Vendor.intVendorId
	, SiteHeader.intCompanyLocationId
	, Vendor.strLocationName
	, SiteHeader.strInvoice
	, SiteHeader.ysnPosted
	, SiteHeader.intCMBankTransactionId
	, SiteHeader.strPayReference
	, Vendor.strVendorId