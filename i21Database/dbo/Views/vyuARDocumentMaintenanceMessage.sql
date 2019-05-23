CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessage]
AS 
SELECT intDocumentMaintenanceId			= A.intDocumentMaintenanceId
     , strCode							= A.strCode
	 , strTitle							= A.strTitle
	 , intCompanyLocationId				= A.intCompanyLocationId
	 , intLineOfBusinessId				= A.intLineOfBusinessId
	 , intEntityCustomerId				= A.intEntityCustomerId
	 , strSource						= A.strSource
	 , strType							= A.strType
	 , ysnCopyAll						= A.ysnCopyAll
	 , intDocumentMaintenanceMessageId	= HEADER.intDocumentMaintenanceMessageId
	 , strHeaderFooter					= HEADER.strHeaderFooter
	 , intCharacterLimit				= HEADER.intCharacterLimit
	 , strMessage						= REPLACE(REPLACE(REPLACE(dbo.fnEliminateHTMLTags(CAST(HEADER.blbMessage AS VARCHAR(MAX)), 0), '<p>', ''), '</p>',''), '&nbsp;', ' ') COLLATE Latin1_General_CI_AS
	 , strMessageHtml					= CAST(HEADER.blbMessage AS VARCHAR(MAX))
	 , strMessageFooter					= REPLACE(REPLACE(REPLACE(dbo.fnEliminateHTMLTags(CAST(FOOTER.blbMessage AS VARCHAR(MAX)), 0), '<p>', ''), '</p>',''), '&nbsp;', ' ') COLLATE Latin1_General_CI_AS
	 , strMessageHtmlFooter				= CAST(FOOTER.blbMessage AS VARCHAR(MAX))
	 , ysnRecipe						= HEADER.ysnRecipe 
	 , ysnQuote							= HEADER.ysnQuote
	 , ysnSalesOrder					= HEADER.ysnSalesOrder
	 , ysnPickList						= HEADER.ysnPickList
	 , ysnBOL							= HEADER.ysnBOL
	 , ysnInvoice						= HEADER.ysnInvoice
	 , ysnScaleTicket					= HEADER.ysnScaleTicket
	 , strCustomerNumber				= C.strCustomerNumber
	 , strLocationName					= CL.strLocationName
FROM (
	SELECT intDocumentMaintenanceId
		 , intEntityCustomerId
		 , intCompanyLocationId
		 , strCode
		 , strTitle
		 , intLineOfBusinessId
		 , strSource
		 , strType
		 , ysnCopyAll 
	FROM dbo.tblSMDocumentMaintenance WITH (NOLOCK)
) A 
OUTER APPLY (
	SELECT TOP 1 intDocumentMaintenanceId
			   , blbMessage
			   , intDocumentMaintenanceMessageId
			   , strHeaderFooter
			   , intCharacterLimit
			   , ysnRecipe
			   , ysnQuote
			   , ysnSalesOrder
			   , ysnPickList
			   , ysnBOL
			   , ysnInvoice
			   , ysnScaleTicket 
	FROM dbo.tblSMDocumentMaintenanceMessage HDM WITH (NOLOCK)
	WHERE A.intDocumentMaintenanceId = HDM.intDocumentMaintenanceId
	  AND HDM.strHeaderFooter = 'Header'
) HEADER
OUTER APPLY (
	SELECT TOP 1 blbMessage
	FROM dbo.tblSMDocumentMaintenanceMessage HDM WITH (NOLOCK)
	WHERE A.intDocumentMaintenanceId = HDM.intDocumentMaintenanceId
	  AND HDM.strHeaderFooter = 'Footer'
) FOOTER
LEFT JOIN (
	SELECT intEntityId
		 , strCustomerNumber 
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON A.intEntityCustomerId = C.intEntityId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON A.intCompanyLocationId = CL.intCompanyLocationId
