CREATE TABLE [dbo].[tblGLForBatchPosting](
	[intBatchPostingId] INT NOT NULL IDENTITY,
	[guid] [uniqueidentifier] NULL,
	[strTransactionType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] [int] NULL,
	[intEntityId] [int] NULL,
	[strUserName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[dtmDateEntered] [datetime] NULL CONSTRAINT [DF_tblGLForBatchPosting_dtmDateEntered]  DEFAULT (getdate()), 
	[ysnSelected] BIT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblGLForBatchPosting] PRIMARY KEY ([intBatchPostingId])
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'intBatchPostingId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Guid to group by batch' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'guid' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'intTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'strUserName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date Entered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'dtmDateEntered' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Selected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'ysnSelected' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLForBatchPosting', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO