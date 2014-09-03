CREATE TABLE [dbo].[tblPRTaxTypeCounty](
	[intTaxTypeCounty] [int] IDENTITY(1,1) NOT NULL,
	[intTaxTypeStateId] INT NOT NULL,
	[strCounty] [nvarchar](50) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxTypeCounty] PRIMARY KEY ([intTaxTypeCounty]) 
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTaxTypeCounty] ON [dbo].[tblPRTaxTypeCounty] ([intTaxTypeStateId], [strCounty]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeCounty',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeCounty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeCounty',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'County',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeCounty',
    @level2type = N'COLUMN',
    @level2name = N'strCounty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeCounty',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeCounty',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'