CREATE TABLE [dbo].[tblPRRace]
(
	[intRaceId] INT NOT NULL IDENTITY , 
    [strRace] NVARCHAR(50) NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRRace] PRIMARY KEY ([intRaceId]), 
    CONSTRAINT [AK_tblPRRace_strDivision] UNIQUE ([strRace]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRRace',
    @level2type = N'COLUMN',
    @level2name = N'intRaceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DIvision Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRRace',
    @level2type = N'COLUMN',
    @level2name = N'strRace'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRRace',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRRace',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'