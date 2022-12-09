CREATE TABLE [dbo].[tblSCTicketApplyStorageAllocation]
(
	intTicketApplyStorageAllocationId INT NOT NULL PRIMARY KEY IDENTITY(1,1),  
	intTicketApplyTicketId INT NOT NULL,
	intTicketApplyStorageId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,

	intConcurrencyId INT NOT NULL DEFAULT(1),

	CONSTRAINT [FK_TicketApplyStorageAllocation_TicketApplyTicket_TicketApplyId]
		FOREIGN KEY (intTicketApplyTicketId)
		REFERENCES dbo.tblSCTicketApplyTicket(intTicketApplyTicketId),

	CONSTRAINT [FK_TicketApplyStorageAllocation_TicketApplyStorage_TicketApplyStorageId]
		FOREIGN KEY (intTicketApplyStorageId)
		REFERENCES dbo.tblSCTicketApplyStorage(intTicketApplyStorageId),
)
