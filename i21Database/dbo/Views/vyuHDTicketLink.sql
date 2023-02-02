CREATE VIEW [dbo].[vyuHDTicketLink]
AS 
	SELECT   intTicketLinkId		= TicketLink.intTicketLinkId
			,intTicketId			= TicketLink.intTicketId
			,intLinkToTicketId		= TicketLink.intLinkToTicketId
			,intTicketLinkTypeId	= TicketLink.intTicketLinkTypeId
			,strTicketNumber		= Ticket.strTicketNumber
			,strLinkToTicketNumber  = LinkToTicket.strTicketNumber
			,strLinkTicketType      = TicketLinkType.strLinkType
			,strTicketSubject       = LinkToTicket.strSubject
			,strTicketStatus        = TicketStatus.strStatus
			,strTicketBackColor     = TicketStatus.strBackColor
			,strTicketFontColor     = TicketStatus.strFontColor
			,strTicketAssignee		= TicketAssignee.strName
	FROM tblHDTicketLink TicketLink
		INNER JOIN tblHDTicket Ticket 
	ON Ticket.intTicketId = TicketLink.intTicketId
		INNER JOIN tblHDTicket LinkToTicket 
	ON LinkToTicket.intTicketId = TicketLink.intLinkToTicketId
		INNER JOIN tblHDTicketLinkType TicketLinkType
	ON TicketLinkType.intTicketLinkTypeId = TicketLink.intTicketLinkTypeId
		LEFT JOIN tblHDTicketStatus TicketStatus 
	ON TicketStatus.intTicketStatusId = LinkToTicket.intTicketStatusId
		LEFT JOIN tblEMEntity TicketAssignee 
	ON TicketAssignee.intEntityId = LinkToTicket.intAssignedToEntity
GO
