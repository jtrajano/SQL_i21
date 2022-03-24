CREATE VIEW [dbo].[vyuHDProjectTicketJIra]
	AS
	select
		intId = convert(int,ROW_NUMBER() over (order by c.intTicketId))
		,a.intProjectId
		,a.strProjectName
		,c.intTicketId
		,c.strTicketNumber
		,d.strKey
		,REPLACE(d.strTypeIconUrl, 'https:', 'http:') strTypeIconUrl
		,d.strSummary
		,strOriginalEstimate
		,d.strReporter
		,d.strAssignee
		,d.strFixedBy
		,REPLACE(d.strPriorityIconUrl, 'https:', 'http:') strPriorityIconUrl
		,REPLACE(d.strStatusIconUrl, 'https:', 'http:') strStatusIconUrl
		,d.dtmJiraCreated
		,d.dtmJiraUpdated
		,d.strFixedVersion
		,a.intConcurrencyId
		,intOriginalProjectId = a1.intProjectId
		,strOriginalProjectName = a1.strProjectName
	from 
		tblHDProject a
		inner join tblHDProjectTask b on 1=1
		inner join tblHDTicket c on c.intTicketId = b.intTicketId
		inner join tblHDTicketJIRAIssue d on d.intTicketId = c.intTicketId
		inner join tblHDProjectTask b1 on b1.intTicketId = c.intTicketId
		inner join tblHDProject a1 on a1.intProjectId = b1.intProjectId
	where (b.intProjectId = a.intProjectId or b.intProjectId in (select aa.intDetailProjectId from  tblHDProjectDetail aa where aa.intProjectId = a.intProjectId))
GO
