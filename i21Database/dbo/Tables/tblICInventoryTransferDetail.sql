﻿CREATE TABLE [dbo].[tblICInventoryTransferDetail]
(
	[intInventoryTransferDetailId] INT NOT NULL IDENTITY, 
    [intInventoryTransferId] INT NOT NULL, 
	[intSourceId] INT NULL,
    [intItemId] INT NOT NULL, 
    [intLotId] INT NULL, 
    [intFromSubLocationId] INT NULL, 
    [intToSubLocationId] INT NULL, 
    [intFromStorageLocationId] INT NULL, 
    [intToStorageLocationId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [intItemUOMId] INT NULL, 
    [intItemWeightUOMId] INT NULL, 
    [dblGrossWeight] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [dblTareWeight] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [intNewLotId] INT NULL, 
    [strNewLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strNewWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblCost] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [intTaxCodeId] INT NULL, 
    [dblFreightRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFreightAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intOwnershipType] INT NULL DEFAULT ((1)),
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[dblOriginalAvailableQty] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[dblOriginalStorageQty] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[ysnWeights] BIT NULL DEFAULT((0)),
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFromLocationActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strToLocationActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblGross] NUMERIC(38,20) NULL,
    [dblTare] NUMERIC(38,20) NULL,
    [dblNet] NUMERIC(38,20) NULL,
    [intNewLotStatusId] INT NULL,
    [intGrossNetUOMId] INT NULL,
    [dblGrossNetUnitQty] NUMERIC(38,20) NULL,
    [dblItemUnitQty] NUMERIC(38,20) NULL,
	[dblWeightPerQty] NUMERIC(38, 20) NULL,
	[strLotCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCostingMethod] INT NULL,    
    CONSTRAINT [PK_tblICInventoryTransferDetail] PRIMARY KEY ([intInventoryTransferDetailId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_tblICInventoryTransfer] FOREIGN KEY ([intInventoryTransferId]) REFERENCES [tblICInventoryTransfer]([intInventoryTransferId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryTransferDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_FromSubLocation] FOREIGN KEY ([intFromSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_ToSubLocation] FOREIGN KEY ([intToSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_FromStorageLocation] FOREIGN KEY ([intFromStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_ToStorageLocation] FOREIGN KEY ([intToStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_ItemWeightUOM] FOREIGN KEY ([intItemWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_NewLot] FOREIGN KEY ([intNewLotId]) REFERENCES [tblICLot]([intLotId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryTransferDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Transfer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryTransferId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'From Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intFromSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'To Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intToSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'From Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intFromStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'To Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intToStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeight'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intNewLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Lot Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'strNewLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblCost'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intTaxCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'