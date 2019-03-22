CREATE TABLE [dbo].[tblGLPostHistory] (
    [intPostHistoryId]   INT             IDENTITY (1, 1) NOT NULL,
    [strBatchId]         NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strSource]          NVARCHAR (30)   COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (75)   COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType] NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dtmPostDate]        DATETIME        NOT NULL,
    [dblTotal]           NUMERIC (18, 6) NOT NULL,
    [intConcurrencyId]   INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLPostHistory] PRIMARY KEY CLUSTERED ([intPostHistoryId] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'intPostHistoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'strBatchId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'strSource' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Post Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'dtmPostDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'dblTotal' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLPostHistory', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO