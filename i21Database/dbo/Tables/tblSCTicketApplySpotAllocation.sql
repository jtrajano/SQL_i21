CREATE TABLE [dbo].[tblSCTicketApplySpotAllocation]
(
	intTicketApplySpotAllocationId INT NOT NULL PRIMARY KEY IDENTITY(1,1),	  
	intTicketApplyTicketId INT NOT NULL,
	intTicketApplySpotId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,

	intConcurrencyId INT NOT NULL DEFAULT(1),

	CONSTRAINT [FK_TicketApplySpotAllocation_TicketApplyTicket_TicketApplyId]
		FOREIGN KEY (intTicketApplyTicketId)
		REFERENCES dbo.tblSCTicketApplyTicket(intTicketApplyTicketId),

	CONSTRAINT [FK_TicketApplySpotAllocation_TicketApplySpot_TicketSpotId]
		FOREIGN KEY (intTicketApplySpotId)
		REFERENCES dbo.tblSCTicketApplySpot(intTicketApplySpotId),
)
