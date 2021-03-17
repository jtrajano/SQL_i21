﻿CREATE TABLE [dbo].[tblARRebuildLog]
(
	[intRebuildLogId]	INT NOT NULL  IDENTITY, 
	[strIssue]			NVARCHAR (50) COLLATE Latin1_General_CI_AS,
	[dtmDate]			DATE,
	[intTransactionId]	INT,
	[strTransactionId]	NVARCHAR (50) COLLATE Latin1_General_CI_AS,
	[strBatchId]		NVARCHAR (50) COLLATE Latin1_General_CI_AS,
	[ysnAllowRebuild]	BIT,
	CONSTRAINT [PK_tblARRebuildLog_intRebuildLogId] PRIMARY KEY CLUSTERED ([intRebuildLogId] ASC)
)
