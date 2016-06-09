CREATE TABLE [dbo].[tblIPLog]
(
	[intLogId] INT NOT NULL IDENTITY, 
    [intProcessId] INT NOT NULL, 
    [intStepId] INT NULL, 
    [strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDate] DATETIME NULL, 
    [strUserName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblIPLog_intLogId] PRIMARY KEY ([intLogId]), 
	CONSTRAINT [FK_tblIPLog_tblIPProcess_intProcessId] FOREIGN KEY ([intProcessId]) REFERENCES [tblIPProcess]([intProcessId]) ON DELETE CASCADE,
)
