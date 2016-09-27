CREATE TABLE [dbo].[tblFRAuditLog] (
    [intAuditLog]			INT			IDENTITY (1, 1) NOT NULL,
    [intReportId]			INT			NOT NULL,
    [intRowId]				INT			NOT NULL,
	[intColumnId]			INT			NOT NULL,    
    [dtmBeginProcess]		DATETIME	NULL,
    [dtmValidation]			DATETIME	NULL,
	[dtmDataGathering]		DATETIME	NULL,
	[dtmGLAmountsSQL]		DATETIME	NULL,
	[dtmTotalCalculation]	DATETIME	NULL,
	[dtmCreateControls]		DATETIME	NULL,
	[dtmEndProcess]			DATETIME	NULL,    
    [intTotalCells]			INT			NULL,
	[strBuildNumber]		NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]		INT			DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRAuditLog] PRIMARY KEY CLUSTERED ([intAuditLog] ASC)
);
