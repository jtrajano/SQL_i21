CREATE TABLE [dbo].[tblPRTaxTypeState](
	[intTaxTypeStateId] [int] NOT NULL IDENTITY,
	[strState] [nvarchar](50) NOT NULL,
	[strCode] [nvarchar](10) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxTypeState] PRIMARY KEY ([intTaxTypeStateId]),
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTaxTypeState] ON [dbo].[tblPRTaxTypeState] ([strState], [strCode]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeState',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeState',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeState',
    @level2type = N'COLUMN',
    @level2name = N'strCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeState',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTypeState',
    @level2type = N'COLUMN',
    @level2name = N'intSort'