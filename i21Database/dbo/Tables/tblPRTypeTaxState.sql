CREATE TABLE [dbo].[tblPRTypeTaxState](
	[intTypeTaxStateId] [int] NOT NULL,
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCode] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeTaxState] PRIMARY KEY ([intTypeTaxStateId]),
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeTaxState] ON [dbo].[tblPRTypeTaxState] ([strState], [strCode]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxState',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxState',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxState',
    @level2type = N'COLUMN',
    @level2name = N'strCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxState',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
