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
		[intLotId] INT NULL, 
		[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSubLocationId] INT NULL, 
		[intStorageLocationId] INT NULL,	
		[intItemUnitMeasureId] INT NULL,	
		[dblQuantity] NUMERIC(38, 15) NULL DEFAULT ((0)), 		
		[dblGrossWeight] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[dblTareWeight] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[dblCost] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[intNoPallet] INT NULL DEFAULT ((0)),
		[intUnitPallet] INT NULL DEFAULT ((0)), 
		[dblStatedGrossPerUnit] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[dblStatedTarePerUnit] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intEntityVendorId] INT NULL,
		[strGarden] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strMarkings] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intOriginId] INT NULL, 
		[intGradeId] INT NULL,
		[intSeasonCropYear] INT NULL, 
		[strVendorLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmManufacturedDate] DATETIME NULL, 
		[strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmCertified] DATETIME NULL, 
		[dtmExpiryDate] DATETIME NULL, 
		[intParentLotId] INT NULL, 
		[strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblStatedNetPerUnit] NUMERIC(38, 20) NULL DEFAULT ((0)), 		
		[dblStatedTotalNet] NUMERIC(38, 20) NULL DEFAULT ((0)), 		
		[dblPhysicalVsStated] NUMERIC(38, 20) NULL DEFAULT ((0)), 		
		[strCertificate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 	
		[intProducerId] INT	NULL,
		[strWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strCertificateId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 	
		[strTrackingNumber] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 	
		[intLotStatusId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICInventoryReceiptItemLot] PRIMARY KEY ([intInventoryReceiptItemLotId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
		CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblEMEntity] FOREIGN KEY ([intProducerId]) REFERENCES [tblEMEntity]([intEntityId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItemLot_intInventoryReceiptItemId]
		ON [dbo].[tblICInventoryReceiptItemLot]([intInventoryReceiptItemId] ASC)
		INCLUDE (intLotId)

	GO

--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Identity Field',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intInventoryReceiptItemLotId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Inventory Receipt Item Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intInventoryReceiptItemId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Parent Lot Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intParentLotId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Lot Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intLotId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Container Number',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'strContainerNo'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Quantity',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dblQuantity'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Number of Units',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intUnits'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Unit Unit of Measure Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = 'intUnitUOMId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Units/Pallet',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intUnitPallet'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Gross Weight',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dblGrossWeight'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Tare Weight',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dblTareWeight'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Weight Unit of Measure',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = 'intWeightUOMId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Stated Gross Per Unit',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dblStatedGrossPerUnit'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Stated Tare Per Unit',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dblStatedTarePerUnit'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Garden',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intGarden'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Grade',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'strGrade'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Origin Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intOriginId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Season / Crop Year',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intSeasonCropYear'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Vendor Lot Id',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'strVendorLotId'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Manufactured Date',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'dtmManufacturedDate'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Remarks',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'strRemarks'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Sort Field',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intSort'
--	GO
--	EXEC sp_addextendedproperty @name = N'MS_Description',
--		@value = N'Concurrency Field',
--		@level0type = N'SCHEMA',
--		@level0name = N'dbo',
--		@level1type = N'TABLE',
--		@level1name = N'tblICInventoryReceiptItemLot',
--		@level2type = N'COLUMN',
--		@level2name = N'intConcurrencyId'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Parent Lot',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'strParentLotId'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Lot',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'strLotId'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Cost',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'dblCost'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Storage Location Id',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'intStorageLocationId'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Condition',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'strCondition'
--GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Certified',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblICInventoryReceiptItemLot',
--    @level2type = N'COLUMN',
--    @level2name = N'dtmCertified'