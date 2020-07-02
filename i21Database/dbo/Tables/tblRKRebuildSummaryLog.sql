CREATE TABLE [dbo].[tblRKRebuildSummaryLog]
(
	[intRebuildSummaryLogId] INT NOT NULL IDENTITY, 
    [dtmRebuildDate] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [intUserId] INT NOT NULL, 
	[ysnSuccess] BIT NULL DEFAULT((0)),
	[strErrorMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKRebuildSummaryLog] PRIMARY KEY ([intRebuildSummaryLogId])
)
