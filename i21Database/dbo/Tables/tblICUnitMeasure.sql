﻿CREATE TABLE [dbo].[tblICUnitMeasure]
(
	[intUnitMeasureId] INT NOT NULL IDENTITY, 
    [strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSymbol] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strUnitType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intDecimalDisplay] INT NULL DEFAULT ((2)),
	[intDecimalCalculation] INT NULL DEFAULT ((2)),
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICUnitMeasure] PRIMARY KEY ([intUnitMeasureId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit of Measure Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'strUnitMeasure'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Symbol or Abbreviation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'strSymbol'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'strUnitType'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Decimal Places for Display',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intDecimalDisplay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Decimal Places for Calculation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intDecimalCalculation'