﻿CREATE VIEW [dbo].[vyuSMDocument]
AS

WITH FolderHeirarchy AS (
  SELECT 
	intDocumentSourceFolderId,  
	A.intDocumentTypeId,
	CAST(strName AS VARCHAR(MAX)) AS strFolderPath
  FROM tblSMDocumentSourceFolder A
  WHERE intDocumentFolderParentId IS NULL

  UNION ALL

  SELECT 
	B.intDocumentSourceFolderId, 
	B.intDocumentTypeId,
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
	(CASE WHEN D.strName IS NULL THEN A.strInterCompanyEntityName ELSE D.strName END) AS strUserName,
	A.intTransactionId,
	intUploadId,
	B.strFolderPath AS strFolderPath,
	B.intDocumentSourceFolderId,
	C.intRecordId,
	E.strNamespace,
	C.strTransactionNo,
	E.strScreenName,
	E.intScreenId,
	A.intConcurrencyId,
	F.strName AS strDocumentType
FROM tblSMDocument A 
	INNER JOIN FolderHeirarchy B ON A.intDocumentSourceFolderId = B.intDocumentSourceFolderId
	INNER JOIN tblSMTransaction C ON A.intTransactionId = C.intTransactionId
	INNER JOIN tblEMEntity D ON A.intEntityId = D.intEntityId
	INNER JOIN tblSMScreen E ON C.intScreenId = E.intScreenId
	LEFT JOIN tblSMDocumentType F ON F.intDocumentTypeId = B.intDocumentTypeId