CREATE FUNCTION [dbo].[fnAPCreatePOVoucherPayable]
(
	@poIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intEntityVendorId]					=	A.intEntityVendorId
		,[intLocationId]					=	A.intShipToId
		,[intCurrencyId]					=	A.intCurrencyId
		,[dtmDate]							=	A.dtmDate
		,[strReference]						=	A.strReference
		,[strSourceNumber]					=	A.strPurchaseOrderNumber
		,[intPurchaseDetailId]				=	B.intPurchaseDetailId
		,[intContractHeaderId]				=	B.intContractHeaderId
		,[intContractDetailId]				=	B.intContractDetailId
		,[intContractSeqId]					=	ctd.intContractSeq
		,[intScaleTicketId]					=	NULL
		,[intInventoryReceiptItemId]		=	NULL
		,[intInventoryReceiptChargeId]		=	NULL
		,[intInventoryShipmentItemId]		=	NULL
		,[intInventoryShipmentChargeId]		=	NULL
		,[intLoadShipmentId]				=	NULL
		,[intLoadShipmentDetailId]			=	NULL
		,[intItemId]						=	B.intItemId
		,[intPurchaseTaxGroupId]			=	B.intTaxGroupId
		,[strMiscDescription]				=	B.strMiscDescription
		,[dblOrderQty]						=	B.dblQtyOrdered
		,[dblOrderUnitQty]					=	B.dblUnitQty
		,[intOrderUOMId]					=	B.intUnitOfMeasureId
		,[dblQuantityToBill]				=	B.dblQtyOrdered
		,[dblQtyToBillUnitQty]				=	B.dblUnitQty
		,[intQtyToBillUOMId]				=	B.intUnitOfMeasureId
		,[dblCost]							=	B.dblCost
		,[dblCostUnitQty]					=	B.dblCostUnitQty
		,[intCostUOMId]						=	B.intCostUOMId
		,[dblNetWeight]						=	B.dblNetWeight
		,[dblWeightUnitQty]					=	B.dblWeightUnitQty
		,[intWeightUOMId]					=	B.intWeightUOMId
		,[intCostCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(subCurrency.intCurrencyID,0) ELSE A.intCurrencyId END
		,[dblTax]							=	B.dblTax
		,[intCurrencyExchangeRateTypeId]	=	B.intForexRateTypeId
		,[dblExchangeRate]					=	B.dblForexRate
		,[ysnSubCurrency]					=	B.ysnSubCurrency
		,[intSubCurrencyCents]				=	A.intSubCurrencyCents
		,[intAccountId]						=	CASE WHEN B.intItemId IS NULL THEN B.intAccountId
												ELSE ISNULL(B.intAccountId, [dbo].[fnGetItemGLAccount](B.intItemId, itemLoc.intItemLocationId, 'Other Charge Expense'))
												END
		,[intShipViaId]						=	A.intShipViaId
		,[intTermId]						=	A.intTermsId
		,[strBillOfLading]					=	NULL
		,[ysnReturn]						=	0
	FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN @poIds ids ON A.intPurchaseId = ids.intId
	INNER JOIN tblSMCurrency cur ON A.intCurrencyId = cur.intCurrencyID
	LEFT JOIN dbo.tblSMCurrency subCurrency ON subCurrency.intMainCurrencyId = A.intCurrencyId AND subCurrency.ysnSubCurrency = 1
	LEFT JOIN tblCTContractDetail ctd ON B.intContractDetailId = ctd.intContractDetailId
	LEFT JOIN tblICItemLocation itemLoc ON B.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = A.intShipToId
	
)
