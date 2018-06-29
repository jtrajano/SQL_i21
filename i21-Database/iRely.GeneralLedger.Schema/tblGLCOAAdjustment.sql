CREATE TABLE [dbo].[tblGLCOAAdjustment] (
    [intCOAAdjustmentId] INT            IDENTITY (1, 1) NOT NULL,
    [strCOAAdjustmentId] NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [intUserId]          INT            NULL,
    [dtmDate]            DATETIME       NULL,
    [memNotes]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT            NULL,
    [intConcurrencyId]   INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAAdjustment] PRIMARY KEY CLUSTERED ([intCOAAdjustmentId] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'intCOAAdjustmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'COA Adjustment Id (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'strCOAAdjustmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'memNotes' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Posted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'ysnPosted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustment', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO