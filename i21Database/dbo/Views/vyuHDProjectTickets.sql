CREATE VIEW [dbo].[vyuHDProjectTickets]
	AS
		select
			t.intTicketId
			,t.intCustomerId
			,t.strCustomerNumber
			,t.intCustomerContactId
			,t.intTicketStatusId
			,t.strTicketNumber
			,t.strSubject
			,strCustomerName = '' COLLATE Latin1_General_CI_AS
			,strContactName = conEnt.strName
			,strModule = smmo.strModule
			,strPriority = prio.strPriority
			,strAssignedTo = assEnt.strName
			,intAssignedToEntityId = t.intAssignedToEntity
			,t.dtmDueDate
			,strDueDate = CONVERT(nvarchar(30),t.dtmDueDate,22) COLLATE Latin1_General_CI_AS
			,ysnCompleted = Convert(bit,(case when t.intTicketStatusId = 2 then 1 else 0 end))
			--,dblQuotedHours = isnull(t.dblQuotedHours,0)
			,dblQuotedHours = isnull((select sum(nb.dblEstimatedHours) from tblHDTicketHoursWorked nb where nb.intTicketId = t.intTicketId),0)
			,dblActualHours = isnull((select sum(nb.intHours) from tblHDTicketHoursWorked nb where nb.intTicketId = t.intTicketId and nb.ysnBillable = convert(bit, 1)),0)
			--,dblOverShort = (isnull(t.dblQuotedHours,0)-isnull(t.dblActualHours,0))
			,dblOverShort = (isnull((select sum(nb.dblEstimatedHours) from tblHDTicketHoursWorked nb where nb.intTicketId = t.intTicketId),0)-isnull((select sum(nb.intHours) from tblHDTicketHoursWorked nb where nb.intTicketId = t.intTicketId and nb.ysnBillable = convert(bit, 1)),0))
			,strMilestone = ms.strDescription
			,ms.intPriority
			,ts.strBackColor
			,ts.strFontColor
			,ts.strIcon
			,ts.strStatus
			,strTicketType = tt.strType
			,t.intSequenceInProject
			,task.intProjectId
			,strPriorityBackColor = prio.strBackColor
			,strPriorityFontColor = prio.strFontColor
			,strPriorityIcon = prio.strIcon
			,dblNonBillableHours = isnull((select sum(nb.intHours) from tblHDTicketHoursWorked nb where nb.intTicketId = t.intTicketId and nb.ysnBillable = convert(bit, 0)),0)
			,strResolutionTrainingManualLink	= t.strResolutionTrainingManualLink
			,strResolutionTrainingAgendaLink	= t.strResolutionTrainingAgendaLink
			,strResolutionSOPLink				= t.strResolutionSOPLink
			,dtmStartDate						= t.dtmStartDate
			,dtmCompleted						= t.dtmCompleted
			,strNote							= t.strNote
			,strCompletedDate = CONVERT(nvarchar(10),t.dtmCompleted,101) COLLATE Latin1_General_CI_AS
			,strStartDate = CONVERT(nvarchar(10),t.dtmStartDate,101) COLLATE Latin1_General_CI_AS
			,intTemplateTicketId = task.intTemplateTicketId
			,strTemplateTicketNumber = TemplateTicket.strTicketNumber
		from
			tblHDTicket t
			/*
			left outer join tblARCustomer cus on cus.intCustomerId = t.intCustomerId
			left outer join tblEMEntity cusEnt on cusEnt.intEntityId = cus.intEntityId
			*/
			left outer join tblEMEntity conEnt on conEnt.intEntityId = t.intCustomerContactId
			left outer join tblHDModule m on m.intModuleId = t.intModuleId
			inner join tblSMModule smmo on smmo.intModuleId = m.intSMModuleId 
			left outer join tblEMEntity assEnt on assEnt.intEntityId = t.intAssignedToEntity
			left outer join tblHDMilestone ms on ms.intMilestoneId = t.intMilestoneId
			left outer join tblHDTicketStatus ts on ts.intTicketStatusId = t.intTicketStatusId
			left outer join tblHDTicketType tt on tt.intTicketTypeId = t.intTicketTypeId
			left outer join tblHDProjectTask task on task.intTicketId = t.intTicketId
			left outer join tblHDTicketPriority prio on prio.intTicketPriorityId = t.intTicketPriorityId
			left join tblHDTicket TemplateTicket on TemplateTicket.intTicketId = task.intTemplateTicketId 
		where t.intTicketTypeId not in (select top 1 intTicketTypeId from tblHDTicketType where strType = 'Template')
GO

