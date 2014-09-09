CREATE TABLE [dbo].[tblICRinFuel]
(
	[intRinFuelId] INT NOT NULL IDENTITY, 
    [strRinFuelCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICRinFuel] PRIMARY KEY ([intRinFuelId]), 
    CONSTRAINT [AK_tblICRinFuel_strRinFuelCode] UNIQUE ([strRinFuelCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuel',
    @level2type = N'COLUMN',
    @level2name = N'intRinFuelId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Fuel Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuel',
    @level2type = N'COLUMN',
    @level2name = N'strRinFuelCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuel',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuel',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuel',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'