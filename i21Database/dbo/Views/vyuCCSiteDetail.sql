CREATE VIEW [dbo].[vyuCCSiteDetail]
WITH SCHEMABINDING
AS 
SELECT
	A.intSiteDetailId, 
	A.intSiteHeaderId, 
	A.intSiteId,
	A.dblGross,
	A.dblFees,
	A.dblNet,
	B.strApType,
	B.strCcdReference,
	B.strReference,
	B.ysnPosted,
	C.strCustomerName,
	C.strSite,
	C.strSiteDescription,
	C.strSiteType,
	D.strLocationName,
	D.strName AS strVendorName,
	B.dtmDate
FROM dbo.tblCCSiteDetail AS A
	INNER JOIN dbo.tblCCSiteHeader AS B
		ON A.intSiteHeaderId = B.intSiteHeaderId
	LEFT JOIN dbo.vyuCCSite AS C
		ON C.intSiteId = A.intSiteId
	LEFT JOIN dbo.vyuCCVendor AS D
		ON D.intVendorDefaultId = B.intVendorDefaultId


