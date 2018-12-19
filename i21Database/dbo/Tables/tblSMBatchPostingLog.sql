﻿CREATE TABLE [dbo].[tblSMBatchPostingLog](
	[intBatchPostingLogId] [int] IDENTITY(1,1) NOT NULL,
	[strUser] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strVersion] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBatchNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmPostingDateStarted] [datetime] NOT NULL,
	[dtmPostingDateEnded] [datetime] NOT NULL,
	[dtmPostingDuration] [time](7) NOT NULL,
	--[intPostingRecordCount] [int] NOT NULL DEFAULT 0,
	[dtmCreatingDateStarted] [datetime] NOT NULL,
	[dtmCreatingDateEnded] [datetime] NOT NULL,
	[dtmCreatingDuration] [time](7) NOT NULL,
	[intCreatingRecordCount] [int] NOT NULL DEFAULT 0,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1
)
