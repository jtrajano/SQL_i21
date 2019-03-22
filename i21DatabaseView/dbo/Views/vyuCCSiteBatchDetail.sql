CREATE VIEW [dbo].[vyuCCSiteBatchDetail]

AS 

SELECT BatchDetail.intSiteBatchDetailId
	, BatchDetail.intSiteDetailId
	, SiteDetail.intSiteHeaderId
	, strVendorName = Vendor.strName
	, SiteHeader.strCcdReference
	, SiteHeader.strReference
	, SiteHeader.strApType
	, SiteHeader.dtmDate
	, Vendor.strLocationName
	, SiteHeader.ysnPosted
	, [Site].strSite
	, [Site].strSiteDescription
	, [Site].strSiteType
	, [Site].strCustomerName
	, BatchDetail.strBatch
	, BatchDetail.dblGross
	, BatchDetail.dblFees
	, BatchDetail.dblNet
FROM tblCCSiteBatchDetail BatchDetail
INNER JOIN tblCCSiteDetail SiteDetail ON BatchDetail.intSiteDetailId = SiteDetail.intSiteDetailId
INNER JOIN tblCCSiteHeader SiteHeader ON SiteHeader.intSiteHeaderId = SiteDetail.intSiteHeaderId
LEFT JOIN vyuCCSite [Site] ON [Site].intSiteId = SiteDetail.intSiteId
LEFT JOIN vyuCCVendor Vendor ON Vendor.intVendorDefaultId = [Site].intVendorDefaultId