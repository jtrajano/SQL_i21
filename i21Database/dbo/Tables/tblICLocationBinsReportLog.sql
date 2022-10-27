CREATE TABLE dbo.tblICLocationBinsReportLog (
	[intLogId] INT NOT NULL IDENTITY(1,1),
	[dtmLastRun] DATETIME NULL,
	[ysnRebuilding] BIT NULL DEFAULT(0), 
	[dtmStart] DATETIME NULL,
	[dtmEnd] DATETIME NULL,	
	[intEntityUserSecurityId] INT NULL,
    CONSTRAINT [PK_tblICLocationBinsReportLog] PRIMARY KEY CLUSTERED ([intLogId])
)
GO
