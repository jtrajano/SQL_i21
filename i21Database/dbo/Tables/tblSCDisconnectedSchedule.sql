CREATE TABLE [dbo].[tblSCDisconnectedSchedule]
(
	[intScheduleId]				INT IDENTITY (1, 1) NOT NULL,
	[strFrequency]				[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
    [intDay]					[int] NULL,
	[intDayOfMonth]				[int] NULL,
	[dtmRunTime]				DATETIME NULL,
	[intEntityId]				INT NULL,
	[intConcurrencyId]			[int] DEFAULT 1,
	CONSTRAINT [PK_tblSCDisconnectedSchedule] PRIMARY KEY CLUSTERED ([intScheduleId] ASC),
	
)

