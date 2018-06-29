CREATE VIEW [dbo].[vyuCCSiteDetail]

AS 

SELECT SiteDetail.intSiteDetailId
	, SiteDetail.intSiteHeaderId
	, SiteDetail.intSiteId
	, SiteDetail.dblGross
	, SiteDetail.dblFees
	, SiteDetail.dblNet
	, SiteHeader.strApType
	, SiteHeader.strCcdReference
	, SiteHeader.strReference
	, SiteHeader.ysnPosted
	, [Site].strCustomerName
	, [Site].strSite
	, [Site].strSiteDescription
	, [Site].strSiteType
	, Vendor.strLocationName
	, strVendorName = Vendor.strName
	, SiteHeader.dtmDate
FROM tblCCSiteDetail SiteDetail
INNER JOIN tblCCSiteHeader SiteHeader ON SiteDetail.intSiteHeaderId = SiteHeader.intSiteHeaderId
LEFT JOIN vyuCCSite [Site] ON [Site].intSiteId = SiteDetail.intSiteId
LEFT JOIN vyuCCVendor Vendor ON Vendor.intVendorDefaultId = SiteHeader.intVendorDefaultId