CREATE TYPE [dbo].[VoucherDetailData] AS TABLE
(
	[intBillId]						INT             NULL,
	[intTransactionCode]			INT				NOT NULL,
    [strMiscDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]					NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]					INT             NULL,
	[intItemId]						INT             NULL,
	[intInventoryReceiptItemId]		INT             NULL,
	[intInventoryReceiptChargeId]   INT             NULL,
	[intPurchaseDetailId]			INT             NULL,
	[intContractHeaderId]			INT             NULL,
	[intContractDetailId]			INT             NULL,
	[intPrepayTypeId]				INT             NULL,
    [dblQtyReceived]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblCost]						DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblPrepayPercentage]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[int1099Form]					INT NOT NULL DEFAULT 0, 
    [int1099Category]				INT NOT NULL DEFAULT 0, 
    [intTaxGroupId]					INT NULL
)