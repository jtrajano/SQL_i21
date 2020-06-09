CREATE TABLE [dbo].[tblSMDataEventLog] (
	[intDataEventLogId]			INT					IDENTITY (1, 1) NOT NULL,
    [intLogId]					INT					NOT NULL,
    [strAction]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strActionType]				NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strActiveNamespace]		NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strUrl]					NVARCHAR(MAX)		COLLATE Latin1_General_CI_AS NULL,
	[strRequestData]			NVARCHAR(MAX)		COLLATE Latin1_General_CI_AS NULL,
	[strResponseData]			NVARCHAR(MAX)		COLLATE Latin1_General_CI_AS NULL,
    [dtmActionDate]				DATETIME			NOT NULL,
    [intConcurrencyId]			INT					NOT NULL,

    CONSTRAINT [PK_dbo.tblSMDataEventLog] PRIMARY KEY CLUSTERED ([intDataEventLogId] ASC),
	CONSTRAINT [FK_dbo.tblSMDataEventLog_dbo.tblSMLog_intLogId] FOREIGN KEY ([intLogId]) REFERENCES [dbo].tblSMLog ([intLogId]) ON DELETE CASCADE,
);
