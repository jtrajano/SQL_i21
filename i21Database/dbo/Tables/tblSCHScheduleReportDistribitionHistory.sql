CREATE TABLE [dbo].[tblSCHScheduleReportDistribitionHistory]
(
	[intScheduleReportDistributionHistoryId]			INT IDENTITY (1, 1) NOT NULL,
	[intScheduleId]										[int] NOT NULL,
	[intReportDistributionId]							[int] NOT NULL,
	[strJobId]											[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTempJobId]										[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDateOfExecution]								DATETIME NULL,
	[dtmDateCreated]									DATETIME NULL,
	[dtmDateStarted]									DATETIME NULL,
	[dtmDateCompleted]									DATETIME NULL,
	[strStatus]											[nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strRemarks]										[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]									[int] DEFAULT 1,

	CONSTRAINT [PK_tblSCHScheduleReportDistribitionHistory] PRIMARY KEY CLUSTERED ([intScheduleReportDistributionHistoryId] ASC)
)


GO

CREATE INDEX [IX_tblSCHScheduleReportDistribitionHistory_intScheduleReportDistributionHistoryId] ON [dbo].[tblSCHScheduleReportDistribitionHistory] ([intScheduleReportDistributionHistoryId])
GO
