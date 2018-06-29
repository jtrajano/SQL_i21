CREATE TYPE [dbo].[VoucherPODetail] AS TABLE
(
    [intAccountId]					INT             NULL,
	[intPurchaseDetailId]			INT             NOT NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblDiscount]					DECIMAL(18, 6)	NULL DEFAULT 0, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT NULL,
	PRIMARY KEY CLUSTERED ([intPurchaseDetailId] ASC)  
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Account to use on voucher transaction. Default to vendor expense account setup of item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Purchase Order Detail primary key.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'intPurchaseDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Quantity received. Default to item ordered less received.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'dblQtyReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Discount percentage to apply to item.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'dblDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Cost of item. Default to cost on purchase.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
	@value = N'Tax group id to apply for the item. Default to item tax setup.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TYPE',
	@level1name = N'VoucherPODetail',
	@level2type = N'COLUMN',
	@level2name = N'intTaxGroupId'
GO