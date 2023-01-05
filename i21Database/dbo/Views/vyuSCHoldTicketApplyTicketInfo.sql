CREATE VIEW [dbo].[vyuSCHoldTicketApplyTicketInfo]
	AS 


SELECT 
	
	TICKET_APPLY.intTicketApplyTicketId
	, TICKET_APPLY.intTicketApplyId
	
	, TICKET_VIEW.intTicketId
	, TICKET_VIEW.strTicketStatus
	, TICKET_VIEW.strTicketStatusDescription
	, TICKET_VIEW.strTicketNumber
	, TICKET_VIEW.dtmTicketDateTime
	, TICKET_VIEW.strReceiptNumber
	

FROM tblSCTicketApplyTicket TICKET_APPLY
	JOIN vyuSCTicketView TICKET_VIEW
		ON TICKET_APPLY.intTicketId = TICKET_VIEW.intTicketId



