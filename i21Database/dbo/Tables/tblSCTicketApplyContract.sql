CREATE TABLE [dbo].[tblSCTicketApplyContract]
(
	intTicketApplyContractId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1),


	CONSTRAINT [FK_TicketApplyContract_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId),

)
