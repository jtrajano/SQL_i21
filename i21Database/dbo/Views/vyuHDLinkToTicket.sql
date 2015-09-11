CREATE VIEW [dbo].[vyuHDLinkToTicket]
	AS 
	select
		intLinkToTicketId=tblHDTicket.intTicketId
		,strLinkToTicketNumber=tblHDTicket.strTicketNumber
		,strLinkToTicketSubject=tblHDTicket.strSubject
		,strLinkToTicketAssignee=tblEntity.strName
		,strLinkToTicketStatus=tblHDTicketStatus.strStatus
		,tblHDTicket.intCustomerId
		,tblHDTicketStatus.strBackColor
		,tblHDTicketStatus.strFontColor
		,tblHDTicketStatus.strIcon
	from
		tblHDTicket
		,tblEntity
		,tblHDTicketStatus
	where
		tblEntity.intEntityId = tblHDTicket.intAssignedToEntity
		and tblHDTicketStatus.intTicketStatusId = tblHDTicket.intTicketStatusId
