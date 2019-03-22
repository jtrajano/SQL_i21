CREATE TABLE [dbo].[tblGLAccountReallocationDetail] (
    [intAccountReallocationDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intAccountReallocationId]       INT             NULL,
    [intAccountId]                   INT             NOT NULL,
    [strJobId]                       NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                  NUMERIC (10, 2) NULL,
    [intConcurrencyId]               INT             DEFAULT 1 NOT NULL,
    [dblUnit]                        NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblGLAccountReallocationDetail] PRIMARY KEY CLUSTERED ([intAccountReallocationDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation] FOREIGN KEY ([intAccountReallocationId]) REFERENCES [dbo].[tblGLAccountReallocation] ([intAccountReallocationId]) ON DELETE CASCADE
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'intAccountReallocationDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'intAccountReallocationId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Job Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'strJobId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Percentage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'dblPercentage' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocationDetail', @level2type=N'COLUMN',@level2name=N'dblUnit' 
GO
