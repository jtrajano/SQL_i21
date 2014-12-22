CREATE TABLE [dbo].[tblICInventoryShipmentItem]
(
	[intInventoryShipmentItemId] INT NOT NULL IDENTITY, 
	[intInventoryShipmentId] INT NOT NULL, 
    [strReferenceNumber] NVARCHAR(50) NULL, 
    [intItemId] INT NOT NULL, 
    [intSubLocationId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intUnitMeasureId] INT NOT NULL, 
    [intWeightUomId] INT NULL, 
    [dblTareWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dbNetWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intDockDoorId] INT NULL, 
    [strNotes] NVARCHAR(MAX) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryShipmentItem] PRIMARY KEY ([intInventoryShipmentItemId]), 
    CONSTRAINT [FK_tblICInventoryShipmentItem_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryShipmentItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
