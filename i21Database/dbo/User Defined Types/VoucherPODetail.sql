CREATE TYPE [dbo].[VoucherPODetail] AS TABLE
(
	[intBillId]						INT             NULL,
    [strMiscDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]					NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]					INT             NULL,
	[intItemId]						INT             NULL,
	[intPurchaseDetailId]			INT             NULL,
    [dblQtyReceived]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblCost]						DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intTaxGroupId]					INT NULL,
	[intLineNo]						INT DEFAULT 1
)
