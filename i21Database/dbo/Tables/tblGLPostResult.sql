CREATE TABLE [dbo].[tblGLPostResult](
	[intResult] [int] IDENTITY(1,1) NOT NULL,
	[strBatchId] [nvarchar](55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strTransactionType] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[intUserId] [int] NULL,
	[intEntityId] [int] NULL,
 CONSTRAINT [PK_tblGLPostResult] PRIMARY KEY CLUSTERED 
(
	[intResult] ASC,
	[strBatchId] ASC,
	[intTransactionId] ASC
)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Result' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'intResult' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'strBatchId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'intTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostResult', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
