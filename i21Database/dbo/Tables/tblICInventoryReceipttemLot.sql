/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptItemLot]
	(
		[intInventoryReceiptItemLotId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptItemId] INT NOT NULL, 
		[intParentLotId] INT NULL, 
		[intLotId] INT NULL, 
		[strParentLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intWeightUOMId] INT NULL, 
		[dblGrossWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblTareWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intStorageLocationId] INT NULL, 
		[intUnitUOMId] INT NULL, 
		[intUnits] INT NULL DEFAULT ((0)), 
		[intUnitPallet] INT NULL DEFAULT ((0)), 
		[dblStatedGrossPerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblStatedTarePerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intGarden] INT NULL, 
		[strGrade] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intOriginId] INT NULL, 
		[intSeasonCropYear] INT NULL, 
		[strVendorLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmManufacturedDate] DATETIME NULL, 
		[strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmCertified] DATETIME NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICInventoryReceiptItemLot] PRIMARY KEY ([intInventoryReceiptItemLotId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
		-- CONSTRAINT [FK_tblICInventoryReceiptItemLot_ParentLot] FOREIGN KEY ([intParentLotId]) REFERENCES [tblICLot]([intLotId]), -- Remove this as per Chakra
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptItemLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inventory Receipt Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Parent Lot Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intParentLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Number',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'strContainerNo'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Number of Units',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intUnits'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = 'intUnitUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units/Pallet',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intUnitPallet'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Gross Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblGrossWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tare Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblTareWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight Unit of Measure',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = 'intWeightUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Stated Gross Per Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblStatedGrossPerUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Stated Tare Per Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblStatedTarePerUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Garden',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intGarden'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Grade',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'strGrade'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Origin Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intOriginId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Season / Crop Year',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intSeasonCropYear'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Vendor Lot Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'strVendorLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Manufactured Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dtmManufacturedDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Remarks',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'strRemarks'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parent Lot',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strParentLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Condition',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strCondition'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Certified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dtmCertified'