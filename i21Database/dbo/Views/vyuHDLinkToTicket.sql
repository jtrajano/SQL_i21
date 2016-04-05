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
	from
		tblHDTicket
		,tblEMEntity
		,tblHDTicketStatus
	where
		tblEMEntity.intEntityId = tblHDTicket.intAssignedToEntity
		and tblHDTicketStatus.intTicketStatusId = tblHDTicket.intTicketStatusId
