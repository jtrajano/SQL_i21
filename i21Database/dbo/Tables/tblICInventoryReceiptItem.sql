/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptItem]
	(
		[intInventoryReceiptItemId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptId] INT NOT NULL, 
		[intLineNo] INT NOT NULL, 
		[intSourceId] INT NULL,
		[intItemId] INT NOT NULL, 
		[intSubLocationId] INT NOT NULL,
		[dblOrderQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblOpenReceive] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblReceived] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intUnitMeasureId] INT NOT NULL, 
		[intNoPackages] INT NULL, 
		[intPackageTypeId] INT NULL,
		[dblExpPackageWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblLineTotal] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICInventoryReceiptItem] PRIMARY KEY ([intInventoryReceiptItemId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICItemUOM] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICUnitMeasure] FOREIGN KEY ([intPackageTypeId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]) ON DELETE NO ACTION
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Package Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intPackageTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Qauantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblOrderQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity to Receive',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblOpenReceive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Received',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of Packages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intNoPackages'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Exp Package Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblExpPackageWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblLineTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'