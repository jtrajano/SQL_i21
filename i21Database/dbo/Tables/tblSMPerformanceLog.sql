
CREATE TABLE [dbo].[tblSMPerformanceLog](
	[intPerformanceLogId]       INT IDENTITY(1,1) NOT NULL,
	[strModuleName]				NVARCHAR(50) NULL,
	[strScreenName]             NVARCHAR(200) NULL,
	[strProcedureName]          NVARCHAR(200) NULL,
    [strBuildNumber]            NVARCHAR(50) NULL,
	[strGroup]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDateTime]          DATETIME NULL,
    [dtmEndDateTime]            DATETIME NULL,	
	[intUserId]                 INT NULL,
	CONSTRAINT [PK_tblSMPerformanceLog_intPerformanceLogId] PRIMARY KEY CLUSTERED ([intPerformanceLogId] ASC)
);
GO
CREATE INDEX [idx_tblSMPerformanceLog] ON [dbo].[tblSMPerformanceLog] (strScreenName, dtmStartDateTime, dtmEndDateTime, intUserId)