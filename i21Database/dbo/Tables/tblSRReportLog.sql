CREATE TABLE [dbo].[tblSRReportLog]
(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[strReportLogId] [nvarchar](50) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	CONSTRAINT [PK_tblSRReportLog_intId] PRIMARY KEY CLUSTERED ([intId] ASC)
)

GO

CREATE NONCLUSTERED INDEX [IX_tblSRReportLog_strReportLogId] ON [dbo].[tblSRReportLog] ([strReportLogId] ASC)

GO
