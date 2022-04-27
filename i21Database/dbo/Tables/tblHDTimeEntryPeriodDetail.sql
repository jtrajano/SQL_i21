CREATE TABLE [dbo].[tblHDTimeEntryPeriodDetail]
(
	[intTimeEntryPeriodDetailId]		INT IDENTITY(1,1) NOT NULL,
	[intTimeEntryPeriodId]		INT			   NOT NULL,
	[intBillingPeriod]			INT			   NOT NULL,
	[strBillingPeriodName]		NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmBillingPeriodStart]		DATETIME NOT NULL,
	[dtmBillingPeriodEnd]		DATETIME NOT NULL,
	[dtmFirstWarningDate]		DATETIME NULL,
	[dtmSecondWarningDate]		DATETIME NULL,
	[dtmLockoutDate]			DATETIME NULL,
	[strBillingPeriodStatus]	NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intRequiredHours]			INT			    NULL,
	[intConcurrencyId] [int]	NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] PRIMARY KEY CLUSTERED ([intTimeEntryPeriodDetailId] ASC),
	CONSTRAINT [FK_tblHDTimeEntryPeriodDetail_tblHDTimeEntryPeriod_intTimeEntryPeriodId] FOREIGN KEY ([intTimeEntryPeriodId]) REFERENCES [dbo].[tblHDTimeEntryPeriod] ([intTimeEntryPeriodId]) ON DELETE CASCADE,
    CONSTRAINT [UQ_tblHDTimeEntryPeriodDetail_intBillingPeriod] UNIQUE ([intBillingPeriod])
)

GO