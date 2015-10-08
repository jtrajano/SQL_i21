CREATE TABLE [dbo].[tblARCommissionSchedule]
(
	[intCommissionScheduleId]	INT NOT NULL IDENTITY, 
    [strCommissionScheduleName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strCommissionScheduleDesc] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [strReviewPeriod]			NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL, 
    [dtmReviewStartDate]		DATETIME NULL, 
    [ysnActive]					BIT NULL, 
    [ysnAutoPayables]			BIT NULL, 
    [ysnAutoPayroll]			BIT NULL, 
    [ysnAutoProcess]			BIT NULL, 
    [intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionSchedule_intCommissionScheduleId] PRIMARY KEY CLUSTERED ([intCommissionScheduleId] ASC),
	CONSTRAINT [UK_tblARCommissionSchedule_strCommissionScheduleName] UNIQUE (strCommissionScheduleName)
)
