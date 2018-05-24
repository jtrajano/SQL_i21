/**
	NOTES:
	[intInventoryReceiptType]
	1 = Direct
	2 = Purchase Contract
	3 = Purchase Order
	[dblQtyReceived]
	Quantity UOM should always be as the receipt qty UOM
**/
CREATE TYPE [dbo].[VoucherDetailReceipt] AS TABLE
(
	[intInventoryReceiptType]		INT				NOT NULL,
	/*Start - Bund Item Info*/
	[intItemBundleId]				INT				NULL, --Primary key of tblICItemBundle
	[intBundletUOMId]				INT				NULL,
	[dblQtyBundleReceived]			INT				NULL,
	[dblBundleUnitQty]				DECIMAL(38, 20)	NULL, 
	/*End - Bund Item Info*/
	[intInventoryReceiptItemId]		INT				NOT NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT NULL,
	PRIMARY KEY CLUSTERED ([intInventoryReceiptItemId] ASC) 
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Inventory Receipt Type',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailReceipt',
	@level2type = N'COLUMN',
	@level2name = N'intInventoryReceiptType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Inventory Receipt Item Id.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailReceipt',
	@level2type = N'COLUMN',
	@level2name = N'intInventoryReceiptItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Quantity to bill. Default to remaining quantity to bill for receipt item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailReceipt',
	@level2type = N'COLUMN',
	@level2name = N'dblQtyReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Cost to bill the item. Default to the unit cost of inventory receipt item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailReceipt',
	@level2type = N'COLUMN',
	@level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Tax group id to use when billing. Will override the taxes from inventory receipt item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailReceipt',
	@level2type = N'COLUMN',
	@level2name = N'intTaxGroupId'
GO