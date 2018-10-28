CREATE TABLE [dbo].[tblCMConfig]
(
	[intConfigId] [int] IDENTITY(1,1) NOT NULL,
	[strVoidIndicator] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strCheckIndicator] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMConfig', @level2type=N'COLUMN',@level2name=N'intConfigId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Void Indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMConfig', @level2type=N'COLUMN',@level2name=N'strVoidIndicator'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check Indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMConfig', @level2type=N'COLUMN',@level2name=N'strCheckIndicator'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMConfig', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO