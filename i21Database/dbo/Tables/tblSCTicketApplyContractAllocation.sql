CREATE TABLE [dbo].[tblSCTicketApplyContractAllocation]
(
	intTicketApplyContractAllocationId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyTicketId INT NOT NULL,
	intTicketApplyContractId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,

	intConcurrencyId INT NOT NULL DEFAULT(1),

	CONSTRAINT [FK_TicketApplyContractAllocation_TicketApplyTicket_TicketApplyId]
		FOREIGN KEY (intTicketApplyTicketId)
		REFERENCES dbo.tblSCTicketApplyTicket(intTicketApplyTicketId),

	CONSTRAINT [FK_TicketApplyContractAllocation_TicketApplyContract_TicketApplyContractId]
		FOREIGN KEY (intTicketApplyContractId)
		REFERENCES dbo.tblSCTicketApplyContract(intTicketApplyContractId)  ON DELETE CASCADE,

)
