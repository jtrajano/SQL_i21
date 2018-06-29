CREATE VIEW [dbo].[vyuHDProjectTimeHoursReport]
	AS
		with estimatedhours as (
			select a.intProjectId,intEstimatedHours = isnull(sum(c.dblQuotedHours),0.000000) from tblHDProject a, tblHDProjectTask b, tblHDTicket c
			where b.intProjectId = a.intProjectId and c.intTicketId = b.intTicketId
			group by a.intProjectId
		),
		invoice as (
			select a.intProjectId,dblAmountDue = isnull(sum(d.dblAmountDue),0.000000),dblPayment = isnull(sum(d.dblPayment),0.000000) from tblHDProject a, tblHDProjectTask b, tblHDTicketHoursWorked c, tblARInvoice d
			where b.intProjectId = a.intProjectId and c.intTicketId = b.intTicketId and d.intInvoiceId = c.intInvoiceId
			group by a.intProjectId
		)
		select
					result.intProjectId
					,result.strProjectName
					,result.intCustomerId
					,result.strCustomerName
					,intEstimatedHours = estimatedhours.intEstimatedHours
					,intHours = sum(result.intHours)
					,intBillableHours = sum(result.intBillableHours)
					,intNonBillableHours = sum(result.intNonBillableHours)
					,dblTotalBilled = isnull(sum(result.intTotalBilled),0)
					,dblAmountDue = invoice.dblAmountDue
					,dblPayment = invoice.dblPayment
					,result.intInternalProjectManager
					,result.strInternalProjectManager
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
					,intTotalBilled = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else a.intHours end) * a.dblRate
					,intBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else a.intHours end)
					,intNonBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then a.intHours else 0 end)
					,h.intJobCodeId
					,h.strJobCode
					,a.dblRate
					,a.ysnBillable
					,a.strDescription
					,intInternalProjectManager = i.intEntityId
					,strInternalProjectManager = i.strName
				from
					tblHDTicketHoursWorked a
					join tblHDTicket b on b.intTicketId = a.intTicketId
					join tblHDProjectTask c on c.intTicketId = b.intTicketId
					join tblHDProject d on d.intProjectId = c.intProjectId
					left join tblEMEntity f on f.intEntityId = d.intCustomerId
					left join tblEMEntity g on g.intEntityId = a.intAgentEntityId
					left join tblHDJobCode h on h.intJobCodeId = a.intJobCodeId
					left join tblEMEntity i on i.intEntityId = d.intInternalProjectManager
		) as result,estimatedhours,invoice
		where
			estimatedhours.intProjectId = result.intProjectId
			and invoice.intProjectId = result.intProjectId
		group by
					result.intProjectId
					,result.strProjectName
					,result.intCustomerId
					,result.strCustomerName
					,result.intInternalProjectManager
					,result.strInternalProjectManager
					,estimatedhours.intEstimatedHours
					,invoice.dblAmountDue
					,invoice.dblPayment

/*
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
*/
