--This will create voucher payable for existing data
--PO MISC
INSERT INTO tblAPVoucherPayable(
	[intEntityVendorId]						,
	[strReference]							,
	[strSourceNumber]						,
	[strBillOfLading]						,
	[intTransactionCode]					,
	[intPurchaseDetailId]					,
	[intInventoryReceiptItemId]				,
	[intInventoryReceiptChargeId]			,
	[intScaleTicketNumber]					,
	[intAccountId]							,
	[intItemId]								,
	[intShipViaId]							,
	[intTermId]								,
	[intContractDetailId]					,
	[intContractHeaderId]					,
	[dblReceivedQty]						,
	[dblInvoicedQty]						,
	[dblToInvoiceQty]						,
	[dblTax]								,
	[dblUniCost]							
)
SELECT
	[intEntityVendorId]					=	A.intEntityVendorId,
	[strReference]						=	A.strReference,
	[strSourceNumber]					=	A.strPurchaseOrderNumber,
	[strBillOfLading]					=	NULL,
	[intTransactionCode]				=	1, --PO
	[intPurchaseDetailId]				=	B.intPurchaseDetailId,
	[intInventoryReceiptItemId]			=	NULL,
	[intInventoryReceiptChargeId]		=	NULL,
	[intScaleTicketNumber]				=	NULL,
	[intAccountId]						=	[dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing'),
	[intItemId]							=	B.intItemId,
	[intShipViaId]						=	A.intShipViaId,
	[intTermId]							=	A.intTermsId,
	[intContractDetailId]				=	B.intContractDetailId,
	[intContractHeaderId]				=	B.intContractHeaderId,
	[dblReceivedQty]					=	B.dblQtyReceived,
	[dblInvoicedQty]					=	B.dblQtyReceived,
	[dblToInvoiceQty]					=	B.dblQtyOrdered - B.dblQtyReceived,
	[dblTax]							=	B.dblTax,
	[dblUniCost]						=	B.dblCost
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
AND B.dblQtyOrdered != B.dblQtyReceived