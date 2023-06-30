CREATE TABLE [dbo].[tblSCTicketAutoScaleLog]
(
	intTicketAutoScaleLogId INT IDENTITY(1,1) PRIMARY KEY NOT NULL

	, intTicketId			INT NOT NULL 
	, dblUnit				NUMERIC(18, 6) NULL
	, intContractDetailId	INT 	


	, ysnHeader BIT DEFAULT(0)

	, CONSTRAINT FK_TicketAutoScaleLog_Ticket FOREIGN KEY (intTicketId) REFERENCES dbo.tblSCTicket(intTicketId) ON DELETE CASCADE
)
