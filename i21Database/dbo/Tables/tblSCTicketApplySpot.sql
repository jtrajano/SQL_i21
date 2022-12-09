CREATE TABLE [dbo].[tblSCTicketApplySpot]
(
	intTicketApplySpotId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intTicketApplyId INT NOT NULL,	
	dblUnit NUMERIC(38, 20) NULL,
	dblBasis DECIMAL(18, 6) NOT NULL DEFAULT 0,
	dblFutures DECIMAL(18, 6) NOT NULL DEFAULT 0,
	intConcurrencyId INT NOT NULL DEFAULT(1),


	CONSTRAINT [FK_TicketApplySpot_TicketApply_TicketApplyId] 
		FOREIGN KEY (intTicketApplyId) 
		REFERENCES dbo.tblSCTicketApply(intTicketApplyId),
)
