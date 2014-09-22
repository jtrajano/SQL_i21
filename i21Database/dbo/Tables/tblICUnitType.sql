CREATE TABLE [dbo].[tblICUnitType]
(
	[intUnitTypeId] INT NOT NULL IDENTITY, 
    [strUnitType] NVARCHAR(50) NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [strInternalCode] NVARCHAR(50) NULL, 
    [intCapacityUnitMeasureId] INT NOT NULL, 
    [dblMaxWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnAllowPick] BIT NULL, 
    [intDimensionUnitMeasureId] INT NOT NULL, 
    [dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intPalletStack] INT NULL DEFAULT ((0)), 
    [intPalletColumn] INT NULL DEFAULT ((0)), 
    [intPalletRow] INT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICUnitType] PRIMARY KEY ([intUnitTypeId]), 
    CONSTRAINT [AK_tblICUnitType_strUnitType] UNIQUE ([strUnitType]), 
    CONSTRAINT [FK_tblICUnitType_tblICUnitMeasure1] FOREIGN KEY ([intCapacityUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) ,
	CONSTRAINT [FK_tblICUnitType_tblICUnitMeasure2] FOREIGN KEY ([intDimensionUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intUnitTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Type Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'strUnitType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'strInternalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Capacity Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intCapacityUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Pick',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowPick'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dimension Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intDimensionUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Height',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'dblHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Depth',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'dblDepth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Width',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'dblWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pallet Stack',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intPalletStack'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pallet Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intPalletColumn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pallet Row',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intPalletRow'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'