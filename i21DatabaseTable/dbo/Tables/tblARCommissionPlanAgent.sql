CREATE TABLE [dbo].[tblARCommissionPlanAgent]
(
	[intCommissionPlanAgentId]		INT NOT NULL IDENTITY,
	[intCommissionPlanId]			INT NOT NULL,
	[intEntityAgentId]				INT NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionPlanAgent_intCommissionPlanAgentId] PRIMARY KEY CLUSTERED ([intCommissionPlanAgentId] ASC),
	CONSTRAINT [FK_tblARCommissionPlanAgent_tblARCommissionPlan_intCommissionPlanId] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan] ([intCommissionPlanId]),
	CONSTRAINT [FK_tblARCommissionPlanAgent_tblEMEntity_intEntityAgentId] FOREIGN KEY ([intEntityAgentId]) REFERENCES [tblEMEntity] ([intEntityId]) ON DELETE CASCADE
)
