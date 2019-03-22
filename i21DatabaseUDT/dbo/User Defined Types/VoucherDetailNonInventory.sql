CREATE TYPE [dbo].[VoucherDetailNonInventory] AS TABLE
(
    [intAccountId]					INT             NULL,
	[intItemId]						INT             NULL,
	[strMiscDescription]			NVARCHAR(500)	NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblDiscount]					DECIMAL(18, 6)	NOT NULL DEFAULT 0, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT             NULL,
	[intInvoiceId]					INT             NULL
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Account to use on voucher transaction. Default to general account setup of item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Item Id.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Miscellaneous description.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'strMiscDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Quantity received. Default to minimum order setup of item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'dblQtyReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Discount percentage to apply to item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'dblDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Cost of item. Default to cost on purchase. Default to last cost setup of item',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Tax group id to apply for the item. Default to item tax setup.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'intTaxGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Invoice Id used for Pay Out.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherDetailNonInventory',
	@level2type = N'COLUMN',
	@level2name = N'intInvoiceId'
GO