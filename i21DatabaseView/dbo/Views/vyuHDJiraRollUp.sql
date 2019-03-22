CREATE VIEW [dbo].[vyuHDJiraRollUp]
	AS
		select
			intId = ROW_NUMBER() over (order by strKey)
			,intProjectId
			,strProjectName
			,dtmCreated
			,dtmGoLive
			,intTicketId
			,strTicketNumber
			,strKey
			,intJiraKeyId
			,strJiraKey
			,strJiraUrl
			,strTypeIconUrl
			,strSummary
			,strDescription
			,strReporter
			,strAssignee
			,strFixedBy
			,strPriorityIconUrl
			,strStatusIconUrl
			,strResolution
			,dtmJiraCreated
			,dtmJiraUpdated
			,strFixedVersion
		from
		(
			select distinct
				a.intProjectId
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
			from
				tblHDProject a
				,tblHDTicket b
				,tblHDProjectTask c
				,tblHDTicketJIRAIssue d
			where
				d.intTicketId = c.intTicketId
				and c.intProjectId = a.intProjectId
				and b.intTicketId = c.intTicketId
		) as result
