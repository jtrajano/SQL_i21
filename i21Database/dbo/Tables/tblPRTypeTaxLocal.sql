CREATE TABLE [dbo].[tblPRTypeTaxLocal](
	[intTypeTaxLocalId] [int] IdENTITY(1,1) NOT NULL,
	[strLocalName] [nvarchar](20) NOT NULL,
	[strLocalType] NVARCHAR(10) NULL, 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeTaxLocal] PRIMARY KEY ([intTypeTaxLocalId]), 
    CONSTRAINT [AK_tblPRTypeTaxLocal_strLocal] UNIQUE ([strLocalName]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxLocalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = 'strLocalName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'strLocalType'