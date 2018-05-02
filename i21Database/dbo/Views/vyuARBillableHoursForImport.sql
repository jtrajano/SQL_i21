CREATE VIEW [dbo].[vyuARBillableHoursForImport]
	AS 
SELECT
	C.[intEntityId]
	,C.[strCustomerNumber]
	,E.[strName]
	,T.[intTicketId]
	,T.[strTicketNumber]
	--,T.[strSubject]
	,strSubject = HW.[strDescription]
	,HW.[intTicketHoursWorkedId]
	,HW.[intAgentEntityId]
	,U.[strName]						AS "strAgentName"
	,GETDATE()							AS	"dtmBilled"
	,HW.[dtmDate]
	,HW.[intInvoiceId] 
	,intJobCodeId = IC.intItemId
	,strJobCode = IC.strItemNo
	,ISNULL(EML.[intWarehouseId], (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1))
										AS "intCompanyLocationId"
	,HW.[intItemId]
	,HW.[intItemUOMId] 
	,IC.[strItemNo]
	,HW.[intHours]
	,HW.[dblRate]						AS "dblPrice"
	,HW.[intHours] * HW.[dblRate]		AS "dblTotal"
	,HW.[intCurrencyId]					AS "intCurrencyId"
	,HW.[intCurrencyExchangeRateTypeId] AS "intCurrencyExchangeRateTypeId"
	,HW.[dblCurrencyRate]				AS "dblCurrencyExchangeRate"
	,HW.[intCurrencyId]					AS "intSubCurrencyId"
	,HW.[dblCurrencyRate]				AS "dblSubCurrencyRate"
FROM
	tblHDTicketHoursWorked HW
INNER JOIN 
	tblICItem IC
		ON HW.[intItemId] = IC.[intItemId]
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
where
	HW.[ysnBillable] = 1
		AND HW.[ysnBilled] = 0
		AND (HW.[intInvoiceId] IS NULL OR HW.[intInvoiceId] = 0)