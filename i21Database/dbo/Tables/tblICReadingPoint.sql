CREATE TABLE [dbo].[tblICReadingPoint]
(
	[intReadingPointId] INT NOT NULL IDENTITY, 
    [strReadingPoint] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intSort] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICReadingPoint] PRIMARY KEY ([intReadingPointId]), 
    CONSTRAINT [AK_tblICReadingPoint_strReadingPoint] UNIQUE ([strReadingPoint])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReadingPoint',
    @level2type = N'COLUMN',
    @level2name = N'intReadingPointId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading Point',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReadingPoint',
    @level2type = N'COLUMN',
    @level2name = N'strReadingPoint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReadingPoint',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReadingPoint',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'