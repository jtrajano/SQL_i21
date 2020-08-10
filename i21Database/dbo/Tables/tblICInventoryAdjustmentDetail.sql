CREATE TABLE [dbo].[tblICInventoryAdjustmentDetail]
(
	[intInventoryAdjustmentDetailId] INT NOT NULL IDENTITY, 
    [intInventoryAdjustmentId] INT NOT NULL, 
    [intSubLocationId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [intItemId] INT NULL,
	[intNewItemId] INT NULL,  
    [intLotId] INT NULL, 
    [intNewLotId] INT NULL, 
	[strNewLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblQuantity] NUMERIC(38, 20) NULL , 
    [dblNewQuantity] NUMERIC(38, 20) NULL , 
	[dblNewSplitLotQuantity] NUMERIC(38, 20) NULL , 
	[dblAdjustByQuantity] NUMERIC(38, 20) NULL , 
    [intItemUOMId] INT NULL, 
	[intNewItemUOMId] INT NULL, 
	[intWeightUOMId] INT NULL,
	[intNewWeightUOMId] INT NULL,
	[dblWeight] NUMERIC(38,20) NULL ,
	[dblNewWeight] NUMERIC(38, 20) NULL ,	
	[dblWeightPerQty] NUMERIC(38,20) NULL ,
	[dblNewWeightPerQty] NUMERIC(38,20) NULL ,      
	[dtmExpiryDate] DATETIME NULL, 
	[dtmNewExpiryDate] DATETIME NULL, 
	[intLotStatusId] INT NULL, 
    [intNewLotStatusId] INT NULL, 
	[dblCost] NUMERIC(38,20) NULL , 
	[dblNewCost] NUMERIC(38,20) NULL , 
	[intNewLocationId] INT NULL, 
	[intNewSubLocationId] INT NULL, 
	[intNewStorageLocationId] INT NULL, 
	[dblLineTotal] NUMERIC(38,20) NULL , 
	[intItemOwnerId] INT NULL,
	[intNewItemOwnerId] INT NULL, 
	[intOwnershipType] INT NULL DEFAULT((1)),
	[intCostingMethod] INT NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)),
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
    CONSTRAINT [PK_tblICInventoryAdjustmentDetail] PRIMARY KEY ([intInventoryAdjustmentDetailId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICInventoryAdjustment] FOREIGN KEY ([intInventoryAdjustmentId]) REFERENCES [tblICInventoryAdjustment]([intInventoryAdjustmentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItem_OldItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItem_NewItem] FOREIGN KEY ([intNewItemId]) REFERENCES [tblICItem]([intItemId]),	    
	CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItemUOM_OldItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItemUOM_NewItemUOM] FOREIGN KEY ([intNewItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItemUOM_OldWeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItemUOM_NewWeightUOM] FOREIGN KEY ([intNewWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLotStatus_OldLotStatus] FOREIGN KEY ([intLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]), 
	CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLotStatus_NewLotStatus] FOREIGN KEY ([intNewLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]) 

	-- Removed the following constraints because the source tables of these relationships can have no data. 
	-- Ex: Zero record at tblSMCompanyLocationSubLocation and NULL value on tblICInventoryAdjustmentDetail.intSubLocationId will throw a foreign key constraint error. 
	--CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),     
	--CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    --CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLot_OldLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
    --CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLot_NewLot] FOREIGN KEY ([intNewLotId]) REFERENCES [tblICLot]([intLotId]), 

)

GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryAdjustmentDetail_intInventoryAdjustmentId]
	ON [dbo].[tblICInventoryAdjustmentDetail]([intInventoryAdjustmentId] ASC)

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryAdjustmentDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Adjustment Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryAdjustmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intNewLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblNewQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intNewItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Weight Per Qty',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblNewWeightPerQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intNewItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Expiry Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dtmNewExpiryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Lot Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intNewLotStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intCostingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblWeight'