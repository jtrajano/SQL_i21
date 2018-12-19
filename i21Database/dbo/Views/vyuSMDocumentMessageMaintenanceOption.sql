CREATE VIEW [dbo].[vyuSMDocumentMessageMaintenanceOption]
	AS 
SELECT B.intDocumentMaintenanceId, B.intDocumentMaintenanceMessageId, B.intCharacterLimit, B.strHeaderFooter, B.strMessage, REPLACE(strProcess, 'ysn', '') COLLATE Latin1_General_CI_AS AS strOptionName, B.ysnValue FROM tblSMDocumentMaintenanceMessage  
UNPIVOT
(
	 ysnValue FOR strProcess IN (ysnRecipe, ysnQuote, ysnSalesOrder, ysnPickList, ysnBOL, ysnInvoice, ysnScaleTicket)
) AS B

GO