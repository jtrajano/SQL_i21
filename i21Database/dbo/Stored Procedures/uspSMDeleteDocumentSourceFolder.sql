CREATE PROCEDURE [dbo].[uspSMDeleteDocumentSourceFolder]
	@FolderId int
AS
WITH relatedfolders as
(
	SELECT e1.intDocumentSourceFolderId as intDocumentSourceFolderId--, 0 as lvl
	FROM tblSMDocumentSourceFolder e1
	WHERE e1.intDocumentSourceFolderId = @FolderId
	UNION ALL
	SELECT e2.intDocumentSourceFolderId as intDocumentSourceFolderId--, lvl+1
	FROM tblSMDocumentSourceFolder e2  
	INNER JOIN relatedfolders g ON e2.intDocumentFolderParentId = g.intDocumentSourceFolderId
)
DELETE FROM tblSMDocumentSourceFolder 
WHERE intDocumentSourceFolderId IN (SELECT intDocumentSourceFolderId FROM relatedfolders)
