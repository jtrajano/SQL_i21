CREATE TABLE [dbo].[tblHDCoworkerGoal]
(
	[intCoworkerGoalId]					INT IDENTITY(1,1) NOT NULL,
	[intEntityId]						INT			   NOT NULL,
    [strFiscalYear]						NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId]						INT			   NOT NULL,
	[intUtilizationTargetAnnual]		INT			   NULL,
	[intUtilizationTargetWeekly]		INT			   NULL,
	[intUtilizationTargetMonthly]		INT			   NULL,
	[dblAnnualHurdle]					NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblIncentiveRate]					NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblAnnualBudget]					NUMERIC(18, 6) NULL DEFAULT 0, 
	[intCommissionAccountId]				INT			   NULL,
	[intRevenueAccountId]				    INT			   NULL,
	[strGoal]							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int]			NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDCoworkerGoal_intCoworkerGoalId] PRIMARY KEY CLUSTERED ([intCoworkerGoalId] ASC),
	CONSTRAINT [FK_tblHDCoworkerGoal_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblHDCoworkerGoal_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
    CONSTRAINT [UQ_tblHDCoworkerGoal_intEntityId_strFiscalYear] UNIQUE ([intEntityId],[strFiscalYear]),
)

GO