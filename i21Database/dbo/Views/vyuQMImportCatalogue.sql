CREATE VIEW [dbo].[vyuQMImportCatalogue]
AS 
SELECT ImportCatalogue.*
     , QMSample.strSampleNumber
FROM tblQMImportCatalogue AS ImportCatalogue
JOIN tblQMSample AS QMSample ON ImportCatalogue.intSampleId = QMSample.intSampleId

