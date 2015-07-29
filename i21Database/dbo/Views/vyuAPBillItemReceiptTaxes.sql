CREATE VIEW [dbo].[vyuAPBillItemReceiptTaxes]
AS
SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intPurchaseDetailId) AS INT) AS intBillItemReceiptTaxId
,Items.*
FROM (
--DIRECT RECEIPT, PURCHASE CONTRACT
SELECT
	[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
	[intPurchaseDetailId]		=	NULL,
	[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
	[intTaxGroupId]				=	A.intTaxGroupId, 
	[intTaxCodeId]				=	A.intTaxCodeId, 
	[intTaxClassId]				=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]		=	A.strCalculationMethod, 
	[dblRate]					=	A.dblRate, 
	[intAccountId]				=	A.intTaxAccountId, 
	[dblTax]					=	A.dblTax, 
	[dblAdjustedTax]			=	A.dblAdjustedTax, 
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]			=	A.ysnSeparateOnInvoice, 
	[ysnCheckOffTax]			=	A.ysnCheckoffTax
FROM tblICInventoryReceiptItemTax A
INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
WHERE C.strReceiptType IN ('Direct','Purchase Contract')
UNION ALL
--PURCHASE ORDER ITEM RECEIPT
SELECT
	[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
	[intPurchaseDetailId]		=	B.intLineNo,
	[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
	[intTaxGroupId]				=	A.intTaxGroupId, 
	[intTaxCodeId]				=	A.intTaxCodeId, 
	[intTaxClassId]				=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]		=	A.strCalculationMethod, 
	[dblRate]					=	A.dblRate, 
	[intAccountId]				=	A.intTaxAccountId, 
	[dblTax]					=	A.dblTax, 
	[dblAdjustedTax]			=	A.dblAdjustedTax, 
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]			=	A.ysnSeparateOnInvoice, 
	[ysnCheckOffTax]			=	A.ysnCheckoffTax
FROM tblICInventoryReceiptItemTax A
INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
WHERE C.strReceiptType = 'Purchase Order'
UNION ALL
--PO MISCELLANEOUS
SELECT
	[intInventoryReceiptItemId]	=	NULL,
	[intPurchaseDetailId]		=	B.intPurchaseDetailId,
	[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
	[intTaxGroupId]				=	A.intTaxGroupId, 
	[intTaxCodeId]				=	A.intTaxCodeId, 
	[intTaxClassId]				=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]		=	A.strCalculationMethod, 
	[dblRate]					=	A.dblRate, 
	[intAccountId]				=	A.intAccountId, 
	[dblTax]					=	A.dblTax, 
	[dblAdjustedTax]			=	A.dblAdjustedTax, 
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]			=	A.ysnSeparateOnBill, 
	[ysnCheckOffTax]			=	A.ysnCheckOffTax
FROM tblPOPurchaseDetailTax A
INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
) Items