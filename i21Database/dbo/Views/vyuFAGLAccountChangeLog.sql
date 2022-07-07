CREATE VIEW [dbo].[vyuFAGLAccountChangeLog]
AS
SELECT
	A.*
	,[strAssetId] = B.strAssetId
	,[strUser] = E.strName
FROM [dbo].[tblFAGLAccountChangeLog] A
INNER JOIN [dbo].[tblFAFixedAsset] B
	ON B.intAssetId = A.intAssetId
LEFT JOIN tblEMEntity E
	ON E.intEntityId = A.intEntityId