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
		,strLastUpdated = CONVERT(VARCHAR(10),a.dtmLastUpdated,101) COLLATE Latin1_General_CI_AS
	from
		tblHDProjectAuditLog a
		inner join tblEMEntity b on b.intEntityId = a.intLastUpdatedByEnityId
		inner join tblHDTicket c on c.intTicketId = a.intLinkId
		inner join tblHDProject d on d.intProjectId = a.intProjectId
	
