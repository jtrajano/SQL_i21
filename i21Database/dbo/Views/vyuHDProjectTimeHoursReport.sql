CREATE VIEW [dbo].[vyuHDProjectTimeHoursReport]
	AS
		select
					intProjectId
					,strProjectName
					,intCustomerId
					,strCustomerName
					,intHours = sum(intHours)
					,intBillableHours = sum(intBillableHours)
					,intNonBillableHours = sum(intNonBillableHours)
					,dblAmountDue = isnull(sum(dblAmountDue),0)
					,dblPayment = isnull(sum(dblPayment),0)
					,intInternalProjectManager
					,strInternalProjectManager
		from
		(
				select
					a.intTicketHoursWorkedId
					,b.intTicketId
					,b.strTicketNumber
					,b.strSubject
					,d.intProjectId
					,d.strProjectName
					,intCustomerId = f.intEntityId
					,strCustomerName = f.strName
					,a.dtmDate
					,intAgentEntityId = g.intEntityId
					,strAgentName = g.strName
					,a.intHours
					,intBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else a.intHours end)
					,intNonBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then a.intHours else 0 end)
					,h.intJobCodeId
					,h.strJobCode
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
					join tblHDProjectTask c on c.intTicketId = b.intTicketId
					join tblHDProject d on d.intProjectId = c.intProjectId
					left join tblARInvoice e on e.intInvoiceId = a.intInvoiceId
					left join tblEMEntity f on f.intEntityId = d.intCustomerId
					left join tblEMEntity g on g.intEntityId = a.intAgentEntityId
					left join tblHDJobCode h on h.intJobCodeId = a.intJobCodeId
					left join tblEMEntity i on i.intEntityId = d.intInternalProjectManager
		) as result
		group by
					intProjectId
					,strProjectName
					,intCustomerId
					,strCustomerName
					,intInternalProjectManager
					,strInternalProjectManager
