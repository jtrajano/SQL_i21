CREATE TABLE [dbo].[tblICFuelTaxClassProductCode]
(
	[intFuelTaxClassProductCodeId] INT NOT NULL IDENTITY, 
    [intFuelTaxClassId] INT NOT NULL, 
    [strState] NVARCHAR(50) NOT NULL, 
    [strProductCode] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICFuelTaxClassProductCode] PRIMARY KEY ([intFuelTaxClassProductCodeId]), 
    CONSTRAINT [FK_tblICFuelTaxClassProductCode_tblICFuelTaxClass] FOREIGN KEY ([intFuelTaxClassId]) REFERENCES [tblICFuelTaxClass]([intFuelTaxClassId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'intFuelTaxClassProductCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Tax Class Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'intFuelTaxClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'strProductCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClassProductCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'