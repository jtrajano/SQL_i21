CREATE TABLE [dbo].[tblICInventoryAdjustmentDetail]
(
	[intInventoryAdjustmentDetailId] INT NOT NULL IDENTITY, 
    [intInventoryAdjustmentId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intSubLocationId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [intLotId] INT NULL, 
    [intNewLotId] INT NULL, 
    [dblNewQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intNewItemUOMId] INT NULL, 
	[intWeightUOMId] INT NULL,
	[dblGrossWeight] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblTareWeight] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblNewWeightPerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [intNewItemId] INT NULL, 
    [dblNewPhysicalCount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dtmNewExpiryDate] DATETIME NULL, 
    [intNewLotStatusId] INT NULL, 
    [intAccountCategoryId] INT NULL, 
    [intCreditAccountId] INT NULL, 
    [intDebitAccountId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryAdjustmentDetail] PRIMARY KEY ([intInventoryAdjustmentDetailId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICInventoryAdjustment] FOREIGN KEY ([intInventoryAdjustmentId]) REFERENCES [tblICInventoryAdjustment]([intInventoryAdjustmentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_NewItem] FOREIGN KEY ([intNewItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_NewLot] FOREIGN KEY ([intNewLotId]) REFERENCES [tblICLot]([intLotId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICItemUOM] FOREIGN KEY ([intNewItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblICLotStatus] FOREIGN KEY ([intNewLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_tblGLAccountCategory] FOREIGN KEY ([intAccountCategoryId]) REFERENCES [tblGLAccountCategory]([intAccountCategoryId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_DebitAccount] FOREIGN KEY ([intDebitAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_CreditAccount] FOREIGN KEY ([intCreditAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentDetail_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)

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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intAccountCategoryId'
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
    @value = N'New Weight Per Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblNewWeightPerUnit'
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
    @value = N'New Physical Count',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblNewPhysicalCount'
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
    @value = N'Credit Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intCreditAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Debit Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryAdjustmentDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDebitAccountId'
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
