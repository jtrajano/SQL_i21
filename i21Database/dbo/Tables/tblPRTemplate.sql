CREATE TABLE [dbo].[tblPRTemplate](
	[intTemplateId] [int] IDENTITY(1,1) NOT NULL,
	[strTemplateName] [nvarchar](50) NOT NULL,
	[strDescription] [nvarchar](100) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTemplate] PRIMARY KEY ([intTemplateId]), 
    CONSTRAINT [AK_tblPRTemplate_strTemplateName] UNIQUE ([strTemplateName]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplate',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplate',
    @level2type = N'COLUMN',
    @level2name = N'strTemplateName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplate',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplate',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'