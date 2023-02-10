CREATE VIEW [dbo].[vyuHDJiraRollUp]
	AS
		select
			intId = ROW_NUMBER() over (order by strKey)
			,intProjectId
			,intCustomerId
			,strProjectName
			,dtmCreated
			,dtmGoLive
			,intTicketId
			,strTicketNumber
			,strKey
			,intJiraKeyId
			,strJiraKey
			,strJiraUrl
			,strTypeIconUrl				= strJiraTypeIconUrl
			,strSummary
			,strDescription
			,strReporter
			,strAssignee
			,strFixedBy
			,strPriorityIconUrl			= strJiraPriorityIconUrl
			,strStatusIconUrl			= strJiraStatusIconUrl
			,strResolution
			,dtmJiraCreated
			,dtmJiraUpdated
			,strFixedVersion
			,strJiraPriority			= strJiraPriority
			,strJiraStatus				= strJiraStatus
			,strJiraType				= strJiraType
		from
		(
			select distinct
				a.intProjectId
				,a.intCustomerId
				,a.strProjectName
				,a.dtmCreated
				,a.dtmGoLive
				,b.intTicketId
				,b.strTicketNumber
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
				,d.strJiraPriorityIconUrl
				,d.strJiraStatusIconUrl
				,d.strJiraTypeIconUrl
				,d.strJiraPriority
				,d.strJiraStatus
				,d.strJiraType
			from
				tblHDProject a
				inner join tblHDTicket b on 1=1
				inner join tblHDProjectTask c on c.intProjectId = a.intProjectId
				inner join tblHDTicketJIRAIssue d on d.intTicketId = c.intTicketId
			where
				b.intTicketId = c.intTicketId
		) as result
GO
