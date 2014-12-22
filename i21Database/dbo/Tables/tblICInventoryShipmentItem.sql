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

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryShipmentItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Shipment Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryShipmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'strReferenceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUomId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'dbNetWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dock Door Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intDockDoorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'strNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'