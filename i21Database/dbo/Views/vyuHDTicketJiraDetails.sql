CREATE VIEW [dbo].[vyuHDTicketJiraDetails]
	AS
		select
			intId = ROW_NUMBER() over (order by strKey)
			,b.intTicketId
			,b.strTicketNumber
			,b.strSubject
			,strCustomerName = (select top 1 strName from tblEMEntity where intEntityId = b.intCustomerId)
			,b.intCustomerId
			,b.dtmCreated
			,strPriotity = (select top 1 strPriority from tblHDTicketPriority where intTicketPriorityId = b.intTicketPriorityId)
			,b.intTicketPriorityId
			,strModule = (select top 1 strModule from tblHDModule where intModuleId = b.intModuleId)
			,b.intModuleId
			,strAssignedTo = (select top 1 strName from tblEMEntity where intEntityId = b.intAssignedToEntity)
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
		from
			tblHDTicket b
			,tblHDTicketJIRAIssue d
		where
			b.intTicketId = d.intTicketId
			and b.strType <> 'CRM'
