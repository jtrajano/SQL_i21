CREATE TABLE [dbo].[tblGLPostResults](
	[intResult] [int] IDENTITY(1,1) NOT NULL,
	[strBatchID] [nvarchar](55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionID] [int] NOT NULL,
	[strTransactionID] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strTransactionType] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLPostResults] PRIMARY KEY CLUSTERED 
(
	[intResult] ASC,
	[strBatchID] ASC,
	[intTransactionID] ASC
)
);