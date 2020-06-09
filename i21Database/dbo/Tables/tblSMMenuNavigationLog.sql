CREATE TABLE [dbo].[tblSMMenuNavigationLog] (
	[intMenuNavigationLogId]	INT					IDENTITY (1, 1) NOT NULL,
    [intLogId]					INT					NOT NULL,
    [strAction]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strMenu]					NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strModuleMenu]				NVARCHAR(250)		COLLATE Latin1_General_CI_AS NULL,
	[strMenuData]				NVARCHAR(MAX)		COLLATE Latin1_General_CI_AS NULL,
    [dtmActionDate]				DATETIME			NOT NULL,
    [ysnPopperMenu]				BIT					NULL,
    [intConcurrencyId]			INT					NOT NULL,

    CONSTRAINT [PK_dbo.tblSMMenuNavigationLog] PRIMARY KEY CLUSTERED ([intMenuNavigationLogId] ASC),
	CONSTRAINT [FK_dbo.tblSMMenuNavigationLog_dbo.tblSMLog_intLogId] FOREIGN KEY ([intLogId]) REFERENCES [dbo].tblSMLog ([intLogId]) ON DELETE CASCADE,
);
