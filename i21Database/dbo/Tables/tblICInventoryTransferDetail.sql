CREATE TABLE [dbo].[tblICInventoryTransferDetail]
(
	[intInventoryTransferDetailId] INT NOT NULL IDENTITY, 
    [intInventoryTransferId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intLotId] INT NULL, 
    [intFromSubLocationId] INT NULL, 
    [intToSubLocationId] INT NULL, 
    [intFromStorageLocationId] INT NULL, 
    [intToStorageLocationId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intItemUOMId] INT NULL, 
    [intItemWeightUOMId] INT NULL, 
    [dblGrossWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTareWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblNetWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intNewLotId] INT NULL, 
    [strNewLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intCreditAccountId] INT NULL, 
    [intDebitAccountId] INT NULL, 
    [intTaxCodeId] INT NULL, 
    [dblFreightRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFreightAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
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
    CONSTRAINT [FK_tblICInventoryTransferDetail_CreditAccount] FOREIGN KEY ([intCreditAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblICInventoryTransferDetail_DebitAccount] FOREIGN KEY ([intDebitAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblNetWeight'
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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Credit Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intCreditAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Debit Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDebitAccountId'
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