CREATE TABLE [dbo].[tblSCTicketApplyLoad]
(
	intTicketApplyLoadId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyId INT NOT NULL,
	intLoadShipmentDetailId INT NOT NULL,
	dblUnit NUMERIC(38, 20) NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1),


	CONSTRAINT [FK_TicketApplyLoad_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId),
)
