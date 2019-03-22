CREATE FUNCTION [dbo].[fnAPCreateVoucherDetailData]
(
	@billDetailData AS VoucherDetailData READONLY
)
RETURNS @returntable TABLE(
	[intBillId]						INT             NULL,
    [strMiscDescription]			NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]					INT             NULL ,
	[intItemId]						INT             NULL,
	[intInventoryReceiptItemId]		INT             NULL,
	[intInventoryReceiptChargeId]   INT             NULL,
	[intPurchaseDetailId]			INT             NULL,
	[intContractHeaderId]			INT             NULL,
	[intContractDetailId]			INT             NULL,
	[intPrepayTypeId]				INT             NULL,
    [dblTotal]						DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblQtyContract]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblContractCost]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyOrdered]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblCost]						DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblTax]						DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPrepayPercentage]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [int1099Form]					INT NOT NULL DEFAULT 0 , 
    [int1099Category]				INT NOT NULL DEFAULT 0 , 
	[ysn1099Printed]				BIT NULL DEFAULT 0 ,
    [intLineNo]						INT NOT NULL DEFAULT 1,
    [intTaxGroupId]					INT NULL
)
AS
BEGIN

	INSERT @returntable
	SELECT
		[intBillId]							=	A.intBillId,
		[strMiscDescription]				=	A.strMiscDescription,
		[strComment]						=	A.strComment,
		[intAccountId]						=	A.intAccountId,
		[intItemId]							=	A.intItemId,
		[intInventoryReceiptItemId]			=	A.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]   	=	A.intInventoryReceiptChargeId,
		[intPurchaseDetailId]				=	A.intPurchaseDetailId,
		[intContractHeaderId]				=	A.intContractHeaderId,
		[intContractDetailId]				=	A.intContractDetailId,
		[intPrepayTypeId]					=	A.intPrepayTypeId,
		[dblTotal]							=	(A.dblCost * A.dblQtyReceived) - ((A.dblCost * A.dblQtyReceived) * (A.dblDiscount / 100)),
		[dblQtyContract]					=	0,	
		[dblContractCost]					=	0,
		[dblQtyOrdered]						=	A.dblQtyReceived,
		[dblQtyReceived]					=	A.dblQtyReceived,
		[dblDiscount]						=	A.dblDiscount,
		[dblCost]							=	A.dblCost,
		[dblTax]							=	0,
		[dblPrepayPercentage]				=	A.dblPrepayPercentage,
		[int1099Form]						=	A.int1099Form,
		[int1099Category]					=	A.int1099Category,
		[ysn1099Printed]					=	0,
		[intLineNo]							=	0,
		[intTaxGroupId]						=	A.intTaxGroupId
	FROM @billDetailData A

	RETURN;
END
