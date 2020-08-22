CREATE TABLE dbo.tblICInventoryValuationSummaryLog (
	[intLogId] INT NOT NULL IDENTITY(1,1),
	[strPeriod] VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmLastRun] DATETIME NULL,
	[ysnRebuilding] BIT NULL DEFAULT(0), 
	[dtmStart] DATETIME NULL,
	[dtmEnd] DATETIME NULL,	
	[intEntityUserSecurityId] INT NULL,
    CONSTRAINT [PK_tblICInventoryValuationSummaryLog] PRIMARY KEY CLUSTERED ([intLogId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryValuationSummaryLog]
	ON [dbo].[tblICInventoryValuationSummaryLog]([strPeriod] ASC)
GO
