CREATE TABLE [dbo].[tblSCTicketApplyLog]
(
	intTicketApplyLogId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyId INT NOT NULL,
	strLogCase1 NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	strLogCase2 NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	strLogCase3 NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	strEntityName NVARCHAR(100) NULL,
	intEntityId INT NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1),


	CONSTRAINT [FK_TicketApplyLog_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId) ON DELETE CASCADE,

)
