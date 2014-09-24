CREATE TABLE [dbo].[tblICItemManufacturingUOM]
(
	[intItemManufacturingUOMId] INT NOT NULL IDENTITY , 
    [intItemId] INT NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemManufacturingUOM] PRIMARY KEY ([intItemManufacturingUOMId]), 
    CONSTRAINT [FK_tblICItemManufacturingUOM_tblICItemManufacturing] FOREIGN KEY ([intItemId]) REFERENCES [tblICItemManufacturing]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemManufacturingUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingUOM',
    @level2type = N'COLUMN',
    @level2name = N'intItemManufacturingUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingUOM',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingUOM',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingUOM',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturingUOM',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'