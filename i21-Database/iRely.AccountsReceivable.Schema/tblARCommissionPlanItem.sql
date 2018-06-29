CREATE TABLE [dbo].[tblARCommissionPlanItem]
(
	[intCommissionPlanItemId]		INT NOT NULL IDENTITY,
	[intCommissionPlanId]			INT NOT NULL,
	[intItemId]						INT NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionPlanItem_intCommissionPlanItemId] PRIMARY KEY CLUSTERED ([intCommissionPlanItemId] ASC),
	CONSTRAINT [FK_tblARCommissionPlanItem_tblARCommissionPlan_intCommissionPlanId] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan] ([intCommissionPlanId]),
	CONSTRAINT [FK_tblARCommissionPlanItem_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem] ([intItemId]) ON DELETE CASCADE
)
