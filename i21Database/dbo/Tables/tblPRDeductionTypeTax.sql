CREATE TABLE [dbo].[tblPRDeductionTypeTax]
(
	[intDeductionTypeTaxId] INT NOT NULL IDENTITY , 
    [intDeductionTypeId] INT NOT NULL, 
    [intTaxTypeId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRDeductionTypeTax] PRIMARY KEY ([intDeductionTypeTaxId]), 
    CONSTRAINT [FK_tblPRDeductionTypeTax_tblPRDeductionType] FOREIGN KEY ([intDeductionTypeId]) REFERENCES [tblPRDeductionType]([intDeductionTypeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRDeductionTypeTax_tblPRTaxType] FOREIGN KEY ([intTaxTypeId]) REFERENCES [tblPRTaxType]([intTaxTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionTypeTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Type is used in Deduction Type Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRDeductionType', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionTypeTax_tblPRDeductionType'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Tax Type is used in Deduction Type Taxes' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTaxType', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionTypeTax_tblPRTaxType'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRDeductionTypeTax] ON [dbo].[tblPRDeductionTypeTax] ([intDeductionTypeId], [intTaxTypeId]) WITH (IGNORE_DUP_KEY = OFF)
