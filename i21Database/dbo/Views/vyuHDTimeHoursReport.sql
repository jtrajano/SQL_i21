CREATE VIEW [dbo].[vyuHDTimeHoursReport]
	AS
		
		select
			a.intTicketHoursWorkedId
			,intTicketId = convert(nvarchar(20),b.intTicketId) COLLATE Latin1_General_CI_AS
			,b.strTicketNumber
			,b.strSubject
			,intProjectId = convert(nvarchar(20),d.intProjectId) COLLATE Latin1_General_CI_AS
			,d.strProjectName
			,intCustomerId = f.intEntityId
			,strCustomerName = f.strName
			,k.strModule
			,a.dtmDate
			,intAgentEntityId = g.intEntityId
			,strAgentName = g.strName
			,a.intHours
			,a.dblEstimatedHours
			,dblHours = (case when h.strServiceType = 'Expense' then 0.00 else a.intHours end)
			,intBilledAmount = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else (case when h.strServiceType = 'Expense' then 0.00 else a.intHours end) end) * a.dblRate
			,intBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else (case when h.strServiceType = 'Expense' then 0.00 else a.intHours end) end)
			,intNonBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then (case when h.strServiceType <> 'Expense' then 0.00 else a.intHours end) else 0 end)
			,intJobCodeId = h.intItemId
			,strJobCode = h.strItemNo
			,a.dblRate
			,a.ysnBillable
			,a.strDescription
			,e.intInvoiceId
			,e.strInvoiceNumber
			,e.dblAmountDue
			,e.dblPayment
			,intInternalProjectManager = i.intEntityId
			,strInternalProjectManager = i.strName
			,l.intVersionId
			,l.strVersionNo
			,m.intTicketTypeId
			,m.strType
			,n.intTicketStatusId
			,n.strStatus
			,o.intMilestoneId
			,o.strMileStone
			,strDepartment = dbo.fnEMGetEmployeeDepartment(g.intEntityId) COLLATE Latin1_General_CI_AS
			,a.strJIRALink
		from
			tblHDTicketHoursWorked a
			join tblHDTicket b on b.intTicketId = a.intTicketId
			left join tblHDProjectTask c on c.intTicketId = b.intTicketId
			left join tblHDProject d on d.intProjectId = c.intProjectId
			left join tblARInvoice e on e.intInvoiceId = a.intInvoiceId
			left join tblEMEntity f on f.intEntityId = b.intCustomerId
			left join tblEMEntity g on g.intEntityId = a.intAgentEntityId
			left join tblICItem h on h.intItemId = a.intItemId
			left join tblEMEntity i on i.intEntityId = d.intInternalProjectManager
			left join tblHDModule j on j.intModuleId = b.intModuleId
			left join tblSMModule k on k.intModuleId = j.intSMModuleId
			left join tblHDVersion l on l.intVersionId = b.intVersionId
			left join tblHDTicketType m on m.intTicketTypeId = b.intTicketTypeId
			left join tblHDTicketStatus n on n.intTicketStatusId = b.intTicketStatusId
			left join tblHDMilestone o on o.intMilestoneId = b.intMilestoneId
		where a.intAgentEntityId is not null and a.intAgentEntityId > 0

		union all

		select
			intTicketHoursWorkedId = convert(int,ROW_NUMBER() over (order by a.intPREntityEmployeeId asc))
			,intTicketId = 0
			,strTicketNumber = null
			,strSubject = null
			,intProjectId = null
			,strProjectName = null
			,intCustomerId = 0
			,strCustomerName = null
			,strModule = null
			,dtmDate = a.dtmPRDate
			,intAgentEntityId = a.intPREntityEmployeeId
			,strAgentName = d.strName
			,intHours = a.dblPRRequest
			,dblEstimatedHours = a.dblPRRequest
			,dblHours = a.dblPRRequest
			,intBilledAmount = 0
			,intBillableHours = 0
			,intNonBillableHours = 0
			,intJobCodeId = null
			,strJobCode = null
			,dblRate = 0.00
			,ysnBillable = convert(bit,0)
			,strDescription = c.strTimeOff + ' (' + c.strDescription + ')'
			,intInvoiceId = null
			,strInvoiceNumber = null
			,dblAmountDue = null
			,dblPayment = null
			,intInternalProjectManager = null
			,strInternalProjectManager = null
			,intVersionId = null
			,strVersionNo = null
			,intTicketTypeId = null
			,strType = null
			,intTicketStatusId = null
			,strStatus = null
			,intMilestoneId = null
			,strMileStone = null
			,strDepartment = dbo.fnEMGetEmployeeDepartment(a.intPREntityEmployeeId) COLLATE Latin1_General_CI_AS
			,strJIRALink = null
		from
			tblHDTimeOffRequest a
			inner join tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
			inner join tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
			inner join tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
			inner join tblSMTransaction e on 1=1
		where
			(e.intScreenId = (select intScreenId from tblSMScreen where strNamespace = 'Payroll.view.TimeOffRequest') 
				 and e.intRecordId = a.intPRTimeOffRequestId 
				 and (e.strApprovalStatus = 'Approved' or e.strApprovalStatus = 'Approved with Modification'))
