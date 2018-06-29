CREATE TABLE [dbo].[tblPRTemplateEarningTax] (
    [intTemplateEarningTaxId] INT IDENTITY (1, 1) NOT NULL,
    [intTemplateEarningId]    INT NOT NULL,
    [intTypeTaxId]            INT NOT NULL,
    [intSort]                 INT NULL,
    [intConcurrencyId]        INT NULL,
    CONSTRAINT [PK_tblPRTemplateEarningTax] PRIMARY KEY CLUSTERED ([intTemplateEarningTaxId] ASC),
    CONSTRAINT [FK_tblPRTemplateEarningTax_tblPRTemplateEarning] FOREIGN KEY ([intTemplateEarningId]) REFERENCES [dbo].[tblPRTemplateEarning] ([intTemplateEarningId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPRTemplateEarningTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [dbo].[tblPRTypeTax] ([intTypeTaxId])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningTax',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateEarningTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningTax',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateEarningTax] ON [dbo].[tblPRTemplateEarningTax] ([intTemplateEarningId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)
