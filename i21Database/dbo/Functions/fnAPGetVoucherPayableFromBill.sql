CREATE FUNCTION [dbo].[fnAPGetVoucherPayableFromBill]
(
	@voucherIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intEntityVendorId]					=	A.intEntityVendorId
		,[intLocationId]					=	A.intShipToId
		,[intCurrencyId]					=	A.intCurrencyId
		,[dtmDate]							=	A.dtmDate
		,[strReference]						=	A.strReference
		,[strSourceNumber]					=	NULL
		,[intPurchaseDetailId]				=	B.intPurchaseDetailId
		,[intContractHeaderId]				=	B.intContractHeaderId
		,[intContractDetailId]				=	B.intContractDetailId
		,[intContractSeqId]					=	B.intContractSeq
		,[intScaleTicketId]					=	B.intScaleTicketId
		,[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]		=	B.intInventoryReceiptChargeId
		,[intInventoryShipmentItemId]		=	NULL
		,[intInventoryShipmentChargeId]		=	B.intInventoryShipmentChargeId
		,[intLoadShipmentId]				=	B.intLoadId
		,[intLoadShipmentDetailId]			=	B.intLoadDetailId
		,[intItemId]						=	B.intItemId
		,[intPurchaseTaxGroupId]			=	B.intTaxGroupId
		,[strMiscDescription]				=	B.strMiscDescription
		,[dblOrderQty]						=	B.dblQtyOrdered
		,[dblOrderUnitQty]					=	B.dblUnitQty
		,[intOrderUOMId]					=	B.intUnitOfMeasureId
		,[dblQuantityToBill]				=	B.dblQtyReceived
		,[dblQtyToBillUnitQty]				=	B.dblUnitQty
		,[intQtyToBillUOMId]				=	B.intUnitOfMeasureId
		,[dblCost]							=	B.dblCost
		,[dblCostUnitQty]					=	B.dblCostUnitQty
		,[intCostUOMId]						=	B.intCostUOMId
		,[dblNetWeight]						=	B.dblNetWeight
		,[dblWeightUnitQty]					=	B.dblWeightUnitQty
		,[intWeightUOMId]					=	B.intWeightUOMId
		,[intCostCurrencyId]				=	B.intCurrencyId
		,[dblTax]							=	B.dblTax
		,[dblDiscount]						=	B.dblDiscount
		,[intCurrencyExchangeRateTypeId]	=	B.intCurrencyExchangeRateTypeId
		,[dblExchangeRate]					=	B.dblRate
		,[ysnSubCurrency]					=	B.ysnSubCurrency
		,[intSubCurrencyCents]				=	A.intSubCurrencyCents
		,[intAccountId]						=	B.intAccountId
		,[intShipViaId]						=	A.intShipViaId
		,[intTermId]						=	A.intTermsId
		,[strBillOfLading]					=	NULL
		,[ysnReturn]						=	CASE WHEN A.intTransactionType != 3 THEN 0 ELSE 1 END
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherIds C ON A.intBillId = C.intId
)
