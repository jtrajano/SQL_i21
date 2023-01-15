CREATE VIEW [dbo].[vyuHDLinkToTicket]
	AS 
	select
		intLinkToTicketId=tblHDTicket.intTicketId
		,strLinkToTicketNumber=tblHDTicket.strTicketNumber
		,strLinkToTicketSubject=tblHDTicket.strSubject
		,strLinkToTicketAssignee=tblEMEntity.strName
		,strLinkToTicketStatus=tblHDTicketStatus.strStatus
		,tblHDTicket.intCustomerId
		,tblHDTicketStatus.strBackColor
		,tblHDTicketStatus.strFontColor
		,tblHDTicketStatus.strIcon
		,tblHDTicket.strType
	from
		tblHDTicket
		inner join tblEMEntity on tblEMEntity.intEntityId = tblHDTicket.intAssignedToEntity
		inner join tblHDTicketStatus on tblHDTicketStatus.intTicketStatusId = tblHDTicket.intTicketStatusId
	where tblHDTicket.intCustomerId IS NOT NULL
GO
