CREATE VIEW [dbo].[vyuARBillableHoursForImport]
AS 
SELECT intEntityId					= C.[intEntityId]
	 , strCustomerNumber			= C.[strCustomerNumber]
	 , strName						= E.[strName]
	 , intTicketId					= T.[intTicketId]
	 , strTicketNumber				= T.[strTicketNumber]
	 , strSubject					= HW.[strDescription]
	 , intTicketHoursWorkedId		= HW.[intTicketHoursWorkedId]
	 , intAgentEntityId				= HW.[intAgentEntityId]
	 , strAgentName					= U.[strName]
	 , dtmBilled					= GETDATE()
	 , dtmDate						= HW.[dtmDate]
	 , intInvoiceId					= HW.[intInvoiceId]
	 , intJobCodeId					= IC.intItemId
	 , strJobCode					= IC.strItemNo
	 , intCompanyLocationId         = ISNULL(EML.[intWarehouseId], CL.intCompanyLocationId)
	 , intItemId					= HW.[intItemId]
	 , intItemUOMId					= HW.[intItemUOMId] 
	 , strItemNo					= IC.[strItemNo]
	 , intHours						= HW.[intHours]
	 , dblPrice						= HW.[dblRate]
	 , dblTotal						= HW.[intHours] * HW.[dblRate]
	 , intCurrencyId				= HW.[intCurrencyId]
	 , intCurrencyExchangeRateTypeId = HW.[intCurrencyExchangeRateTypeId]
	 , dblCurrencyExchangeRate		= CASE WHEN HW.[dblCurrencyRate] = 0 THEN 1.00 ELSE HW.[dblCurrencyRate] END
	 , intSubCurrencyId				= HW.[intCurrencyId]
	 , dblSubCurrencyRate			= HW.[dblCurrencyRate]
	 , intEntityWarehouseId			= EML.[intWarehouseId]
FROM dbo.tblHDTicketHoursWorked HW WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) IC ON HW.[intItemId] = IC.[intItemId]
INNER JOIN (
	SELECT intTicketId
		 , intCustomerId
		 , strTicketNumber
	FROM dbo.tblHDTicket WITH (NOLOCK)
) T ON HW.[intTicketId] = T.[intTicketId]
INNER JOIN (
	SELECT intEntityId
		 , strCustomerNumber
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON T.[intCustomerId] = C.[intEntityId]
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON C.[intEntityId] = E.[intEntityId]	
LEFT JOIN (
	SELECT intEntityId
		 , intWarehouseId
	FROM tblEMEntityLocation WITH (NOLOCK)
	WHERE ysnDefaultLocation = 1
) EML ON E.[intEntityId] = EML.[intEntityId]
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK) 
) U ON HW.[intAgentEntityId] = U.[intEntityId]
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationId 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	WHERE ysnLocationActive = 1
) CL
WHERE HW.[ysnBillable] = 1
  AND HW.[ysnBilled] = 0
  AND (HW.[intInvoiceId] IS NULL OR HW.[intInvoiceId] = 0)