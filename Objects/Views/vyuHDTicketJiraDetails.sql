CREATE VIEW [dbo].[vyuHDTicketJiraDetails]
	AS
		select
			intId = ROW_NUMBER() over (order by strKey)
			,b.intTicketId
			,b.strTicketNumber
			,b.strSubject
			,strCustomerName = e.strName
			,b.intCustomerId
			,b.dtmCreated
			,strPriotity = f.strPriority
			,b.intTicketPriorityId
			,i.strStatus
			,b.intTicketStatusId
			,strModule = g.strModule
			,b.intModuleId
			,strAssignedTo = h.strName
			,b.intAssignedToEntity
			,d.strKey
			,d.intJiraKeyId
			,d.strJiraKey
			,d.strJiraUrl
			,d.strTypeIconUrl
			,d.strSummary
			,d.strDescription
			,d.strReporter
			,d.strAssignee
			,d.strFixedBy
			,d.strPriorityIconUrl
			,d.strStatusIconUrl
			,d.strResolution
			,d.dtmJiraCreated
			,d.dtmJiraUpdated
			,d.strFixedVersion
			,d.strOriginalEstimate
			,d.intOriginalEstimateSeconds
		from
			tblHDTicket b
			inner join tblHDTicketJIRAIssue d on d.intTicketId = b.intTicketId
			left join tblEMEntity e on e.intEntityId = b.intCustomerId
			left join tblHDTicketPriority f on f.intTicketPriorityId = b.intTicketPriorityId
			left join tblHDModule g on g.intModuleId = b.intModuleId
			left join tblEMEntity h on h.intEntityId = b.intAssignedToEntity
			left join tblHDTicketStatus i on i.intTicketStatusId = b.intTicketStatusId
		where
			b.strType <> 'CRM'
