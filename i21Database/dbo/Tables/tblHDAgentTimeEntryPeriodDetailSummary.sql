﻿CREATE TABLE [dbo].[tblHDAgentTimeEntryPeriodDetailSummary]
(
	[intAgentTimeEntryPeriodDetailSummaryId] INT IDENTITY(1,1) NOT NULL,
	[intEntityId]							 INT NULL,
	[intTimeEntryPeriodDetailId]			 INT NULL,
	[dtmBillingPeriodStart]					 DATETIME NULL,
	[dtmBillingPeriodEnd]					 DATETIME NULL,
	[dblTotalHours]							 NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblBillableHours]						 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblNonBillableHours]					 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblBudgetedHours]						 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblVacationHolidaySick]				 NUMERIC(18, 6) NULL DEFAULT 0,
	[intUtilizationWeekly]					 INT NULL,
	[intUtilizationAnnually]				 INT NULL,
	[intUtilizationMonthly]					 INT NULL,
	[dblActualUtilizationWeekly]			 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblActualUtilizationAnnually]			 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblActualUtilizationMonthly]			 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblAnnualHurdle]						 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblAnnualBudget]						 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblActualAnnualBudget]					 NUMERIC(18, 6) NULL DEFAULT 0,
	[dblActualWeeklyBudget]					 NUMERIC(18, 6) NULL DEFAULT 0,
	[intRequiredHours]						 INT NULL,
	[intTimeEntryPeriodId]					 INT NULL,
	[strBillingPeriodName]					 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strName]								 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblWeeklyBudget]						 NUMERIC(18, 6) NULL DEFAULT 0,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDAgentTimeEntryPeriodDetailSummary_intAgentTimeEntryPeriodDetailSummaryId] PRIMARY KEY CLUSTERED ([intAgentTimeEntryPeriodDetailSummaryId] ASC),
	CONSTRAINT [UQ_tblHDAgentTimeEntryPeriodDetailSummary_intEntityId_intTimeEntryPeriodDetailId] UNIQUE ([intEntityId],[intTimeEntryPeriodDetailId]),
	CONSTRAINT [FK_tblHDAgentTimeEntryPeriodDetailSummary_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [dbo].[tblHDTimeEntryPeriodDetail] ([intTimeEntryPeriodDetailId])
)

GO