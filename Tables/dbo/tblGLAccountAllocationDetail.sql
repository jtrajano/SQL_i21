CREATE TABLE [dbo].[tblGLAccountAllocationDetail] (
    [intAccountAllocationDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intAllocatedAccountId]        INT             NOT NULL,
    [intAccountId]                 INT             NOT NULL,
    [strJobId]                     NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                NUMERIC (10, 2) NULL,
    [intConcurrencyId]             INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountAllocationDetail_1] PRIMARY KEY CLUSTERED ([intAccountAllocationDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount1] FOREIGN KEY ([intAllocatedAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Allocation Detail Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'intAccountAllocationDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Allocated Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'intAllocatedAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Job Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'strJobId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Percentage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'dblPercentage' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAllocationDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO

