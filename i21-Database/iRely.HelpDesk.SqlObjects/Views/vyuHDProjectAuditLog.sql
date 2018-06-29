CREATE VIEW [dbo].[vyuHDProjectAuditLog]
	AS
	select
		b.strName
		,c.strTicketNumber
		,c.strSubject
		,d.strProjectName
		,a.strDescription
		,a.dtmLastUpdated
		,a.intSort
		,a.intProjectId
		,intTicketId = a.intLinkId
		,a.intProjectAuditLogId
		,strLastUpdated = CONVERT(VARCHAR(10),a.dtmLastUpdated,101)
	from
		tblHDProjectAuditLog a
		,tblEMEntity b
		,tblHDTicket c
		,tblHDProject d
	where
		b.intEntityId = a.intLastUpdatedByEnityId
		and c.intTicketId = a.intLinkId
		and d.intProjectId = a.intProjectId
