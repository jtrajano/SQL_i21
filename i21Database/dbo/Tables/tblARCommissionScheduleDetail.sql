CREATE TABLE [dbo].[tblARCommissionScheduleDetail]
(
	[intCommissionScheduleDetailId]	INT NOT NULL IDENTITY,
	[intCommissionScheduleId]       INT NOT NULL,
    [intEntityId]					INT NULL, 
	[intCommissionId]				INT NULL, 
    [ysnAdjustPrevious]				BIT NULL, 
    [intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionScheduleDetail_intCommissionScheduleDetailId] PRIMARY KEY CLUSTERED ([intCommissionScheduleDetailId] ASC),
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblARCommissionSchedule] FOREIGN KEY ([intCommissionScheduleId]) REFERENCES [tblARCommissionSchedule] ([intCommissionScheduleId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]),
	CONSTRAINT [FK_tblARCommissionScheduleDetail_tblARCommissionPlan] FOREIGN KEY ([intCommissionId]) REFERENCES [tblARCommissionPlan]([intCommissionId]) ON DELETE CASCADE 
)
