CREATE TABLE [dbo].[tblICItemManufacturingCell]
(
	[intItemFactoryManufacturingCellId] INT NOT NULL IDENTITY, 
    [intItemFactoryId] INT NOT NULL, 
    [intManufacturingCellId] INT NOT NULL, 
    [ysnDefault] BIT NULL DEFAULT ((0)), 
	[intPreference] INT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemFactoryManufacturingCell] PRIMARY KEY ([intItemFactoryManufacturingCellId]), 
    CONSTRAINT [FK_tblICItemFactoryManufacturingCell_tblICItemFactory] FOREIGN KEY ([intItemFactoryId]) REFERENCES [tblICItemFactory]([intItemFactoryId]), 
    CONSTRAINT [FK_tblICItemFactoryManufacturingCell_tblICManufacturingCell] FOREIGN KEY ([intManufacturingCellId]) REFERENCES [tblICManufacturingCell]([intManufacturingCellId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intItemFactoryManufacturingCellId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Factory Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intItemFactoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturing Cell Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intManufacturingCellId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intPreference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'