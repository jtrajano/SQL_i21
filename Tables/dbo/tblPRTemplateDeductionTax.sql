CREATE TABLE [dbo].[tblPRTemplateDeductionTax]
(
	[intTemplateDeductionTaxId] INT NOT NULL IDENTITY , 
    [intTemplateDeductionId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTemplateDeductionTax] PRIMARY KEY ([intTemplateDeductionTaxId]), 
    CONSTRAINT [FK_tblPRTemplateDeductionTax_tblPRTemplateDeduction] FOREIGN KEY ([intTemplateDeductionId]) REFERENCES [tblPRTemplateDeduction]([intTemplateDeductionId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTemplateDeductionTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateDeductionTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeductionTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateDeductionId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Group Detail is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTemplateDeduction', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRTemplateDeductionTax_tblPRTemplateDeduction'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Tax Type is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTypeTax', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRTemplateDeductionTax_tblPRTypeTax'
GO

CREATE NONCLUSTERED INDEX [IX_tblPRTemplateDeductionTax] ON [dbo].[tblPRTemplateDeductionTax] ([intTemplateDeductionId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)
