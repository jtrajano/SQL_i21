/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICSku]
	(
		[intSKUId] INT NOT NULL IDENTITY, 
		[intExternalSystemId] INT NULL, 
		[strSKU] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intSKUStatusId] INT NOT NULL, 
		[strLotCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strSerialNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
		[dtmReceiveDate] DATETIME NOT NULL, 
		[dtmProductionDate] DATETIME NOT NULL, 
		[intItemId] INT NOT NULL, 
		[intContainerId] INT NOT NULL, 
		[intOwnerId] INT NOT NULL, 
		[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dtmLastUpdateOn] DATETIME NOT NULL, 
		[intLotId] INT NULL, 
		[intUnitMeasureId] INT NULL, 
		[intReasonId] INT NULL, 
		[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intParentSKUId] INT NULL, 
		[dblWeightPerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intWeightPerUnitMeasureId] INT NULL, 
		[intUnitPerLayer] INT NULL, 
		[intLayerPerPallet] INT NULL, 
		[ysnSanitized] BIT NULL DEFAULT ((0)), 
		[strBatch] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICSku] PRIMARY KEY ([intSKUId]), 
		CONSTRAINT [AK_tblICSku_strSKU] UNIQUE ([strSKU]), 
		CONSTRAINT [FK_tblICSku_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
		CONSTRAINT [FK_tblICSku_tblICContainer] FOREIGN KEY ([intContainerId]) REFERENCES [tblICContainer]([intContainerId]), 
		CONSTRAINT [FK_tblICSku_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblICSku_tblICReasonCode] FOREIGN KEY ([intReasonId]) REFERENCES [tblICReasonCode]([intReasonCodeId]), 
		CONSTRAINT [FK_tblICSku_WeightUOM] FOREIGN KEY ([intWeightPerUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intSKUId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'External System Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intExternalSystemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'SKU',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strSKU'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'SKU Status Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intSKUStatusId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strLotCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Serial No',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strSerialNo'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Receive Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'dtmReceiveDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Production Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'dtmProductionDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intContainerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Owner Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intOwnerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strLastUpdateBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update On',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastUpdateOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Reason Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intReasonId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Comment',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strComment'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Parent SKU Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intParentSKUId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight Per Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'dblWeightPerUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight Per Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intWeightPerUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Per Layer',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intUnitPerLayer'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Layer Per Pallet',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intLayerPerPallet'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sanitized',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'ysnSanitized'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Batch',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'strBatch'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICSku',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'