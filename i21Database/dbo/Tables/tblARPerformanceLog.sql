
CREATE TABLE [dbo].[tblARPerformanceLog](
	[intPerformanceLogId]       INT IDENTITY(1,1) NOT NULL,
	[strScreenName]             NVARCHAR(200) NULL,
	[strProcedureName]          NVARCHAR(200) NULL,
    [strBuildNumber]            NVARCHAR(50) NULL,
	[dtmStartDateTime]          DATETIME NULL,
    [dtmEndDateTime]            DATETIME NULL,
	[intUserId]                 INT NULL,
	CONSTRAINT [PK_tblARPerformanceLog_intPerformanceLogId] PRIMARY KEY CLUSTERED ([intPerformanceLogId] ASC)
);
GO
CREATE INDEX [idx_tblARPerformanceLog] ON [dbo].[tblARPerformanceLog] (strScreenName, dtmStartDateTime, dtmEndDateTime, intUserId)