CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessage]
AS 
SELECT A.intDocumentMaintenanceId
     , A.strCode
	 , A.strTitle
	 , A.intCompanyLocationId
	 , A.intLineOfBusinessId
	 , A.intEntityCustomerId
	 , A.strSource
	 , A.strType
	 , A.ysnCopyAll
	 , B.intDocumentMaintenanceMessageId
	 , B.strHeaderFooter
	 , B.intCharacterLimit
	 , strMessage								= REPLACE(REPLACE(REPLACE(CONVERT(VarChar(max), B.blbMessage), '<p>', ''), '</p>',''), '&nbsp;', ' ')	 
	 , B.ysnRecipe
	 , B.ysnQuote
	 , B.ysnSalesOrder
	 , B.ysnPickList
	 , B.ysnBOL
	 , B.ysnInvoice
	 , B.ysnScaleTicket 
	 , C.strCustomerNumber
	 , CL.strLocationName
FROM
	(SELECT intDocumentMaintenanceId, intEntityCustomerId, intCompanyLocationId, strCode, strTitle, intLineOfBusinessId, strSource, strType, ysnCopyAll 
	 FROM tblSMDocumentMaintenance) A 
INNER JOIN 
	(SELECT intDocumentMaintenanceId, blbMessage, intDocumentMaintenanceMessageId, strHeaderFooter, intCharacterLimit, ysnRecipe, ysnQuote, ysnSalesOrder, ysnPickList, ysnBOL, 
		ysnInvoice, ysnScaleTicket 
	 FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
LEFT JOIN 
	(SELECT intEntityCustomerId, strCustomerNumber FROM vyuARCustomer) C ON A.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN 
	(SELECT intCompanyLocationId, strLocationName FROM tblSMCompanyLocation) CL ON A.intCompanyLocationId = CL.intCompanyLocationId