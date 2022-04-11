CREATE TABLE [dbo].[tblQMCuppingSession]
(
	[intCuppingSessionId] INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)),
    [strCuppingSessionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmCuppingDateTime] DATETIME NOT NULL,

	CONSTRAINT [PK_tblQMCuppingSession] PRIMARY KEY ([intCuppingSessionId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMCuppingSession_strCuppingSessionNumber] ON [dbo].[tblQMCuppingSession](strCuppingSessionNumber)
GO