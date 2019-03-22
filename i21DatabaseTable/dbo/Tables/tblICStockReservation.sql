CREATE TABLE [dbo].[tblICStockReservation]
(
	[intStockReservationId] INT NOT NULL IDENTITY 
    ,[intItemId] INT NOT NULL 
	,[intLocationId] INT NOT NULL 
    ,[intItemLocationId] INT NOT NULL 
    ,[intItemUOMId] INT NOT NULL
	,[intLotId] INT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT ((0))
	,[intParentLotId] INT NULL
    ,[intTransactionId] INT NULL
    ,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intSort] INT NULL
	,[intInventoryTransactionType] INT NULL
    ,[intConcurrencyId] INT NULL DEFAULT ((0))
	,[ysnPosted] BIT NULL DEFAULT((0))
	,[intCompanyId] INT NULL
    ,[dtmDateCreated] DATETIME NULL
    ,[dtmDateModified] DATETIME NULL
    ,[intCreatedByUserId] INT NULL
    ,[intModifiedByUserId] INT NULL
    ,CONSTRAINT [PK_tblICStockReservation] PRIMARY KEY ([intStockReservationId])
    ,CONSTRAINT [FK_tblICStockReservation_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblICStockReservation_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
    ,CONSTRAINT [FK_tblICStockReservation_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
    ,CONSTRAINT [FK_tblICStockReservation_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
GO 

CREATE NONCLUSTERED INDEX [IX_tblICStockReservation]
	ON [dbo].[tblICStockReservation]([intItemId] ASC, [intLocationId] ASC, [intItemLocationId] ASC, [intItemUOMId] ASC, [intLotId] ASC, [intSubLocationId] ASC, [intStorageLocationId] ASC)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intStockReservationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intItemLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'dblQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transaction Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intTransactionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transaction Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'strTransactionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStockReservation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'