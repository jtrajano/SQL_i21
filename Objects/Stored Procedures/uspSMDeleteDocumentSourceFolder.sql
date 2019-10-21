CREATE PROCEDURE [dbo].[uspSMDeleteDocumentSourceFolder]
	@FolderIdList NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql NVARCHAR(MAX)

SET @sql ='
			WITH relatedfolders as
			(
				SELECT e1.intDocumentSourceFolderId as intDocumentSourceFolderId--, 0 as lvl
				FROM tblSMDocumentSourceFolder e1
				WHERE e1.intDocumentSourceFolderId IN (' + @FolderIdList + ')
				UNION ALL
				SELECT e2.intDocumentSourceFolderId as intDocumentSourceFolderId--, lvl+1
				FROM tblSMDocumentSourceFolder e2  
				INNER JOIN relatedfolders g ON e2.intDocumentFolderParentId = g.intDocumentSourceFolderId
			)
			DELETE FROM tblSMDocumentSourceFolder 
			WHERE intDocumentSourceFolderId IN (SELECT intDocumentSourceFolderId FROM relatedfolders)
			'

EXEC sp_executesql @sql

END
