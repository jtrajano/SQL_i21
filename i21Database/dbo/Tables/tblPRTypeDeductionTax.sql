CREATE TABLE [dbo].[tblPRTypeDeductionTax]
(
	[intTypeDeductionTaxId] INT NOT NULL IDENTITY , 
    [intTypeDeductionId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeDeductionTax] PRIMARY KEY ([intTypeDeductionTaxId]), 
    CONSTRAINT [FK_tblPRTypeDeductionTax_tblPRTypeDeduction] FOREIGN KEY ([intTypeDeductionId]) REFERENCES [tblPRTypeDeduction]([intTypeDeductionId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTypeDeductionTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeDeductionTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Type is used in Deduction Type Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTypeDeduction', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRTypeDeductionTax_tblPRTypeDeduction'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Tax Type is used in Deduction Type Taxes' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTypeTax', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRTypeDeductionTax_tblPRTypeTax'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeDeductionTax] ON [dbo].[tblPRTypeDeductionTax] ([intTypeDeductionId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)
