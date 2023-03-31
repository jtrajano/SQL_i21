CREATE VIEW [dbo].[vyuQMImportTemplateColumn]
AS 
/* Created By: Jonathan Valenzuela
 * Created Date: 03/22/2023
 * Title: Import Template Column
 * JIRA: QC-1001
 * Description: Return list of Template/Renamed Column 
 */
SELECT TemplateColumn.*
     , ImportType.strName AS strImportTypeName
FROM tblQMImportTemplateColumn AS TemplateColumn
INNER JOIN tblQMImportType AS ImportType ON TemplateColumn.intImportTypeId = ImportType.intImportTypeId
WHERE TemplateColumn.ysnActive = 1;
