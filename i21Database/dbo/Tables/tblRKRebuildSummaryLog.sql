CREATE TABLE [dbo].[tblRKRebuildSummaryLog]
(
	[intRebuildSummaryLogId] INT NOT NULL IDENTITY, 
    [dtmRebuildDate] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [intUserId] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKRebuildSummaryLog] PRIMARY KEY ([intRebuildSummaryLogId])
)
