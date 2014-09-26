CREATE TABLE [dbo].[tblICItemManufacturing]
(
	[intItemId] INT NOT NULL, 
    [ysnRequireCustomerApproval] BIT NULL DEFAULT ((0)), 
    [intRecipeId] INT NULL, 
    [ysnSanitationRequired] BIT NULL DEFAULT ((0)), 
    [intLifeTime] INT NOT NULL, 
    [strLifeTimeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intReceiveLife] INT NULL, 
    [strGTIN] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strRotationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intNMFCId] INT NULL, 
    [ysnStrictFIFO] BIT NULL DEFAULT ((0)), 
    [intDimensionUOMId] INT NULL, 
    [dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intWeightUOMId] INT NULL, 
    [dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intMaterialPackTypeId] INT NULL, 
    [strMaterialSizeCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInnerUnits] INT NULL, 
    [intLayerPerPallet] INT NULL, 
    [intUnitPerLayer] INT NULL, 
    [dblStandardPalletRatio] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strMask1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strMask2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strMask3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemManufacturing] PRIMARY KEY ([intItemId]), 
    CONSTRAINT [FK_tblICItemManufacturing_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICItemManufacturing_DimensionUOM] FOREIGN KEY ([intDimensionUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblICItemManufacturing_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblICItemManufacturing_MaterialPackType] FOREIGN KEY ([intMaterialPackTypeId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])

)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Require Customer Approval',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'ysnRequireCustomerApproval'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recipe Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intRecipeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sanitation Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'ysnSanitationRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Life Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intLifeTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Life Time Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strLifeTimeType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receive Life',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intReceiveLife'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'GTIN',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strGTIN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rotation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strRotationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NMFC Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intNMFCId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Strict FIFO',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'ysnStrictFIFO'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dimension Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intDimensionUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Height',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'dblHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Width',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'dblWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Depth',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'dblDepth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'dblWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Size Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strMaterialSizeCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inner Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intInnerUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Layer Per Pallet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intLayerPerPallet'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Per Layer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intUnitPerLayer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Pallet Ratio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'dblStandardPalletRatio'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strMask1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strMask2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'strMask3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Pack Type Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemManufacturing',
    @level2type = N'COLUMN',
    @level2name = N'intMaterialPackTypeId'