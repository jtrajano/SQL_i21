CREATE FUNCTION [dbo].[fnAPGetVoucherDetailReceiptTax]
(
	@intInventoryReceiptItemId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intTaxGroupId]				=	A.intTaxGroupId, 
		[intTaxCodeId]				=	A.intTaxCodeId, 
		[intTaxClassId]				=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]		=	A.strCalculationMethod, 
		[dblRate]					=	A.dblRate, 
		[intAccountId]				=	A.intTaxAccountId, 
		[dblTax]					=	A.dblTax, 
		[dblAdjustedTax]			=	ISNULL(A.dblAdjustedTax,0), 
		[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]			=	A.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]			=	A.ysnCheckoffTax,
		[strTaxCode]				=	D.strTaxCode,
		[ysnTaxOnly]				=	A.ysnTaxOnly
	FROM tblICInventoryReceiptItemTax A
	INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	--INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
	INNER JOIN tblSMTaxCode D ON D.intTaxCodeId = A.intTaxCodeId
	WHERE B.intInventoryReceiptItemId = @intInventoryReceiptItemId
)
