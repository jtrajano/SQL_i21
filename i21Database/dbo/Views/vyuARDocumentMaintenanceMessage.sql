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
	 , strMessage								= CONVERT(VarChar(max), B.blbMessage)
	 , B.ysnRecipe
	 , B.ysnQuote
	 , B.ysnSalesOrder
	 , B.ysnPickList
	 , B.ysnBOL
	 , B.ysnInvoice
	 , B.ysnScaleTicket 
	 , C.strCustomerNumber
	 , CL.strLocationName
FROM tblSMDocumentMaintenance A 
INNER JOIN tblSMDocumentMaintenanceMessage B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
LEFT JOIN vyuARCustomer C ON A.intEntityCustomerId = C.[intEntityId]
LEFT JOIN tblSMCompanyLocation CL ON A.intCompanyLocationId = CL.intCompanyLocationId