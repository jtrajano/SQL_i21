﻿CREATE TABLE [dbo].[tblICInventoryReceiptItem]
(
	[intInventoryReceiptItemId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptId] INT NOT NULL, 
    [intLineNo] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [intNoPackages] INT NULL, 
    [dblExpPackageWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitRetail] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblLineTotal] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblGrossMargin] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceiptItem] PRIMARY KEY ([intInventoryReceiptItemId]), 
    CONSTRAINT [FK_tblICInventoryReceiptItem_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Receipt Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intLineNo'