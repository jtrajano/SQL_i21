CREATE TABLE [dbo].[tblARCommissionScheduleDetail]
(
	[intCommissionScheduleDetailId]	INT NOT NULL IDENTITY,
	[intCommissionScheduleId]       INT NOT NULL,
    [intEntityId]					INT NULL, 
	[intCommissionPlanId]			INT NULL, 
	[intSort]						INT NULL DEFAULT ((0)),
    [dblPercentage]					NUMERIC(18, 6) NULL, 
    [intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionScheduleDetail_intCommissionScheduleDetailId] PRIMARY KEY CLUSTERED ([intCommissionScheduleDetailId] ASC),
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblARCommissionSchedule] FOREIGN KEY ([intCommissionScheduleId]) REFERENCES [tblARCommissionSchedule] ([intCommissionScheduleId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblARCommissionPlan] FOREIGN KEY ([intCommissionPlanId]) REFERENCES [tblARCommissionPlan]([intCommissionPlanId])
)
