CREATE TABLE [dbo].[tblICLot]
(
	[intLotId] INT NOT NULL IDENTITY, 
    [strLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICLot] PRIMARY KEY ([intLotId]), 
    CONSTRAINT [AK_tblICLot_strLotId] UNIQUE ([strLotId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLot',
    @level2type = N'COLUMN',
    @level2name = N'intLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLot',
    @level2type = N'COLUMN',
    @level2name = N'strLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLot',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'