CREATE TABLE [dbo].[tblGLReconciledAccount]
(
	[intId] INT NOT NULL PRIMARY KEY, 
    [intConcurrencyId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [dtmReconciledDate] DATETIME NOT NULL, 
    [strReconciledId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReconciledAccount', @level2type=N'COLUMN',@level2name=N'intId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReconciledAccount', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReconciledAccount', @level2type=N'COLUMN',@level2name=N'intAccountId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Reconciled Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReconciledAccount', @level2type=N'COLUMN',@level2name=N'dtmReconciledDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reconciled Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReconciledAccount', @level2type=N'COLUMN',@level2name=N'strReconciledId' 
GO