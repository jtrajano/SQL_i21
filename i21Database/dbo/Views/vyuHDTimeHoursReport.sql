CREATE VIEW [dbo].[vyuHDTimeHoursReport]
	AS
		select
			a.intTicketHoursWorkedId
			,b.intTicketId
			,b.strTicketNumber
			,b.strSubject
			,d.intProjectId
			,d.strProjectName
			,intCustomerId = f.intEntityId
			,strCustomerName = f.strName
			,k.strModule
			,a.dtmDate
			,intAgentEntityId = g.intEntityId
			,strAgentName = g.strName
			,a.intHours
			,intBilledAmount = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else a.intHours end) * a.dblRate
			,intBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else a.intHours end)
			,intNonBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then a.intHours else 0 end)
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
