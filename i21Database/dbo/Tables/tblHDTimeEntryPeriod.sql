CREATE TABLE [dbo].[tblHDTimeEntryPeriod]
(
	[intTimeEntryPeriodId]		INT IDENTITY(1,1) NOT NULL,
    [strFiscalYear]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intFirstWarningDays]		INT			   NULL,
	[intSecondWarningDays]		INT			   NULL,
	[intLockoutDays]			INT			   NULL,
	[intConcurrencyId] [int]	NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryPeriod_intTimeEntryPeriodId] PRIMARY KEY CLUSTERED ([intTimeEntryPeriodId] ASC),
    CONSTRAINT [UQ_tblHDTimeEntryPeriod_strFiscalYear] UNIQUE ([strFiscalYear])
)

GO