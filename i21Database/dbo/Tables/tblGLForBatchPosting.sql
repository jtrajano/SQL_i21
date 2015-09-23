﻿CREATE TABLE [dbo].[tblGLForBatchPosting](
	[guid] [uniqueidentifier] NULL,
	[strTransactionType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] [int] NULL,
	[intEntityId] [int] NULL,
	[strUserName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[dtmDateEntered] [datetime] NULL CONSTRAINT [DF_tblGLForBatchPosting_dtmDateEntered]  DEFAULT (getdate())
) ON [PRIMARY]