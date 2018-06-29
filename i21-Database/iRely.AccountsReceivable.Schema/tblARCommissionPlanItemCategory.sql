CREATE TABLE [dbo].[tblARCommissionPlanItemCategory]
(
	[intCommissionPlanItemCategoryId]	INT NOT NULL IDENTITY,
	[intCommissionPlanId]				INT NOT NULL,
	[intItemCategoryId]					INT NULL,
	[intConcurrencyId]					INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionPlanItemCategory_intCommissionPlanItemCategoryId] PRIMARY KEY CLUSTERED ([intCommissionPlanItemCategoryId] ASC),
	CONSTRAINT [FK_tblARCommissionPlanItemCategory_tblARCommissionPlan_intCommissionPlanId] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan] ([intCommissionPlanId]),
	CONSTRAINT [FK_tblARCommissionPlanItemCategory_tblICCategory_intItemId] FOREIGN KEY ([intItemCategoryId]) REFERENCES [tblICCategory] ([intCategoryId]) ON DELETE CASCADE
)
