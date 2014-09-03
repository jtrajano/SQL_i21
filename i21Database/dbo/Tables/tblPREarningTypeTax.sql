CREATE TABLE [dbo].[tblPREarningTypeTax]
(
	[intEarningTypeTaxId] INT NOT NULL IDENTITY , 
    [intEarningTypeId] INT NOT NULL, 
    [intTaxTypeId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREarningTypeTax] PRIMARY KEY ([intEarningTypeTaxId]), 
    CONSTRAINT [FK_tblPREarningTypeTax_tblPREarningType] FOREIGN KEY ([intEarningTypeId]) REFERENCES [tblPREarningType]([intEarningTypeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPREarningTypeTax_tblPRTaxType] FOREIGN KEY ([intTaxTypeId]) REFERENCES [tblPRTaxType]([intTaxTypeId])
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREarningTypeTax] ON [dbo].[tblPREarningTypeTax] ([intEarningTypeId], [intTaxTypeId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intEarningTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intEarningTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'