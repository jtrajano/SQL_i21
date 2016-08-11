CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessage]
AS 
SELECT A.intDocumentMaintenanceId, A.strCode, A.strTitle, A.intCompanyLocationId, A.intLineOfBusinessId, 
A.intEntityCustomerId, A.strSource, A.strType, A.ysnCopyAll,
B.intDocumentMaintenanceMessageId, B.strHeaderFooter, B.intCharacterLimit, B.strMessage, B.ysnRecipe, 
B.ysnQuote, B.ysnSalesOrder, B.ysnPickList, B.ysnBOL, B.ysnInvoice, B.ysnScaleTicket 
FROM tblSMDocumentMaintenance A 
INNER JOIN (SELECT intDocumentMaintenanceId, intDocumentMaintenanceMessageId, strHeaderFooter, intCharacterLimit, strMessage, ysnRecipe, ysnQuote, ysnSalesOrder, ysnPickList, ysnBOL, ysnInvoice,ysnScaleTicket 
			FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
