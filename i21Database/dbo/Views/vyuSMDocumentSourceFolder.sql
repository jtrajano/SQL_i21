CREATE VIEW [dbo].vyuSMDocumentSourceFolder
AS

SELECT
	intDocumentSourceFolderId,
	intScreenId,
	A.strName,
	intSort,
	A.intDocumentTypeId,
	A.intConcurrencyId,
	intDocumentFolderParentId,
	C.strName AS strDocumentType,
	leaf = CAST(CASE WHEN (SELECT COUNT(*) FROM tblSMDocumentSourceFolder B WHERE B.intDocumentFolderParentId = A.intDocumentSourceFolderId) = 0 THEN 1 ELSE 0 END AS BIT) 
FROM tblSMDocumentSourceFolder A LEFT JOIN tblSMDocumentType C ON A.intDocumentTypeId = C.intDocumentTypeId

	
