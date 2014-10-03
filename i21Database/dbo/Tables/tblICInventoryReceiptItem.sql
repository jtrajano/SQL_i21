CREATE TABLE [dbo].[tblICInventoryReceiptItem]
(
	[intInventoryReceiptItemId] INT NOT NULL IDENTITY, 
    [intLineNo] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [intNoPackages] INT NULL, 
    [dblExpPackageWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitRetail] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblLineTotal] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblGrossMargin] NUMERIC(18, 6) NULL DEFAULT ((0)), 

    CONSTRAINT [PK_tblICInventoryReceiptItem] PRIMARY KEY ([intInventoryReceiptItemId])
)
