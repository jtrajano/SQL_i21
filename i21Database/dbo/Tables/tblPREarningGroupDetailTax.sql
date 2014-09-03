CREATE TABLE [dbo].[tblPREarningGroupDetailTax]
(
	[intEarningGroupDetailTaxId] INT NOT NULL IDENTITY , 
    [intEarningGroupDetailId] INT NOT NULL, 
    [intTaxTypeId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblPREarningGroupDetailTax] PRIMARY KEY ([intEarningGroupDetailTaxId]), 
    CONSTRAINT [FK_tblPREarningGroupDetailTax_tblPREarningGroupDetail] FOREIGN KEY ([intEarningGroupDetailId]) REFERENCES [tblPREarningGroupDetail]([intEarningGroupDetailId]), 
    CONSTRAINT [FK_tblPREarningGroupDetailTax_tblPRTaxType] FOREIGN KEY ([intTaxTypeId]) REFERENCES [tblPRTaxType]([intTaxTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupDetailTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Group Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetailTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREarningGroupDetailTax] ON [dbo].[tblPREarningGroupDetailTax] ([intEarningGroupDetailId], [intTaxTypeId]) WITH (IGNORE_DUP_KEY = OFF)
