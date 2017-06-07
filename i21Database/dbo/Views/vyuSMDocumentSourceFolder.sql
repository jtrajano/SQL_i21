﻿CREATE VIEW [dbo].vyuSMDocumentSourceFolder
AS

SELECT
	intDocumentSourceFolderId,
	intScreenId,
	strName,
	intSort,
	intDocumentTypeId,
	intConcurrencyId,
	intDocumentFolderParentId,
	strDocumentType = (SELECT TOP 1 strName FROM tblSMDocumentType D WHERE D.intDocumentTypeId = A.intDocumentTypeId),
	leaf = CAST(CASE WHEN (SELECT COUNT(*) FROM tblSMDocumentSourceFolder B WHERE B.intDocumentFolderParentId = A.intDocumentSourceFolderId) = 0 THEN 1 ELSE 0 END AS BIT) 
from tblSMDocumentSourceFolder A