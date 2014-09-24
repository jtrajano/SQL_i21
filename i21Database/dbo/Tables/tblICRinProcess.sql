CREATE TABLE [dbo].[tblICRinProcess]
(
	[intRinProcessId] INT NOT NULL IDENTITY, 
    [strRinProcessCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICRinProcess] PRIMARY KEY ([intRinProcessId]), 
    CONSTRAINT [AK_tblICRinProcess_strRinProcessCode] UNIQUE ([strRinProcessCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinProcess',
    @level2type = N'COLUMN',
    @level2name = N'intRinProcessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Process Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinProcess',
    @level2type = N'COLUMN',
    @level2name = N'strRinProcessCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinProcess',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinProcess',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinProcess',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'