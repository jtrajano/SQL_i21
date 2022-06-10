﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemUOM]
	(
		[intItemUOMId] INT NOT NULL IDENTITY , 
		[intItemId] INT NOT NULL,
		[intUnitMeasureId] INT NOT NULL, 
		[dblUnitQty] NUMERIC(38, 20) NULL DEFAULT ((0)), 
		[dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[intWeightUOMId] INT NULL,
		[strUpcCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strLongUPCCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
        [intCheckDigit] INT NULL,
        [strUPCDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
        [intModifier] INT NULL,
		[ysnStockUnit] BIT NULL DEFAULT ((0)),
		[ysnAllowPurchase] BIT NULL DEFAULT ((0)),
		[ysnAllowSale] BIT NULL DEFAULT ((0)),
		[dblLength] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intDimensionUOMId] INT NULL,
		[dblVolume] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intVolumeUOMId] INT NULL,
		[dblMaxQty] NUMERIC(18, 6) NULL DEFAULT ((0)),
        [dblStandardWeight] NUMERIC(38, 20) NULL DEFAULT ((0)),		
		[ysnStockUOM] AS ([ysnStockUnit]), --[ysnStockUOM] BIT NULL, -- Convert ysnStockUOM into a calculated column to minimize code impact.
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
        [dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		[intDataSourceId] TINYINT NULL,
		[intUpcCode] AS 
			(
				CASE 
					WHEN 
							strLongUPCCode IS NOT NULL 
							AND ISNUMERIC(RTRIM(LTRIM(strLongUPCCode))) = 1 
							AND NOT (strLongUPCCode LIKE '%.%' OR strLongUPCCode LIKE '%e%' OR strLongUPCCode LIKE '%E%') 
						THEN 				
							CAST(RTRIM(LTRIM(strLongUPCCode)) AS BIGINT) 
					ELSE 
						CAST(NULL AS BIGINT) 
				END
			) PERSISTED,
        [guiApiUniqueId] UNIQUEIDENTIFIER NULL,
        [intRowNumber] INT NULL,
		CONSTRAINT [PK_tblICItemUOM] PRIMARY KEY ([intItemUOMId]), 
        CONSTRAINT [CHK_tblICItemUOM_intModifier] CHECK (intModifier >= 0 AND intModifier <= 999),
        CONSTRAINT [CHK_tblICItemUOM_intCheckDigit] CHECK (intCheckDigit >= 0 AND intCheckDigit <= 9),
		CONSTRAINT [FK_tblICItemUOM_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICItemUOM_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICItemUOM_DimensionUOM] FOREIGN KEY ([intDimensionUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICItemUOM_VolumeUOM] FOREIGN KEY ([intVolumeUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [AK_tblICItemUOM] UNIQUE ([intItemId], [intUnitMeasureId]),
		CONSTRAINT [FK_tblICItemUOM_tblICDataSource] FOREIGN KEY ([intDataSourceId]) REFERENCES [tblICDataSource]([intDataSourceId])
	)
	GO

		CREATE NONCLUSTERED INDEX [IX_tblICItemUOM_intUnitMeasureId]
		ON [dbo].[tblICItemUOM]([intUnitMeasureId] ASC, [intItemId] ASC, ysnStockUnit ASC)
		INCLUDE (dblUnitQty); 
	GO

		CREATE NONCLUSTERED INDEX [IX_tblICItemUOM_intItemId]
		ON [dbo].[tblICItemUOM]([intItemId] ASC, intUnitMeasureId ASC, ysnStockUnit ASC)
		INCLUDE (dblUnitQty); 
	GO
        CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUOM_strLongUPCCode]
        ON tblICItemUOM([strLongUPCCode])
        WHERE strLongUPCCode IS NOT NULL AND intModifier IS NULL;
    GO
        CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUOM_strUpcCode]
        ON tblICItemUOM([strUpcCode])
        WHERE strUpcCode IS NOT NULL AND intModifier IS NULL;
    GO
        CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUOM_strLongUPCCode_intModifier]
        ON tblICItemUOM([strLongUPCCode], [intModifier])
        WHERE strLongUPCCode IS NOT NULL AND intModifier IS NOT NULL;
    GO
        CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUOM_strUpcCode_intModifier]
        ON tblICItemUOM([strUpcCode], [intModifier])
        WHERE strUpcCode IS NOT NULL AND intModifier IS NOT NULL;
    GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitQty'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblWeight'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UPC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'strUpcCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stock Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnStockUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Purchase',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowPurchase'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Sale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Length',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Height',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblVolume'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Width',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dimension Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intDimensionUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUOM',
    @level2type = N'COLUMN',
    @level2name = N'intVolumeUOMId'