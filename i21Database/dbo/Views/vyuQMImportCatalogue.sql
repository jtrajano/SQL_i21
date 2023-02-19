CREATE VIEW [dbo].[vyuQMImportCatalogue]
AS

/* Created By: Jonathan Valenzuela
 * Created Date: 02/17/2023
 * Title: Catalogue Import Log
 * JIRA: QC-847
 * Description: Return list of Catalogue Import Log
 */
SELECT ImportCatalogue.*
     , QMSample.strSampleNumber
FROM tblQMImportCatalogue AS ImportCatalogue
LEFT JOIN tblQMSample AS QMSample ON ImportCatalogue.intSampleId = QMSample.intSampleId
GO
