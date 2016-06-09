CREATE TABLE [dbo].[tblARCommissionSchedule]
(
	[intCommissionScheduleId]	INT NOT NULL IDENTITY, 
    [strCommissionScheduleName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strCommissionScheduleDesc] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [strReviewPeriod]			NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strScheduleType]			NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strEntityIds]				NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [dtmStartDate]				DATETIME NULL, 
	[dtmEndDate]				DATETIME NULL, 	
	[intCommissionPlanId]		INT NULL,
    [ysnActive]					BIT NULL, 
    [ysnPayables]				BIT NULL, 
    [ysnPayroll]				BIT NULL, 
    [ysnAdjustPrevious]			BIT NULL, 
    [intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionSchedule_intCommissionScheduleId] PRIMARY KEY CLUSTERED ([intCommissionScheduleId] ASC),
	CONSTRAINT [UK_tblARCommissionSchedule_strCommissionScheduleName] UNIQUE (strCommissionScheduleName)
)
