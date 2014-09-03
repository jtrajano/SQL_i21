CREATE TABLE [dbo].[tblPRDeductionGroupDetailTax]
(
	[intDeductionGroupDetailTaxId] INT NOT NULL IDENTITY , 
    [intDeductionGroupDetailId] INT NOT NULL, 
    [intTaxTypeId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRDeductionGroupDetailTax] PRIMARY KEY ([intDeductionGroupDetailTaxId]), 
    CONSTRAINT [FK_tblPRDeductionGroupDetailTax_tblPRDeductionGroupDetail] FOREIGN KEY ([intDeductionGroupDetailId]) REFERENCES [tblPRDeductionGroupDetail]([intDeductionGroupDetailId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRDeductionGroupDetailTax_tblPRTaxType] FOREIGN KEY ([intTaxTypeId]) REFERENCES [tblPRTaxType]([intTaxTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupDetailTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupDetailId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Group Detail is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRDeductionGroupDetail', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionGroupDetailTax_tblPRDeductionGroupDetail'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Tax Type is used in Deduction Group Detail Tax' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTaxType', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionGroupDetailTax_tblPRTaxType'
GO

CREATE NONCLUSTERED INDEX [IX_tblPRDeductionGroupDetailTax] ON [dbo].[tblPRDeductionGroupDetailTax] ([intDeductionGroupDetailId], [intTaxTypeId]) WITH (IGNORE_DUP_KEY = OFF)
