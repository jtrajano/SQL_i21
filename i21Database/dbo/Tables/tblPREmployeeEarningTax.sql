CREATE TABLE [dbo].[tblPREmployeeEarningTax] (
    [intEmployeeEarningTaxId] INT IDENTITY (1, 1) NOT NULL,
    [intEmployeeEarningId]    INT NOT NULL,
    [intTypeTaxId]            INT NOT NULL,
    [intSort]                 INT NULL,
    [intConcurrencyId]        INT NULL,
    CONSTRAINT [PK_tblPREmployeeEarningTax] PRIMARY KEY CLUSTERED ([intEmployeeEarningTaxId] ASC),
    CONSTRAINT [FK_tblPREmployeeEarningTax_tblPREmployeeEarning] FOREIGN KEY ([intEmployeeEarningId]) REFERENCES [dbo].[tblPREmployeeEarning] ([intEmployeeEarningId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPREmployeeEarningTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [dbo].[tblPRTypeTax] ([intTypeTaxId])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningTax',
    @level2type = N'COLUMN',
    @level2name = 'intEmployeeEarningTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningTax',
    @level2type = N'COLUMN',
    @level2name = 'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeEarningTax] ON [dbo].[tblPREmployeeEarningTax] ([intEmployeeEarningId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)
