CREATE TABLE [dbo].[tblPRTaxTypeLocal](
	[intTaxTypeLocalId] [int] IdENTITY(1,1) NOT NULL,
	[strLocal] [nvarchar](20) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxTypeLocal] PRIMARY KEY ([intTaxTypeLocalId]), 
    CONSTRAINT [AK_tblPRTaxTypeLocal_strLocal] UNIQUE ([strLocal]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeLocal',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeLocalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeLocal',
    @level2type = N'COLUMN',
    @level2name = N'strLocal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeLocal',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeLocal',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'