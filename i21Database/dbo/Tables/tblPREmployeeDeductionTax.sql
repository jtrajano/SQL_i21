CREATE TABLE [dbo].[tblPREmployeeDeductionTax]
(
	[intEmployeeDeductionTaxId] INT NOT NULL IDENTITY , 
    [intEmployeeDeductionId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeeDeductionTax] PRIMARY KEY ([intEmployeeDeductionTaxId]), 
    CONSTRAINT [FK_tblPREmployeeDeductionTax_tblPREmployeeDeduction] FOREIGN KEY ([intEmployeeDeductionId]) REFERENCES [tblPREmployeeDeduction]([intEmployeeDeductionId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPREmployeeDeductionTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDeductionTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDeductionId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Group Detail is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPREmployeeDeduction', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPREmployeeDeductionTax_tblPREmployeeDeduction'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Tax Type is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTypeTax', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPREmployeeDeductionTax_tblPRTypeTax'
GO

CREATE NONCLUSTERED INDEX [IX_tblPREmployeeDeductionTax] ON [dbo].[tblPREmployeeDeductionTax] ([intEmployeeDeductionId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)
