CREATE TABLE [dbo].[tblSCTicketApplyLoadAllocation]
(
	intTicketApplyLoadAllocationId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyTicketId INT NOT NULL,
	intTicketApplyLoadId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,

	intConcurrencyId INT NOT NULL DEFAULT(1),

	CONSTRAINT [FK_TicketApplyLoadAllocation_TicketApplyTicket_TicketApplyId]
		FOREIGN KEY (intTicketApplyTicketId)
		REFERENCES dbo.tblSCTicketApplyTicket(intTicketApplyTicketId),

	CONSTRAINT [FK_TicketApplyLoadAllocation_TicketApplyLoad_TicketApplyLoadId]
		FOREIGN KEY (intTicketApplyLoadId)
		REFERENCES dbo.tblSCTicketApplyLoad(intTicketApplyLoadId),
)
