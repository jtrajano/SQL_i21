CREATE TABLE [dbo].[tblARCommissionPlan]
(
	[intCommissionId]		INT NOT NULL IDENTITY,
	[strCommissionPlanName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strEntities]           NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strBasis]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCalculationType]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strHurdleFrequency]    NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[strHurdleType]		    NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[dblHurdle]				NUMERIC(18,6) NULL,
	[dblCalculationAmount]  NUMERIC(18,6) NULL,
	[dtmStartDate]			DATETIME NULL,
	[dtmEndDate]			DATETIME NULL,
	[ysnPaymentRequired]	BIT NULL,
	[ysnActive]				BIT NULL,
	[intCommissionAccountId] INT NULL,
	[intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARCommissionPlan_intCommissionId] PRIMARY KEY CLUSTERED ([intCommissionId] ASC),
	CONSTRAINT [UK_tblARCommissionPlan_strCommissionPlanName] UNIQUE (strCommissionPlanName)
)
