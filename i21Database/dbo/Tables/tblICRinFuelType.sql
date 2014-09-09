CREATE TABLE [dbo].[tblICRinFuelType]
(
	[intRinFuelTypeId] INT NOT NULL IDENTITY, 
    [strRinFuelTypeCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [dblEquivalenceValue] NUMERIC(18, 6) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblICRinFuelType] PRIMARY KEY ([intRinFuelTypeId]), 
    CONSTRAINT [AK_tblICRinFuelType_strRinFuelTypeCode] UNIQUE ([strRinFuelTypeCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'intRinFuelTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Fuel Type Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'strRinFuelTypeCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Equivalence Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'dblEquivalenceValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFuelType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'