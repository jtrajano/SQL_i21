CREATE VIEW [dbo].[vyuHDProjectMilstoneSummary]
	AS
		with ticketStatus as (
		select
			a.intProjectId
			,c.intTicketId
			,d.intTicketStatusId
			,d.strStatus
			,e.intPriority
		from
			tblHDProject a
			,tblHDProjectTask b
			,tblHDTicket c
			,tblHDTicketStatus d
			,tblHDMilestone e
		where
			b.intProjectId = a.intProjectId
			and c.intTicketId = b.intTicketId
			and d.intTicketStatusId = c.intTicketStatusId
			and e.intMilestoneId = c.intMilestoneId
		)

		select
			d.intProjectId
			,a.intMilestoneId
			,a.intPriority
			,a.strMileStone
			,a.strDescription
			,intOpenTickets = (select count(*) from ticketStatus e where e.intProjectId = d.intProjectId and e.intPriority = a.intPriority and e.strStatus <> 'Closed')
			,intCompletedTickets = (select count(*) from ticketStatus e where e.intProjectId = d.intProjectId and e.intPriority = a.intPriority and e.strStatus = 'Closed')
			,intTotalTickets = (select count(*) from ticketStatus e where e.intProjectId = d.intProjectId and e.intPriority = a.intPriority)
			,dblPercentComplete = ((select convert(numeric(18,6),count(*)) from ticketStatus e where e.intProjectId = d.intProjectId and e.intPriority = a.intPriority and e.strStatus = 'Closed')/(select convert(numeric(18,6),count(*)) from ticketStatus e where e.intProjectId = d.intProjectId and e.intPriority = a.intPriority)) * 100.00
			,dblQuotedHours = isnull(sum(b.dblQuotedHours),0.00)
			,dblActualHours = isnull(sum(b.dblActualHours),0.00)
			,dblOverShort = isnull(sum(b.dblActualHours),0.00) - isnull(sum(b.dblQuotedHours),0.00)
		from
			tblHDMilestone a
			join tblHDTicket b on b.intMilestoneId = a.intMilestoneId
			join tblHDProjectTask c on c.intTicketId = b.intTicketId
			join tblHDProject d on d.intProjectId = c.intProjectId
		group by
			d.intProjectId
			,a.intMilestoneId
			,a.intPriority
			,a.strMileStone
			,a.strDescription