CREATE TABLE [dbo].[tblICMaterialNMFC]
(
	[intMaterialNMFCId] INT NOT NULL IDENTITY, 
    [intExternalSystemId] INT NULL, 
    [strInternalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDisplayMember] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDefault] BIT NOT NULL DEFAULT ((0)), 
    [ysnLocked] BIT NOT NULL DEFAULT ((0)), 
    [strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT ((0)), 
    [dtmLastUpdateOn] DATETIME NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICMaterialNMFC] PRIMARY KEY ([intMaterialNMFCId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'intMaterialNMFCId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'External System Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'intExternalSystemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'strInternalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Display Member',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'strDisplayMember'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Locked',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'ysnLocked'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Update By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'strLastUpdateBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Update On',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdateOn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMaterialNMFC',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'