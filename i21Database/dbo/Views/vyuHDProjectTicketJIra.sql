CREATE VIEW [dbo].[vyuHDProjectTicketJIra]
	AS
	select
		intId = convert(int,ROW_NUMBER() over (order by c.intTicketId))
		,a.intProjectId
		,a.strProjectName
		,c.intTicketId
		,c.strTicketNumber
		,strKey = CASE WHEN ISNULL(d.strJiraKey, '') = ''
							THEN d.strKey
						ELSE d.strJiraKey
				  END
		,strTypeIconUrl				= d.strJiraTypeIconUrl
		,d.strSummary
		,strOriginalEstimate
		,d.strReporter
		,d.strAssignee
		,d.strFixedBy
		,strPriorityIconUrl			= d.strJiraPriorityIconUrl
		,strStatusIconUrl			= d.strJiraStatusIconUrl
		,d.dtmJiraCreated
		,d.dtmJiraUpdated
		,d.strFixedVersion
		,a.intConcurrencyId
		,intOriginalProjectId = a1.intProjectId
		,strOriginalProjectName = a1.strProjectName
		,strJiraPriority			= d.strJiraPriority
		,strJiraStatus				= d.strJiraStatus
		,strJiraType				= d.strJiraType
	from 
		tblHDProject a
		inner join tblHDProjectTask b on b.intProjectId = a.intProjectId
		inner join tblHDTicket c on c.intTicketId = b.intTicketId
		inner join tblHDTicketJIRAIssue d on d.intTicketId = c.intTicketId
		inner join tblHDProjectTask b1 on b1.intTicketId = c.intTicketId
		inner join tblHDProject a1 on a1.intProjectId = b1.intProjectId
	where (b.intProjectId = a.intProjectId or b.intProjectId in (select aa.intDetailProjectId from  tblHDProjectDetail aa where aa.intProjectId = a.intProjectId))
GO
