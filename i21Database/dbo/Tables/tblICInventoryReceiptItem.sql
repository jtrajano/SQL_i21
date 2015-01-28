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
		[intItemId] INT NOT NULL, 
		[dblOrderQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblOpenReceive] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblReceived] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intUnitMeasureId] INT NOT NULL, 
		[intNoPackages] INT NULL, 
		[intPackTypeId] INT NULL,
		[dblExpPackageWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblLineTotal] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICInventoryReceiptItem] PRIMARY KEY ([intInventoryReceiptItemId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryReceiptItem_tblICItemUOM] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
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