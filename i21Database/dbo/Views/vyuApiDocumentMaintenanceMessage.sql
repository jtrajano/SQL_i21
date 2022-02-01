CREATE VIEW [dbo].[vyuApiDocumentMaintenanceMessage]
AS
SELECT
    md.intDocumentMaintenanceId
    , md.strCode
    , md.strFooter
    , md.strHeader
    , md.strTitle
    , md.strMessageHtml
    , dm.strType
    , lob.strLineOfBusiness
    , e.strName strCustomer
FROM vyuARDocumentMaintenanceMessageDetails md
JOIN tblSMDocumentMaintenance dm ON dm.intDocumentMaintenanceId = md.intDocumentMaintenanceId
LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = dm.intLineOfBusinessId
LEFT JOIN tblEMEntity e ON e.intEntityId = dm.intEntityCustomerId