CREATE TABLE [dbo].[tblICInventoryShipmentItemLot]
(
	[intInventoryShipmentItemLotId] INT NOT NULL IDENTITY, 
	[intInventoryShipmentItemId] INT NOT NULL, 
    [intLotId] INT NOT NULL, 
    [dblQuantityShipped] NUMERIC(18, 6) NULL, 
    [strWhseCargoNumber] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryShipmentItemLot] PRIMARY KEY ([intInventoryShipmentItemLotId]), 
    CONSTRAINT [FK_tblICInventoryShipmentItemLot_tblICInventoryShipmentItem] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [tblICInventoryShipmentItem]([intInventoryShipmentItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryShipmentItemLot_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
)
