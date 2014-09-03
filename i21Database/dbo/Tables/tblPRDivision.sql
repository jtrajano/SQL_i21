CREATE TABLE [dbo].[tblPRDivision]
(
	[intDivisionId] INT NOT NULL IDENTITY , 
    [strDivision] NVARCHAR(50) NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRDivision] PRIMARY KEY ([intDivisionId]), 
    CONSTRAINT [AK_tblPRDivision_strDivision] UNIQUE ([strDivision]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDivision',
    @level2type = N'COLUMN',
    @level2name = N'intDivisionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DIvision Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDivision',
    @level2type = N'COLUMN',
    @level2name = N'strDivision'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDivision',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDivision',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'