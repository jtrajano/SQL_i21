CREATE TABLE [dbo].[tblICStorageLocationSku]
(
	[intStorageLocationSkuId] INT NOT NULL IDENTITY, 
    [intStorageLocationId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intSkuId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intContainerId] INT NULL, 
    [intLotCodeId] INT NULL, 
    [intLotStatusId] INT NULL, 
    [intOwnerId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICStorageLocationSku] PRIMARY KEY ([intStorageLocationSkuId]), 
    CONSTRAINT [FK_tblICStorageLocationSku_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [FK_tblICStorageLocationSku_tblICSku] FOREIGN KEY ([intSkuId]) REFERENCES [tblICSku]([intSKUId]), 
    CONSTRAINT [FK_tblICStorageLocationSku_tblICContainer] FOREIGN KEY ([intContainerId]) REFERENCES [tblICContainer]([intContainerId]), 
    CONSTRAINT [FK_tblICStorageLocationSku_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICStorageLocationSku_tblICLotStatus] FOREIGN KEY ([intLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationSkuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SKU Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intSkuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Container Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intContainerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intLotCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intLotStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Owner Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intOwnerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationSku',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'