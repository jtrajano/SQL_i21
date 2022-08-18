CREATE TABLE [dbo].[tblHDTimeEntryPeriodDetailDay]
(
	[intTimeEntryPeriodDetailDaysId]		INT IDENTITY(1,1) NOT NULL,
	[intTimeEntryPeriodDetailId]			INT			   NOT NULL,
	[strDaysDisplay]						NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmBillingPeriodStart]					DATETIME NOT NULL,
	[dtmBillingPeriodEnd]					DATETIME NOT NULL,
	[intConcurrencyId] [int]				NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryPeriodDetailDay_intTimeEntryPeriodDetailDaysId] PRIMARY KEY CLUSTERED ([intTimeEntryPeriodDetailDaysId] ASC),
	CONSTRAINT [FK_tblHDTimeEntryPeriodDetailDay_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [dbo].[tblHDTimeEntryPeriodDetail] ([intTimeEntryPeriodDetailId]) ON DELETE CASCADE,
    CONSTRAINT [UQ_tblHDTimeEntryPeriodDetailDay_intTimeEntryPeriodDetailId_strDaysDisplay] UNIQUE ([intTimeEntryPeriodDetailId],[strDaysDisplay])
)

GO