CREATE VIEW [dbo].[vyuApiDocumentMaintenanceMessages]
AS

SELECT
      m.intDocumentMaintenanceId
    , m.intDocumentMaintenanceMessageId
    , m.strHeaderFooter
    , strMessage = REPLACE(REPLACE(REPLACE(dbo.fnEliminateHTMLTags(CAST(m.blbMessage AS VARCHAR(MAX)), 0), '<p>', ''), '</p>',''), '&nbsp;', ' ') COLLATE Latin1_General_CI_AS
FROM tblSMDocumentMaintenanceMessage m