CREATE TABLE [dbo].[tblPRTypeEarningTax]
(
	[intTypeEarningTaxId] INT NOT NULL IDENTITY , 
    [intTypeEarningId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeEarningTax] PRIMARY KEY ([intTypeEarningTaxId]), 
    CONSTRAINT [FK_tblPRTypeEarningTax_tblPRTypeEarning] FOREIGN KEY ([intTypeEarningId]) REFERENCES [tblPRTypeEarning]([intTypeEarningId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTypeEarningTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeEarningTax] ON [dbo].[tblPRTypeEarningTax] ([intTypeEarningId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'