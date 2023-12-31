﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblMFPackTypeDetail]
	(
		[intPackTypeDetailId] INT NOT NULL IDENTITY, 
		[intPackTypeId] INT NOT NULL, 
		[intSourceUnitMeasureId] INT NOT NULL, 
		[intTargetUnitMeasureId] INT NOT NULL, 
		[dblConversionFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblMFPackTypeDetail] PRIMARY KEY ([intPackTypeDetailId]), 
		CONSTRAINT [FK_tblMFPackTypeDetail_tblICPackType] FOREIGN KEY ([intPackTypeId]) REFERENCES [tblMFPackType]([intPackTypeId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblMFPackTypeDetail_SourceUnitMeasure] FOREIGN KEY ([intSourceUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblMFPackTypeDetail_TargetUnitMeasure] FOREIGN KEY ([intTargetUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intPackTypeDetailId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pack Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intPackTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Source Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intSourceUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Target Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intTargetUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Conversion Factor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'dblConversionFactor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackTypeDetail',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'