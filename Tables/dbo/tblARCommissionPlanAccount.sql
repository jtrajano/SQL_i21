CREATE TABLE [dbo].[tblARCommissionPlanAccount]
(
	[intCommissionPlanAccountId]		INT NOT NULL IDENTITY,
	[intCommissionPlanId]				INT NOT NULL,
	[intAccountId]						INT NULL,
	[intConcurrencyId]					INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionPlanAccount_intCommissionPlanAccountId] PRIMARY KEY CLUSTERED ([intCommissionPlanAccountId] ASC),
	CONSTRAINT [FK_tblARCommissionPlanAccount_tblARCommissionPlan_intCommissionPlanId] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan] ([intCommissionPlanId]),
	CONSTRAINT [FK_tblARCommissionPlanAccount_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount] ([intAccountId]) ON DELETE CASCADE
)
