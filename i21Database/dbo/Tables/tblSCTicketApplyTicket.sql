CREATE TABLE [dbo].[tblSCTicketApplyTicket]
(
	intTicketApplyTicketId INT NOT NULL PRIMARY KEY IDENTITY(1,1),	  
	intTicketApplyId INT NOT NULL,
	intTicketId INT NOT NULL,	
	dblUnit NUMERIC(38, 20) NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1),

	CONSTRAINT [FK_TicketApplyTicket_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId) ON DELETE CASCADE,

	CONSTRAINT FK_TicketApplyTicket_Ticket_TicketId
		FOREIGN KEY (intTicketId)
		REFERENCES dbo.tblSCTicket(intTicketId)	  ON DELETE CASCADE
)
