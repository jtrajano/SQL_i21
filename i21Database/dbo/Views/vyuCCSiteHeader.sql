CREATE VIEW [dbo].[vyuCCSiteHeader]
WITH SCHEMABINDING
AS 
SELECT
	A.intSiteHeaderId, 
	B.strName AS strVendorName,
	A.strCcdReference,
	A.strReference,
	A.strApType,
	A.dtmDate,
	A.ysnPosted,
	A.dblGross,
	A.dblFees,
	A.dblNet
FROM dbo.tblCCSiteHeader AS A	
	INNER JOIN dbo.vyuCCVendor AS B
		ON A.intVendorDefaultId = B.intVendorDefaultId
