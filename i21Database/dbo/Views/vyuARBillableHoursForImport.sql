CREATE VIEW [dbo].[vyuARBillableHoursForImport]
	AS 
SELECT
	C.intEntityCustomerId
	,C.strCustomerNumber
	,E.strName
	,T.intTicketId
	,T.strTicketNumber
	,HW.intTicketHoursWorkedId
	,HW.intAgentEntityId
	,U.strName					AS "strAgentName"
	,GETDATE()					AS	"dtmBilled"
	,HW.dtmDate
	,JC.intJobCodeId
	,JC.strJobCode
	,JC.intItemId
	,IC.strItemNo
	,HW.intHours
	,HW.dblRate					AS "dblPrice"
	,HW.intHours * HW.dblRate	AS "dblTotal"
FROM
	tblHDJobCode JC
INNER JOIN 
	tblICItem IC
		ON JC.intItemId = IC.intItemId	
INNER JOIN
	tblHDTicketHoursWorked HW
		ON JC.intJobCodeId = HW.intJobCodeId
		AND HW.ysnBillable = 1
		AND HW.ysnBilled = 0
INNER JOIN
	tblHDTicket T
		ON HW.intTicketId = T.intTicketId
INNER JOIN
	tblARCustomer C
		ON T.intCustomerId = C.intEntityCustomerId
INNER JOIN
	tblEntity E
		ON C.intEntityCustomerId = E.intEntityId	
INNER JOIN
	tblEntity U
		ON HW.intAgentEntityId = U.intEntityId