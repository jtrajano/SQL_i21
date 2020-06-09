CREATE TABLE [dbo].[tblSMMessageLog] (
	[intMessageLogId]			INT					IDENTITY (1, 1) NOT NULL,
    [intLogId]					INT					NOT NULL,
    [strMessage]				NVARCHAR(MAX)		COLLATE Latin1_General_CI_AS NULL,
	[strIconType]				NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strAction]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strCallbackButton]			NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
    [dtmActionDate]				DATETIME			NOT NULL,
    [intConcurrencyId]			INT					NOT NULL,

    CONSTRAINT [PK_dbo.tblSMMessageLog] PRIMARY KEY CLUSTERED ([intMessageLogId] ASC),
	CONSTRAINT [FK_dbo.tblSMMessageLog_dbo.tblSMLog_intLogId] FOREIGN KEY ([intLogId]) REFERENCES [dbo].tblSMLog ([intLogId]) ON DELETE CASCADE,
);
