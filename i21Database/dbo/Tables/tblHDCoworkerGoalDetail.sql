﻿CREATE TABLE [dbo].[tblHDCoworkerGoalDetail]
(
	[intCoworkerGoalDetailId]	 INT IDENTITY(1,1) NOT NULL,
	[intCoworkerGoalId]			 INT			   NOT NULL,
	[intBillingPeriod]			 INT			   NOT NULL,
	[strBillingPeriodName]		 NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblBudget]					 NUMERIC(18, 6) NULL DEFAULT 0,
	[intUtilization]			 INT			   NULL,
	[intTimeEntryPeriodDetailId] INT			   NULL,
	[ysnActive]					 BIT	 NOT NULL	CONSTRAINT [DF_tblHDCoworkerGoalDetail_ysnActive] DEFAULT ((1)),
	[intConcurrencyId] [int]	NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDCoworkerGoalDetail_intCoworkerGoalDetailId] PRIMARY KEY CLUSTERED ([intCoworkerGoalDetailId] ASC),
	CONSTRAINT [FK_tblHDCoworkerGoalDetail_tblHDCoworkerGoal_intCoworkerGoalId] FOREIGN KEY ([intCoworkerGoalId]) REFERENCES [dbo].[tblHDCoworkerGoal] ([intCoworkerGoalId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblHDCoworkerGoalDetail_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [dbo].[tblHDTimeEntryPeriodDetail] ([intTimeEntryPeriodDetailId]),
    CONSTRAINT [UQ_tblHDCoworkerGoalDetail_intCoworkerGoalId_intBillingPeriod] UNIQUE ([intCoworkerGoalId],[intBillingPeriod])
)

GO