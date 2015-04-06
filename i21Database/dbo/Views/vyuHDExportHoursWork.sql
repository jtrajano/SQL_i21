CREATE VIEW [dbo].[vyuHDExportHoursWork]
	AS
			select
			dtmDate = hw.dtmDate
			,strJIRAIssue = hw.strJIRALink
			,strCompanyId = t.strCustomerNumber
			,strCompanyName = e.strName
			,strName = ec.strName
			,strJobCode = jc.strJobCode
			,intHoursWorked = hw.intHours
			,dblRate = hw.dblRate
			,dblTotalCost = hw.intHours * hw.dblRate
			,strBillable = case hw.ysnBillable when 1 then 'Billable' else 'Non-billable' end
			,strDescription = hw.strDescription
			,strSource = 'Help Desk'
			,strAgent = us.strFullName
			,strUserName = us.strUserName
			,strTicketNumber = t.strTicketNumber
			,intId = hw.intTicketHoursWorkedId
			,strSummary = t.strSubject
		from
			tblHDTicketHoursWorked hw
			inner join tblHDTicket t on t.intTicketId = hw.intTicketId
			left outer join tblARCustomer c on c.strCustomerNumber = t.strCustomerNumber
			left outer join tblEntity e on e.intEntityId = c.[intEntityCustomerId]
			left outer join tblEntity ec on ec.intEntityId = t.intCustomerContactId
			left outer join tblHDJobCode jc on jc.intJobCodeId = hw.intJobCodeId
			left outer join tblSMUserSecurity us on us.intUserSecurityID = hw.intAgentId
		where (case when hw.ysnBilled is null then 0 else hw.ysnBilled end) <> 1
