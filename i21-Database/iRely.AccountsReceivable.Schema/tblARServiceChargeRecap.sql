CREATE TABLE [dbo].[tblARServiceChargeRecap]
(
	[intSCRecapId]				INT IDENTITY (1, 1) NOT NULL,
	[strBatchId]				NVARCHAR(100)		COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId]		INT					NULL,
	[intServiceChargeAccountId] INT					NULL,
	[dtmServiceChargeDate]		DATETIME			NULL,
	[dblTotalAmount]			NUMERIC(18,6)		NULL,
	[intConcurrencyId]			INT DEFAULT ((0))	NOT NULL,
	CONSTRAINT [PK_tblARServiceChargeRecap] PRIMARY KEY CLUSTERED ([intSCRecapId] ASC)
)
