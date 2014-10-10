CREATE TABLE [dbo].[tblICInventoryReceiptItemLot]
(
	[intInventoryReceiptItemLotId] INT NOT NULL IDENTITY, 
    [intInventoryReceiptItemId] INT NOT NULL, 
    [strParentLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intUnits] INT NOT NULL DEFAULT ((0)), 
    [intUnitUOMId] INT NULL, 
    [intUnitPallet] INT NOT NULL DEFAULT ((0)), 
    [dblGrossWeight] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblTareWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intWeightUOMId] INT NOT NULL, 
    [dblStatedGrossPerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblStatedTarePerUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intStorageBinId] INT NOT NULL, 
    [intGarden] INT NULL, 
    [strGrade] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intOriginId] INT NULL, 
    [intSeasonCropYear] INT NULL, 
    [strVendorLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmManufacturedDate] DATETIME NULL, 
    [strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceiptItemLot] PRIMARY KEY ([intInventoryReceiptItemLotId]), 
    CONSTRAINT [FK_tblICInventoryReceiptItemLot_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptItemLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Receipt Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parent Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strParentLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Container Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strContainerNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit UOM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = 'intUnitUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units/Pallet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intUnitPallet'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight UOM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = 'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stated Gross Per Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblStatedGrossPerUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stated Tare Per Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dblStatedTarePerUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Bin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intStorageBinId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Garden',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intGarden'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grade',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strGrade'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Origin Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intOriginId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season / Crop Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intSeasonCropYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Lot Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strVendorLotId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufactured Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'dtmManufacturedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Remarks',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'strRemarks'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemLot',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'