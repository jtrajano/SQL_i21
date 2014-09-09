CREATE TABLE [dbo].[tblPRTypeTimeOffTax]
(
	[intTypeTimeOffTaxId] INT NOT NULL IDENTITY , 
    [intTypeTimeOffId] INT NOT NULL, 
    [intTypeTaxId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeTimeOffTax] PRIMARY KEY ([intTypeTimeOffTaxId]), 
    CONSTRAINT [FK_tblPRTypeTimeOffTax_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [tblPRTypeTimeOff]([intTypeTimeOffId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTypeTimeOffTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId])
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeTimeOffTax] ON [dbo].[tblPRTypeTimeOffTax] ([intTypeTimeOffId], [intTypeTaxId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Leave Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'