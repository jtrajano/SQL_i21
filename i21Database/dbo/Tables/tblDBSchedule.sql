CREATE TABLE [dbo].[tblDBSchedule]
(
	[intScheduleId]				INT NOT NULL PRIMARY KEY IDENTITY,
	[strDescription]			[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFrequency]				[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[ysnMonday]					[bit] NULL,
	[ysnTuesday]				[bit] NULL,
	[ysnWednesday]				[bit] NULL,
	[ysnThursday]				[bit] NULL,
	[ysnFriday]					[bit] NULL,
	[ysnSaturday]				[bit] NULL,
	[ysnSunday]					[bit] NULL,
	[intDayOfMonth]				[int] NULL,
	[dtmRunTime]				DATE NULL,
	[intConcurrencyId]			[int] DEFAULT 1,

	CONSTRAINT [UC_tblDBSchedule] UNIQUE (strDescription)
)
GO

CREATE INDEX [IX_tblDBSchedule_intScheduleId] ON [dbo].[tblDBSchedule] ([intScheduleId])
GO
