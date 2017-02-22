CREATE VIEW [dbo].[vyuARBillableHoursForImport]
	AS 
SELECT
	C.[intEntityCustomerId]
	,C.[strCustomerNumber]
	,E.[strName]
	,T.[intTicketId]
	,T.[strTicketNumber]
	,HW.[intTicketHoursWorkedId]
	,HW.[intAgentEntityId]
	,U.[strName]					AS "strAgentName"
	,GETDATE()						AS	"dtmBilled"
	,HW.[dtmDate]
	,HW.[intInvoiceId] 
	,JC.[intJobCodeId]
	,JC.[strJobCode]
	,ISNULL(EML.[intWarehouseId], ISNULL(JC.[intCompanyLocationId], (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1)))
									AS "intCompanyLocationId"
	,JC.[intItemId]
	,JC.[intItemUOMId] 
	,IC.[strItemNo]
	,HW.[intHours]
	,HW.[dblRate]					AS "dblPrice"
	,HW.[intHours] * HW.[dblRate]	AS "dblTotal"
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
		ON T.[intCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	tblEMEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId]	
LEFT JOIN
	tblEMEntityLocation EML
		ON E.[intEntityId] = EML.[intEntityId]
		AND EML.[ysnDefaultLocation] = 1
INNER JOIN
	tblEMEntity U
		ON HW.[intAgentEntityId] = U.[intEntityId]