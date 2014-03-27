CREATE TABLE [dbo].[tblGLPostResult](
	[intResult] [int] IDENTITY(1,1) NOT NULL,
	[strBatchId] [nvarchar](55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strTransactionType] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[intUserId] [int] NOT NULL,
 CONSTRAINT [PK_tblGLPostResults] PRIMARY KEY CLUSTERED 
(
	[intResult] ASC,
	[strBatchId] ASC,
	[intTransactionId] ASC
)
);