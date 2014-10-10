CREATE TABLE [dbo].[tblICInventoryReceiptItemTax]
(
	[intInventoryReceiptItemTaxId] INT NOT NULL , 
    [intInventoryReceiptItemId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [ysnSelected] BIT NOT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceiptItemTax] PRIMARY KEY ([intInventoryReceiptItemTaxId]), 
    CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptItemTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Receipt Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Selected',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'ysnSelected'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItemTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'