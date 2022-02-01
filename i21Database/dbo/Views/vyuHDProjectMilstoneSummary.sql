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
			inner join tblHDProjectTask b on b.intProjectId = a.intProjectId
			inner join tblHDTicket c on c.intTicketId = b.intTicketId
			inner join tblHDTicketStatus d on d.intTicketStatusId = c.intTicketStatusId
			inner join tblHDMilestone e on e.intMilestoneId = c.intMilestoneId
		),
		estimatedHours as (
			select a.intMilestoneId, d.intProjectId, dblEstimatedHours = sum(isnull(c.dblEstimatedHours, 0.00))
			from 
				tblHDMilestone a
				inner join tblHDTicket b on b.intMilestoneId = a.intMilestoneId
				inner join tblHDTicketHoursWorked c on c.intTicketId = b.intTicketId
				inner join tblHDProjectTask d on d.intTicketId = b.intTicketId
			group by a.intMilestoneId,d.intProjectId
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
			--,dblQuotedHours = isnull(sum(b.dblQuotedHours),0.00)
			,dblQuotedHours = isnull((select estimatedHours.dblEstimatedHours from estimatedHours where estimatedHours.intMilestoneId = a.intMilestoneId and estimatedHours.intProjectId = d.intProjectId), 0.00)
			,dblActualHours = isnull(sum(b.dblActualHours),0.00)
			,dblOverShort = isnull((select estimatedHours.dblEstimatedHours from estimatedHours where estimatedHours.intMilestoneId = a.intMilestoneId and estimatedHours.intProjectId = d.intProjectId), 0.00) - isnull(sum(b.dblActualHours),0.00)
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