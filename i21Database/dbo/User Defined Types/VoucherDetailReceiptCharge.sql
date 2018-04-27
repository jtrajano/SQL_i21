CREATE TYPE [dbo].[VoucherDetailReceiptCharge] AS TABLE
(
	[intInventoryReceiptChargeId]	INT				NOT NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT NULL,
	PRIMARY KEY CLUSTERED ([intInventoryReceiptChargeId] ASC) 
)
GO