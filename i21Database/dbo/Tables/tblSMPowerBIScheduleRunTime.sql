CREATE TABLE [dbo].[tblSMPowerBIScheduleRunTime]
(
	[intPowerBIScheduleRunTimeId]		INT IDENTITY (1, 1) NOT NULL,
	[intPowerBIDatasetId]				INT NOT NULL,
	[dtmRunTime]						DATETIME NULL,
	[intConcurrencyId]					[int] DEFAULT 1,

	CONSTRAINT [PK_tblSMPowerBIScheduleRunTime] PRIMARY KEY CLUSTERED ([intPowerBIScheduleRunTimeId] ASC),
)
GO

CREATE INDEX [IX_tblSMPowerBIScheduleRunTime_intPowerBIScheduleRunTimeId] ON [dbo].[tblSMPowerBIScheduleRunTime] ([intPowerBIScheduleRunTimeId])
GO
