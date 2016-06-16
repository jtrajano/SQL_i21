CREATE VIEW [dbo].[vyuCCSiteBatchDetail]
WITH SCHEMABINDING
AS 
SELECT
	A.intSiteBatchDetailId,
	A.intSiteDetailId, 
	B.intSiteHeaderId, 
	E.strName AS strVendorName,
	C.strCcdReference,
	C.strReference,
	C.strApType,
	C.dtmDate,
	E.strLocationName,
	C.ysnPosted,
	D.strSite,
	D.strSiteDescription,
	D.strSiteType,
	D.strCustomerName,
	A.strBatch,
	A.dblGross,
	A.dblFees,
	A.dblNet
FROM dbo.tblCCSiteBatchDetail A 
	INNER JOIN dbo.tblCCSiteDetail AS B
		ON A.intSiteDetailId = B.intSiteDetailId
	INNER JOIN dbo.tblCCSiteHeader AS C
		ON C.intSiteHeaderId = B.intSiteHeaderId
	LEFT JOIN dbo.vyuCCSite AS D
		ON D.intSiteId = B.intSiteId
	LEFT JOIN dbo.vyuCCVendor AS E
		ON E.intVendorDefaultId = D.intVendorDefaultId


