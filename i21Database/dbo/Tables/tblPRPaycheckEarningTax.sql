CREATE TABLE [dbo].[tblPRPaycheckEarningTax]
(
	[intPaycheckEarningTaxId] INT NOT NULL IDENTITY(1, 1), 
    [intPaycheckEarningId] INT NOT NULL, 
    [intEmployeeTaxId] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRPaycheckEarningTax] PRIMARY KEY ([intPaycheckEarningTaxId]), 
    CONSTRAINT [FK_tblPRPaycheckEarningTax_tblPRPaycheckEarning] FOREIGN KEY ([intPaycheckEarningId]) REFERENCES [tblPRPaycheckEarning]([intPaycheckEarningId]) ON DELETE CASCADE, 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckEarningTaxId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Tax Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarningTax',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTaxId'