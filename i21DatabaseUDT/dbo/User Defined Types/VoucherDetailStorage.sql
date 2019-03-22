CREATE TYPE [dbo].[VoucherDetailStorage] AS TABLE
(
	[intCustomerStorageId]		INT NULL,
	[intScaleTicketId]			INT NULL,
	[intInventoryReceiptItemId] INT NULL,
	[intItemId]					INT	NOT NULL,
	[intAccountId]				INT	NULL,
	[dblQtyReceived]			DECIMAL(18, 6)	NOT NULL, 
	[strMiscDescription]		NVARCHAR(500)	NULL, 
    [dblCost]					DECIMAL(38, 20)	NOT NULL,
	[intContractHeaderId]		INT NULL,
	[intContractDetailId]		INT NULL,
	[intUnitOfMeasureId] 		INT NULL,
	[intCostUOMId] 				INT NULL,
	[intWeightUOMId] 			INT NULL,
	[dblWeightUnitQty] 			DECIMAL(18, 6)	NOT NULL,
    [dblCostUnitQty] 			DECIMAL(38, 20)	NOT NULL,
    [dblUnitQty] 				DECIMAL(18, 6)	NOT NULL,
    [dblNetWeight] 				DECIMAL(18, 6)	NOT NULL
)