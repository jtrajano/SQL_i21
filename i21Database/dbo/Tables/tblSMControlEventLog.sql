CREATE TABLE [dbo].[tblSMControlEventLog] (
	[intControlEventLogId]		INT					IDENTITY (1, 1) NOT NULL,
    [intLogId]					INT					NOT NULL,
    [strItemId]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strControlType]			NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strEventSource]			NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strAction]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strParentScreen]			NVARCHAR(500)		COLLATE Latin1_General_CI_AS NULL,
    [dtmActionDate]				DATETIME			NOT NULL,
    [intConcurrencyId]			INT					NOT NULL,

    CONSTRAINT [PK_dbo.tblSMControlEventLog] PRIMARY KEY CLUSTERED ([intControlEventLogId] ASC),
	CONSTRAINT [FK_dbo.tblSMControlEventLog_dbo.tblSMLog_intLogId] FOREIGN KEY ([intLogId]) REFERENCES [dbo].tblSMLog ([intLogId]) ON DELETE CASCADE,
);
