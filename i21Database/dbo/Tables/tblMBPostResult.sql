CREATE TABLE [dbo].[tblMBPostResult]
(
	[intResult] [int] IDENTITY (1, 1) NOT NULL,
	[strBatchId] [nvarchar](55) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) NOT NULL,
	[strDescription] [nvarchar](250) NULL,
	[dtmDate] [datetime] NULL,
	[strTransactionType] [nvarchar](40) NULL,
	[intUserId] [int] NULL,
	[intEntityId] [int] NULL,
	CONSTRAINT [PK_tblMBPostResult] PRIMARY KEY CLUSTERED ([intResult] ASC)
)
