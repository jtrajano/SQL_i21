CREATE VIEW [dbo].[vyuCCNotification]
AS
SELECT ccSiteHeader.intSiteHeaderId,
	   ccVendor.strName AS strCompanyName,
	   ccVendor.strAddress AS strCompanyAddress,
       ccSiteDetail.intSiteDetailId,
       ccCustomer.intCustomerId,
       ccCustomer.strCustomerName,
       ccCustomer.strCustomerEntityNo,
       ccSite.strSite,
       ccSite.strSiteDescription,
       ccSiteHeader.dtmDate,
       ccSiteHeader.strCcdReference,
       ccSiteDetail.dblGross,
       ccSiteDetail.dblFees,
       ccSiteDetail.dblNet,
       ccSiteBatchDetail.strBatch,
       ccSiteBatchDetail.dblGross AS dblBatchGross,
       ccSiteBatchDetail.dblFees AS dblBatchFees,
       ccSiteBatchDetail.dblNet AS dblBatchNet
FROM dbo.tblCCSiteHeader AS ccSiteHeader
	INNER JOIN dbo.vyuCCVendor AS ccVendor 
		ON ccVendor.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	INNER JOIN dbo.tblCCSiteDetail AS ccSiteDetail
		ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
	LEFT OUTER JOIN dbo.tblCCSiteBatchDetail AS ccSiteBatchDetail
		ON ccSiteBatchDetail.intSiteDetailId = ccSiteDetail.intSiteDetailId
	LEFT OUTER JOIN dbo.vyuCCSite AS ccSite
		ON ccSite.intSiteId = ccSiteDetail.intSiteId
	LEFT OUTER JOIN dbo.vyuCCCustomer AS ccCustomer
       ON ccCustomer.intCustomerId = ccSite.intCustomerId;

GO
