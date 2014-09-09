CREATE TABLE [dbo].[tblPRTemplateTimeOffTax]
(
	[intTemplateTimeOffTaxId] INT NOT NULL IDENTITY , 
    [intTypeTimeOffId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTemplateTimeOffTax] PRIMARY KEY ([intTemplateTimeOffTaxId]), 
    CONSTRAINT [FK_tblPRTemplateTimeOffTax_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [tblPRTypeTimeOff]([intTypeTimeOffId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTemplateTimeOffTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateTimeOffTax] ON [dbo].[tblPRTemplateTimeOffTax] ([intTypeTimeOffId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateTimeOffTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time-Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'