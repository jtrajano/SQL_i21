CREATE VIEW [dbo].[vyuARBillableHoursForImport]
AS
SELECT intEntityId				= C.[intEntityId]
	 , strCustomerNumber		= C.[strCustomerNumber]
	 , strName					= E.[strName]
	 , intTicketId				= T.[intTicketId]
	 , strTicketNumber			= T.[strTicketNumber]
	 , intTicketHoursWorkedId	= HW.[intTicketHoursWorkedId]
	 , intAgentEntityId			= HW.[intAgentEntityId]
	 , strAgentName				= U.[strName]
	 , dtmBilled				= GETDATE()
	 , dtmDate					= HW.[dtmDate]
	 , intInvoiceId				= HW.[intInvoiceId] 
	 , intJobCodeId				= JC.[intJobCodeId]
	 , strJobCode				= JC.[strJobCode]
	 , intCompanyLocationId		= ISNULL(EML.[intWarehouseId], CL.intCompanyLocationId)
	 , intItemId				= JC.[intItemId]
	 , intItemUOMId				= JC.[intItemUOMId] 
	 , strItemNo				= IC.[strItemNo]
	 , intHours					= HW.[intHours]
	 , dblPrice					= HW.[dblRate]
	 , dblTotal					= HW.[intHours] * HW.[dblRate]
	 , intEntityWarehouseId		=  EML.[intWarehouseId]
FROM
	tblHDJobCode JC
INNER JOIN 
	tblICItem IC
		ON JC.[intItemId] = IC.[intItemId]	
INNER JOIN
	tblHDTicketHoursWorked HW
		ON JC.[intJobCodeId] = HW.[intJobCodeId]
		AND HW.[ysnBillable] = 1
		AND HW.[ysnBilled] = 0
		AND (HW.[intInvoiceId] IS NULL OR HW.[intInvoiceId] = 0)
INNER JOIN
	tblHDTicket T
		ON HW.[intTicketId] = T.[intTicketId]
INNER JOIN
	tblARCustomer C
		ON T.[intCustomerId] = C.[intEntityId]
INNER JOIN
	tblEMEntity E
		ON C.[intEntityId] = E.[intEntityId]	
LEFT JOIN
	tblEMEntityLocation EML
		ON E.[intEntityId] = EML.[intEntityId]
		AND EML.[ysnDefaultLocation] = 1
INNER JOIN
	tblEMEntity U
		ON HW.[intAgentEntityId] = U.[intEntityId]
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationId 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	WHERE ysnLocationActive = 1
) CL