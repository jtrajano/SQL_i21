﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryShipmentItemLot]
	(
		[intInventoryShipmentItemLotId] INT NOT NULL IDENTITY, 
		[intInventoryShipmentItemId] INT NOT NULL, 
		[intLotId] INT NOT NULL, 
		[dblQuantityShipped] NUMERIC(38, 20) NULL, 
		[dblGrossWeight] NUMERIC(38, 20) NULL DEFAULT((0)),
		[dblTareWeight] NUMERIC(38, 20) NULL DEFAULT((0)),
		[dblWeightPerQty] NUMERIC(38, 20) NULL DEFAULT((0)),
		[strWarehouseCargoNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
		[dblDestinationQuantityShipped] NUMERIC(38, 20) NULL DEFAULT((0)),
		[dblDestinationGrossWeight] NUMERIC(38, 20) NULL DEFAULT((0)),
		[dblDestinationTareWeight] NUMERIC(38, 20) NULL DEFAULT((0)),
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL,
		[intSourceInventoryShipmentItemLotId] INT NULL, 
		CONSTRAINT [PK_tblICInventoryShipmentItemLot] PRIMARY KEY ([intInventoryShipmentItemLotId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItemLot_tblICInventoryShipmentItem] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [tblICInventoryShipmentItem]([intInventoryShipmentItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryShipmentItemLot_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId])
	)

	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipmentItemLot_intInventoryShipmentItemId]
		ON [dbo].[tblICInventoryShipmentItemLot]([intInventoryShipmentItemId] ASC)
		INCLUDE (intLotId)

	GO

	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryShipmentItemLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inventory Shipment Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryShipmentItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity Shipped',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantityShipped'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Warehouse Cargo Number',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = 'strWarehouseCargoNumber'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Gross Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblGrossWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tare Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItemLot',
		@level2type = N'COLUMN',
		@level2name = N'dblTareWeight'