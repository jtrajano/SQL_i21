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
	[intInventoryShipmentChargeId] = NULL,
	[intInventoryReceiptChargeId] = NULL,
	--[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
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
	[strTaxCode]				=	D.strTaxCode
FROM tblICInventoryReceiptItemTax A
INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
INNER JOIN tblSMTaxCode D ON D.intTaxCodeId = A.intTaxCodeId
WHERE C.strReceiptType IN ('Direct','Purchase Contract','Inventory Return')
UNION ALL
--PURCHASE ORDER ITEM RECEIPT
SELECT
	[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
	[intPurchaseDetailId]		=	B.intLineNo,
	[intInventoryShipmentChargeId] = NULL,
	[intInventoryReceiptChargeId] = NULL,
	--[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
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
	[strTaxCode]				=	D.strTaxCode
FROM tblICInventoryReceiptItemTax A
INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
INNER JOIN tblSMTaxCode D ON D.intTaxCodeId = A.intTaxCodeId
WHERE C.strReceiptType = 'Purchase Order'
UNION ALL
--PO MISCELLANEOUS
SELECT
	[intInventoryReceiptItemId]	=	NULL,
	[intPurchaseDetailId]		=	B.intPurchaseDetailId,
	[intInventoryShipmentChargeId] = NULL,
	[intInventoryReceiptChargeId] = NULL,
	--[intTaxGroupMasterId]		=	A.intTaxGroupMasterId, 
	[intTaxGroupId]				=	A.intTaxGroupId, 
	[intTaxCodeId]				=	A.intTaxCodeId, 
	[intTaxClassId]				=	A.intTaxClassId, 
	[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
	[strCalculationMethod]		=	A.strCalculationMethod, 
	[dblRate]					=	A.dblRate, 
	[intAccountId]				=	A.intAccountId, 
	[dblTax]					=	A.dblTax, 
	[dblAdjustedTax]			=	ISNULL(A.dblAdjustedTax,0), 
	[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
	[ysnSeparateOnBill]			=	A.ysnSeparateOnBill, 
	[ysnCheckOffTax]			=	A.ysnCheckOffTax,
	[strTaxCode]				=	D.strTaxCode
FROM tblPOPurchaseDetailTax A
INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
INNER JOIN tblSMTaxCode D ON D.intTaxCodeId = A.intTaxCodeId
WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
UNION ALL
-- INVENTORY SHIPMENT CHARGES
SELECT DISTINCT
		[intInventoryReceiptItemId]	= NULL,
		[intPurchaseDetailId]		= NULL,
		[intInventoryShipmentChargeId] = A.intInventoryShipmentChargeId,
		[intInventoryReceiptChargeId] = NULL,
		[intTaxGroupId]				= (CASE WHEN VST.intTaxGroupId > 0 THEN VST.intTaxGroupId
											WHEN CL.intTaxGroupId  > 0 THEN CL.intTaxGroupId 
											WHEN EL.intTaxGroupId > 0 THEN EL.intTaxGroupId ELSE 0 END),
		[intTaxCodeId]				= Taxes.intTaxCodeId,
		[intTaxClassId]				= Taxes.intTaxClassId,
		[strTaxableByOtherTaxes]	= Taxes.strTaxableByOtherTaxes COLLATE Latin1_General_CI_AS,
		[strCalculationMethod]		= Taxes.strCalculationMethod COLLATE Latin1_General_CI_AS,
		[dblRate]					= Taxes.dblRate,
		[intAccountId]				= D.intSalesTaxAccountId,
		[dblTax]					= Taxes.dblTax,
		[dblAdjustedTax]			= ISNULL(Taxes.dblAdjustedTax,0),
		[ysnTaxAdjusted]			= Taxes.ysnTaxAdjusted,
		[ysnSeparateOnBill]			= Taxes.ysnSeparateOnInvoice,
		[ysnCheckOffTax]			= Taxes.ysnCheckoffTax,
		[strTaxCode]				= D.strTaxCode
	FROM vyuICShipmentChargesForBilling A
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	INNER JOIN dbo.tblICItem I ON I.intItemId = A.intItemId
	LEFT JOIN dbo.tblEMEntityLocation EL ON A.intEntityVendorId = EL.intEntityId AND D1.intShipFromId = EL.intEntityLocationId
	LEFT JOIN dbo.tblAPVendorSpecialTax VST ON VST.intEntityVendorId = A.intEntityVendorId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId  FROM tblSMUserRoleCompanyLocationPermission)
	LEFT JOIN tblICCategoryTax B ON I.intCategoryId = B.intCategoryId
	LEFT JOIN tblSMTaxClass C ON B.intTaxClassId = C.intTaxClassId 
	LEFT JOIN tblSMTaxCode D ON D.intTaxClassId = C.intTaxClassId 
	OUTER APPLY fnGetItemTaxComputationForVendor(A.intItemId, A.intEntityVendorId, A.dtmDate, A.dblUnitCost, 1, (CASE WHEN VST.intTaxGroupId > 0 THEN VST.intTaxGroupId
																													  WHEN CL.intTaxGroupId  > 0 THEN CL.intTaxGroupId 
																													  WHEN EL.intTaxGroupId > 0  THEN EL.intTaxGroupId ELSE 0 END), CL.intCompanyLocationId, D1.intShipFromId , 0, NULL, 0) Taxes
	WHERE Taxes.intTaxCodeId IS NOT NULL																													
UNION ALL
--INVENTORY CHARGES

--INVENTORY CHARGES
SELECT DISTINCT
		[intInventoryReceiptItemId]	= NULL,
		[intPurchaseDetailId]		= NULL,
		[intInventoryShipmentChargeId] = NULL,
		[intInventoryReceiptChargeId] = A.intInventoryReceiptChargeId,
		[intTaxGroupId]				= A.intTaxGroupId,
		[intTaxCodeId]				= A.intTaxCodeId,
		[intTaxClassId]				= A.intTaxClassId,
		[strTaxableByOtherTaxes]	= A.strTaxableByOtherTaxes COLLATE Latin1_General_CI_AS,
		[strCalculationMethod]		= A.strCalculationMethod COLLATE Latin1_General_CI_AS,
		[dblRate]					= A.dblRate,
		[intAccountId]				= A.intTaxAccountId,
		[dblTax]					= A.dblTax,
		[dblAdjustedTax]			= A.dblAdjustedTax,
		[ysnTaxAdjusted]			= A.ysnTaxAdjusted,
		[ysnSeparateOnBill]			= 'false',
		[ysnCheckOffTax]			= A.ysnCheckoffTax,
		[strTaxCode]				= A.strTaxCode
	FROM tblICInventoryReceiptChargeTax A
) Items
GO