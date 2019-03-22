CREATE TABLE [dbo].[tblGLAccountAdjustmentLog]
(
	[intAccountAdjustmentId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPrimaryKey] INT NULL, 
    [strTable] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strColumn] NCHAR(20)  COLLATE Latin1_General_CI_AS NULL, 
    [strAction] NCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmAction] DATETIME NULL, 
    [strOriginalValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strNewValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL    
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Adjustment Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'intAccountAdjustmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'intPrimaryKey' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strTable' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strColumn'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Action' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strAction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Action' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'dtmAction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Original Value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strOriginalValue' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'New Value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strNewValue' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountAdjustmentLog', @level2type=N'COLUMN',@level2name=N'strName' 
GO

