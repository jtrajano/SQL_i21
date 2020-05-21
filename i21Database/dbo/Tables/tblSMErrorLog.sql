CREATE TABLE [dbo].[tblSMErrorLog]
(
	[intErrorLogId]			INT             IDENTITY (1, 1) NOT NULL,
	[intLogId]				INT				NOT NULL,
	[strActionType]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strNamespace]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[strMessage]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strRequestJsonData]	NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strResponseJsonData]	NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]				DATETIME		NOT NULL,
	[intConcurrencyId]   INT              NOT NULL

	CONSTRAINT [FK_dbo.tblSMAErrorLog_dbo.tblSMLog_intLogId] FOREIGN KEY ([intLogId]) REFERENCES [dbo].tblSMLog ([intLogId]) ON DELETE CASCADE,
    CONSTRAINT [PK_dbo.tblSMErrorLog] PRIMARY KEY CLUSTERED ([intErrorLogId] ASC)
)
