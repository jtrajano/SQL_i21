CREATE TYPE [dbo].[VoucherDetailDirectInventory] AS TABLE
(
    [intAccountId]					INT             NULL,
	[intItemId]						INT             NULL,
	[strMiscDescription]			NVARCHAR(500)	NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblDiscount]					DECIMAL(18, 6)	NOT NULL DEFAULT 0, 
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT             NULL,
	[intInvoiceId]					INT             NULL,
	[intScaleTicketId]				INT				NULL
)