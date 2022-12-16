CREATE TABLE [dbo].[tblSCTicketApplyStorage]
(
	intTicketApplyStorageId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyId INT NOT NULL,	
	intStorageScheduleId INT NOT NULL,	
	dblUnit NUMERIC(38, 20) NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1),


	CONSTRAINT [FK_TicketApplyStorage_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId) ON DELETE CASCADE,
)
