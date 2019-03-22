CREATE TYPE [dbo].[VoucherDetailDirectInventory] AS TABLE
(
    [intAccountId]					INT             NULL,
	[intItemId]						INT             NULL,
	[strMiscDescription]			NVARCHAR(500)	NULL,
    [intUnitOfMeasureId]            INT             NULL,
    [dblQtyReceived]				DECIMAL(18, 6)	NULL, 
    [dblUnitQty]                    DECIMAL(38, 20)	NULL, 
    [dblDiscount]					DECIMAL(18, 6)	NOT NULL DEFAULT 0, 
    [intCostUOMId]                  INT             NULL,
    [dblCost]						DECIMAL(38, 20)	NULL, 
    [dblCostUnitQty]                DECIMAL(38, 20)	NULL, 
    [intTaxGroupId]					INT             NULL,
	[intInvoiceId]					INT             NULL,
    [intContractDetailId]           INT             NULL,
    [intLoadDetailId]               INT             NULL,
	[intScaleTicketId]				INT				NULL
)