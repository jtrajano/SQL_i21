CREATE TABLE [dbo].[tblGLCOAAdjustmentDetail] (
    [intCOAAdjustmentDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intCOAAdjustmentId]       INT           NULL,
    [strAction]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strType]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strNew]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strPrimaryField]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strOriginal]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]             INT           NULL,
    [intAccountGroupId]        INT           NULL,
    [intConcurrencyId]         INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAAdjustmentDetail] PRIMARY KEY CLUSTERED ([intCOAAdjustmentDetailId] ASC),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment] FOREIGN KEY ([intCOAAdjustmentId]) REFERENCES [dbo].[tblGLCOAAdjustment] ([intCOAAdjustmentId]) ON DELETE CASCADE
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'intCOAAdjustmentDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'intCOAAdjustmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Action' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'strAction' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'strType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'New' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'strNew' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Field' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'strPrimaryField' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Original' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'strOriginal' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAAdjustmentDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO