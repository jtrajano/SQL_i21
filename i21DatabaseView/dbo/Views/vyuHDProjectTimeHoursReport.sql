CREATE VIEW [dbo].[vyuHDProjectTimeHoursReport]
	AS
		with estimatedhours as (
			select a.intProjectId,intEstimatedHours = (select sum(isnull(ae.dblEstimatedHours,0.00)) from tblHDTicketHoursWorked ae, tblHDProjectTask b where b.intProjectId = a.intProjectId and ae.intTicketId = b.intTicketId)
			from tblHDProject a
		),
		invoice as (
			select a.intProjectId,dblAmountDue = isnull(sum(d.dblAmountDue),0.000000),dblPayment = isnull(sum(d.dblPayment),0.000000) from tblHDProject a, tblHDProjectTask b, tblHDTicketHoursWorked c, tblARInvoice d
			where b.intProjectId = a.intProjectId and c.intTicketId = b.intTicketId and d.intInvoiceId = c.intInvoiceId
			group by a.intProjectId
		)
		select
					intProjectId = convert(nvarchar(20),result.intProjectId) COLLATE Latin1_General_CI_AS
					,result.strProjectName
					,intCustomerId = result.intCustomerId
					,result.strCustomerName
					,intEstimatedHours = estimatedhours.intEstimatedHours
					,intHours = sum(result.intHours)
					,dblHours = sum(result.dblHours)
					,intBillableHours = sum(result.intBillableHours)
					,intNonBillableHours = sum(result.intNonBillableHours)
					,dblTotalBilled = isnull(sum(result.intTotalBilled),0)
					,dblAmountDue = isnull(invoice.dblAmountDue,0.00)
					,dblPayment = isnull(invoice.dblPayment,0.00)
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
					,dblHours = (case when j.strServiceType = 'Expense' then 0.00 else a.intHours end)
					,intTotalBilled = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else (case when j.strServiceType = 'Expense' then 0.00 else a.intHours end) end) * a.dblRate
					,intBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then 0 else (case when j.strServiceType = 'Expense' then 0.00 else a.intHours end) end)
					,intNonBillableHours = (case when isnull(a.ysnBillable, convert(bit,0)) = convert(bit,0) then (case when j.strServiceType <> 'Expense' then 0.00 else a.intHours end) else 0 end)
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
					left join tblICItem j on j.intItemId = a.intItemId
				where a.intAgentEntityId is not null and a.intAgentEntityId > 0
		) as result
		left join estimatedhours on estimatedhours.intProjectId = result.intProjectId
		left join invoice on invoice.intProjectId = result.intProjectId
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