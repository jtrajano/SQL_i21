CREATE TABLE [dbo].[tblSCDisconnectedSchedule]
(
	[intScheduleId]				INT IDENTITY (1, 1) NOT NULL,
	[strFrequency]				[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strType]					[nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intDay]					[int] NULL,
	[intDayOfMonth]				[int] NULL,
	[dtmRunTime]				DATETIME NULL,
	[dtmEndTime]				DATETIME NULL,
	[intTimeInterval]			INT NULL,
	[intEntityId]				INT NULL,
	[ysnMonday]					BIT NULL,
	[ysnTuesday]				BIT NULL,
	[ysnWednesday]				BIT NULL,
	[ysnThursday]				BIT NULL,
	[ysnFriday]					BIT NULL,
	[ysnSaturday]				BIT NULL,
	[ysnSunday]					BIT NULL,
	[intConcurrencyId]		    INT NULL DEFAULT (1),
	CONSTRAINT [PK_tblSCDisconnectedSchedule_intScheduleId] PRIMARY KEY CLUSTERED ([intScheduleId] ASC)
	
)

