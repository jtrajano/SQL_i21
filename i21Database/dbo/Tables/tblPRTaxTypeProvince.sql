CREATE TABLE [dbo].[tblPRTaxTypeProvince](
	[intTaxTypeProvinceId] [int] IdENTITY(1,1) NOT NULL,
	[strProvince] [nvarchar](50) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxTypeProvince] PRIMARY KEY ([intTaxTypeProvinceId]), 
    CONSTRAINT [AK_tblPRTaxTypeProvince_strProvince] UNIQUE ([strProvince]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeProvince',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeProvinceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Province',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeProvince',
    @level2type = N'COLUMN',
    @level2name = N'strProvince'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeProvince',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeProvince',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'