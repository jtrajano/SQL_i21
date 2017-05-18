CREATE VIEW [dbo].[vyuSMDocument]
AS

WITH FolderHeirarchy AS (
  SELECT 
	intDocumentSourceFolderId,  
	CAST(strName AS VARCHAR(MAX)) AS strFolderPath
  FROM tblSMDocumentSourceFolder A
  WHERE intDocumentFolderParentId IS NULL

  UNION ALL

  SELECT 
	B.intDocumentSourceFolderId, 
	CAST(strFolderPath + '\' + CAST(B.strName AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS strFolderPath
  FROM tblSMDocumentSourceFolder B
	INNER JOIN FolderHeirarchy C ON C.intDocumentSourceFolderId = B.intDocumentFolderParentId
)
SELECT 
	intDocumentId,
	A.strName,
	strType,
	dtmDateModified,
	intSize,
	A.intEntityId,
	D.strName AS strUserName,
	A.intTransactionId,
	intUploadId,
	B.strFolderPath AS strFolderPath,
	B.intDocumentSourceFolderId,
	C.intRecordId,
	E.strNamespace
FROM tblSMDocument A 
	INNER JOIN FolderHeirarchy B ON A.intDocumentSourceFolderId = B.intDocumentSourceFolderId
	INNER JOIN tblSMTransaction C ON A.intTransactionId = C.intTransactionId
	INNER JOIN tblEMEntity D ON A.intEntityId = D.intEntityId
	INNER JOIN tblSMScreen E ON C.intScreenId = E.intScreenId