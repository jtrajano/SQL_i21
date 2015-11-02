﻿CREATE TABLE [dbo].[tblPRPaycheckDeductionTax]
(
	[intPaycheckDeductionTaxId] INT NOT NULL IDENTITY, 
    [intPaycheckDeductionId] INT NOT NULL,
	[intTypeTaxId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRPaycheckDeductionTax] PRIMARY KEY ([intPaycheckDeductionTaxId]), 
    CONSTRAINT [FK_tblPRPaycheckDeductionTax_tblPRPaycheckDeduction] FOREIGN KEY ([intPaycheckDeductionId]) REFERENCES [tblPRPaycheckDeduction]([intPaycheckDeductionId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPRPaycheckDeductionTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [dbo].[tblPRTypeTax] ([intTypeTaxId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckDeductionTaxId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Deduction Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckDeductionId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'