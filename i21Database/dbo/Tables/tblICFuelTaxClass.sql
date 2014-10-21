CREATE TABLE [dbo].[tblICFuelTaxClass]
(
	[intFuelTaxClassId] INT NOT NULL , 
    [strTaxClassCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [strIRSTaxCode] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICFuelTaxClass] PRIMARY KEY ([intFuelTaxClassId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClass',
    @level2type = N'COLUMN',
    @level2name = N'intFuelTaxClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Class Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClass',
    @level2type = N'COLUMN',
    @level2name = N'strTaxClassCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClass',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'IRS Tax Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClass',
    @level2type = N'COLUMN',
    @level2name = N'strIRSTaxCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFuelTaxClass',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'