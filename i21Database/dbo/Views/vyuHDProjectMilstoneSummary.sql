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
		),
		actualHours as (
			select a.intMilestoneId, d.intProjectId, dblActualHours = sum(isnull(c.intHours, 0.00))
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
			,dblActualHours = isnull((select actualHours.dblActualHours from actualHours where actualHours.intMilestoneId = a.intMilestoneId and actualHours.intProjectId = d.intProjectId), 0.00)
			,dblOverShort = isnull((select estimatedHours.dblEstimatedHours from estimatedHours where estimatedHours.intMilestoneId = a.intMilestoneId and estimatedHours.intProjectId = d.intProjectId), 0.00) - isnull((select actualHours.dblActualHours from actualHours where actualHours.intMilestoneId = a.intMilestoneId and actualHours.intProjectId = d.intProjectId), 0.00)
			,dtmStartDate				= ProjectTicketStartDate.dtmStartDate
			,dtmDueDate					= ProjectTicketDueDate.dtmDueDate
			,dtmCompleted				= CASE WHEN ProjectTicketStatus.intTicketStatusId IS NOT NULL	
													THEN NULL
											   ELSE ProjectTicketCompletedDate.dtmCompleted
										  END
		    ,strStatus					= CASE WHEN ProjectTicketStatus.intTicketStatusId IS NOT NULL	
													THEN 'Open'
											   ELSE 'Closed'
										  END
		from
			tblHDMilestone a
			join tblHDTicket b on b.intMilestoneId = a.intMilestoneId
			join tblHDProjectTask c on c.intTicketId = b.intTicketId
			join tblHDProject d on d.intProjectId = c.intProjectId
			OUTER APPLY(

				SELECT	   TOP 1 dtmStartDate = ProjectTickets.dtmStartDate
				FROM tblHDProjectTask ProjectTask
						INNER JOIN tblHDTicket ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = d.intProjectId AND
					  ProjectTickets.intMilestoneId = a.intMilestoneId AND
				  ProjectTickets.dtmStartDate IS NOT NULL
				ORDER BY ProjectTickets.dtmStartDate

			) ProjectTicketStartDate
			OUTER APPLY(

				SELECT	   TOP 1 dtmDueDate = ProjectTickets.dtmDueDate
				FROM tblHDProjectTask ProjectTask
						INNER JOIN tblHDTicket ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = d.intProjectId AND
					  ProjectTickets.intMilestoneId = a.intMilestoneId AND
				      ProjectTickets.dtmDueDate IS NOT NULL	
				ORDER BY ProjectTickets.dtmDueDate DESC

			) ProjectTicketDueDate
			OUTER APPLY(

				SELECT	   TOP 1 dtmCompleted = ProjectTickets.dtmCompleted
				FROM tblHDProjectTask ProjectTask
						INNER JOIN tblHDTicket ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = d.intProjectId AND
					  ProjectTickets.intMilestoneId = a.intMilestoneId AND 
					  ProjectTickets.dtmCompleted IS NOT NULL
				ORDER BY ProjectTickets.dtmCompleted DESC

			) ProjectTicketCompletedDate
			OUTER APPLY(

				SELECT	   TOP 1 intTicketStatusId = ProjectTickets.intTicketStatusId
				FROM tblHDProjectTask ProjectTask
						INNER JOIN tblHDTicket ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = d.intProjectId AND
					  ProjectTickets.intMilestoneId = a.intMilestoneId AND
					  ProjectTickets.intTicketStatusId <> 2	
					  				
			) ProjectTicketStatus
		group by
			d.intProjectId
			,a.intMilestoneId
			,a.intPriority
			,a.strMileStone
			,a.strDescription
			,ProjectTicketStartDate.dtmStartDate
			,ProjectTicketDueDate.dtmDueDate
			,ProjectTicketStatus.intTicketStatusId
			,ProjectTicketCompletedDate.dtmCompleted

GO