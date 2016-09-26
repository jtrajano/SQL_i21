CREATE TABLE [dbo].[tblCRMSetting]
(
	[intCrmSettingId] [int] IDENTITY(1,1) NOT NULL,
	[strSignatureFormat] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCRMSettings] PRIMARY KEY CLUSTERED ([intCrmSettingId] ASC)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSetting',
    @level2type = N'COLUMN',
    @level2name = N'intCrmSettingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Signature Format',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSetting',
    @level2type = N'COLUMN',
    @level2name = N'strSignatureFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSetting',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'