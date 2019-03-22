CREATE TABLE [dbo].[tblARCommissionPlanSalesperson]
(
	[intCommissionPlanSalespersonId]	INT NOT NULL IDENTITY,
	[intCommissionPlanId]				INT NOT NULL,
	[intEntitySalespersonId]			INT NULL,
	[intConcurrencyId]					INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionPlanSalesperson_intCommissionPlanSalespersonId] PRIMARY KEY CLUSTERED ([intCommissionPlanSalespersonId] ASC),
	CONSTRAINT [FK_tblARCommissionPlanSalesperson_tblARCommissionPlan_intCommissionPlanId] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan] ([intCommissionPlanId]),
	CONSTRAINT [FK_tblARCommissionPlanSalesperson_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [tblARSalesperson] ([intEntityId]) ON DELETE CASCADE
)
