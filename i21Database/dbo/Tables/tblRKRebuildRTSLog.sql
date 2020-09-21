CREATE TABLE [dbo].[tblRKRebuildRTSLog]
(
	[intRebuildRTSLogId] INT NOT NULL IDENTITY, 
    [dtmCreateDateTime] DATETIME NULL DEFAULT (GETDATE()), 
    [strLogMessage] NVARCHAR(MAX) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblRKRebuildRTSLog] PRIMARY KEY ([intRebuildRTSLogId]) 
)
