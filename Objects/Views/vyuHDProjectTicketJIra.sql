CREATE VIEW [dbo].[vyuHDProjectTicketJIra]
	AS
	select
		intId = convert(int,ROW_NUMBER() over (order by c.intTicketId))
		,a.intProjectId
		,a.strProjectName
		,c.intTicketId
		,c.strTicketNumber
		,d.strKey
		,d.strTypeIconUrl
		,d.strSummary
		,strOriginalEstimate
		,d.strReporter
		,d.strAssignee
		,d.strFixedBy
		,d.strPriorityIconUrl
		,d.strStatusIconUrl
		,d.dtmJiraCreated
		,d.dtmJiraUpdated
		,d.strFixedVersion
		,a.intConcurrencyId
		,intOriginalProjectId = a1.intProjectId
		,strOriginalProjectName = a1.strProjectName
	from tblHDProject a, tblHDProjectTask b, tblHDTicket c, tblHDTicketJIRAIssue d, tblHDProjectTask b1, tblHDProject a1
	where (b.intProjectId = a.intProjectId or b.intProjectId in (select aa.intDetailProjectId from  tblHDProjectDetail aa where aa.intProjectId = a.intProjectId))
	and c.intTicketId = b.intTicketId
	and d.intTicketId = c.intTicketId
	and b1.intTicketId = c.intTicketId
	and a1.intProjectId = b1.intProjectId