CREATE TABLE [dbo].[tblICStockReservation]
(
	[intStockReservationId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intItemLocationId] INT NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intTransactionId] INT NULL, 
    [strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICStockReservation] PRIMARY KEY ([intStockReservationId]), 
    CONSTRAINT [FK_tblICStockReservation_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICStockReservation_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]), 
    CONSTRAINT [FK_tblICStockReservation_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)

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
    @level2name = N'dblQuantity'
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