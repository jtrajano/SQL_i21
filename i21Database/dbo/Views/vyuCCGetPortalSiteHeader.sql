CREATE VIEW [dbo].[vyuCCGetPortalSiteHeader]
AS
SELECT        
	  Site.intCustomerId
	, SiteDetail.intSiteHeaderId
	, Vendor.strName AS strVendorName
	, SiteHeader.strCcdReference
	, SUM(SiteDetail.dblGross) dblGross
	, SUM(SiteDetail.dblFees) dblFees
	, SUM(SiteDetail.dblNet) dblNet
	, Site.strCustomerName
	, SiteHeader.dtmDate

FROM            
	dbo.tblCCSiteDetail AS SiteDetail INNER JOIN 
	dbo.tblCCSiteHeader AS SiteHeader ON SiteDetail.intSiteHeaderId = SiteHeader.intSiteHeaderId LEFT OUTER JOIN 
	dbo.vyuCCSite AS Site ON Site.intSiteId = SiteDetail.intSiteId LEFT OUTER JOIN 
	dbo.vyuCCVendor AS Vendor ON Vendor.intVendorDefaultId = SiteHeader.intVendorDefaultId

GROUP BY  
	  SiteHeader.strCcdReference
	, SiteHeader.dtmDate
	, Site.intCustomerId
	, Site.strCustomerName
	, SiteDetail.intSiteHeaderId
	, Vendor.strName