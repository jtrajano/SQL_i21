
CREATE TABLE [dbo].[tblSMBatchPostingLog](
	[intBatchPostingLogId] [int] IDENTITY(1,1) NOT NULL,
	[strUser] [nvarchar](50) NULL,
	[strVersion] [nvarchar](50) NULL,
	[strBatchNo] [nvarchar](50) NULL,
	[dtmPostingDateStarted] [datetime] NULL,
	[dtmPostingDateEnded] [datetime] NULL,
	[dtmPostingDuration] [time](7) NULL,
	[intPostingRecordCount] [int] NOT NULL DEFAULT 0,
	[dtmCreatingDateStarted] [datetime] NULL,
	[dtmCreatingDateEnded] [datetime] NULL,
	[dtmCreatingDuration] [time](7) NULL,
	[intCreatingRecordCount] [int] NOT NULL DEFAULT 0,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1
)
