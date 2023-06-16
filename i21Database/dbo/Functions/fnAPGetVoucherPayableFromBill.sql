CREATE FUNCTION [dbo].[fnAPGetVoucherPayableFromBill]
(
	@voucherIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intBillId]							=	A.intBillId
		,[intEntityVendorId]				=	A.intEntityVendorId
		,[intTransactionType]				=	A.intTransactionType
		,[intLocationId]					=	A.intStoreLocationId
		,[intShipToId]						=	A.intShipToId
		,[intShipFromId]					=	A.intShipFromId
		,[intShipFromEntityId]				=	A.intShipFromEntityId
		,[intPayToAddressId]				=	A.intPayToAddressId
		,[intCurrencyId]					=	A.intCurrencyId
		,[dtmDate]							=	A.dtmDate
		,[strVendorOrderNumber]				=	A.strVendorOrderNumber
		,[strReference]						=	A.strReference
		,[strSourceNumber]					=	NULL
		,[intSubCurrencyCents]				=	A.intSubCurrencyCents
		,[intShipViaId]						=	A.intShipViaId
		,[intTermId]						=	A.intTermsId
		,[strBillOfLading]					=	NULL
		,[intAPAccount]						=	A.intAccountId
		,[strMiscDescription]				=	B.strMiscDescription
		,[intItemId]						=	B.intItemId
		,[ysnSubCurrency]					=	B.ysnSubCurrency
		,[intAccountId]						=	B.intAccountId
		,[ysnReturn]						=	CASE WHEN A.intTransactionType != 3 THEN 0 ELSE 1 END
		,[intLineNo]						=	B.intLineNo
		,[intStorageLocationId]				=	B.intStorageLocationId
		,[dblBasis]							=	B.dblBasis
		,[dblFutures]						=	B.dblFutures
		,[intPurchaseDetailId]				=	B.intPurchaseDetailId
		,[intContractHeaderId]				=	B.intContractHeaderId
		,[intContractCostId]				=	B.intContractCostId
		,[intContractSeqId]					=	B.intContractSeq
		,[intContractDetailId]				=	B.intContractDetailId
		,[intScaleTicketId]					=	B.intScaleTicketId
		,[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]		=	B.intInventoryReceiptChargeId
		,[intInventoryShipmentItemId]		=	NULL
		,[intInventoryShipmentChargeId]		=	B.intInventoryShipmentChargeId
		,[intLoadShipmentId]				=	B.intLoadId
		,[intLoadShipmentDetailId]			=	B.intLoadDetailId
		,[intLoadHeaderId]					=	B.intLoadHeaderId
		,[intPaycheckHeaderId]				=	B.intPaycheckHeaderId
		,[intCustomerStorageId]				=	B.intCustomerStorageId
		,[intCCSiteDetailId]				=	B.intCCSiteDetailId
		,[intInvoiceId]						=	B.intInvoiceId
		,[intBuybackChargeId]				=	B.intBuybackChargeId
		,[dblOrderQty]						=	B.dblQtyOrdered
		,[dblOrderUnitQty]					=	B.dblUnitQty
		,[intOrderUOMId]					=	B.intUnitOfMeasureId
		,[dblQuantityToBill]				=	B.dblQtyReceived
		,[dblQtyToBillUnitQty]				=	B.dblUnitQty
		,[intQtyToBillUOMId]				=	B.intUnitOfMeasureId
		,[dblCost]							=	B.dblCost
		,[dblOldCost]						=	B.dblOldCost
		,[dblCostUnitQty]					=	B.dblCostUnitQty
		,[intCostUOMId]						=	B.intCostUOMId
		,[intCostCurrencyId]				=	B.intCurrencyId
		,[dblWeight]						=	B.dblWeight
		,[dblNetWeight]						=	B.dblNetWeight
		,[dblWeightUnitQty]					=	B.dblWeightUnitQty
		,[intWeightUOMId]					=	B.intWeightUOMId
		,[intCurrencyExchangeRateTypeId]	=	B.intCurrencyExchangeRateTypeId
		,[dblExchangeRate]					=	B.dblRate
		,[intPurchaseTaxGroupId]			=	B.intTaxGroupId
		,[dblTax]							=	B.dblTax
		,[dblDiscount]						=	A.dblDiscount
		,[dblDetailDiscountPercent]			=	B.dblDiscount
		,[ysnDiscountOverride]				=	A.ysnDiscountOverride
		,[intDeferredVoucherId]				=	B.intDeferredVoucherId
		,[dblPrepayPercentage]				=	B.dblPrepayPercentage
		,[intPrepayTypeId]					=	B.intPrepayTypeId
		,[dblNetShippedWeight]				=	B.dblNetShippedWeight
		,[dblWeightLoss]					=	B.dblWeightLoss
		,[dblFranchiseWeight]				=	B.dblFranchiseWeight
		,[dblFranchiseAmount]				=	B.dblFranchiseAmount
		,[dblActual]						=	B.dblActual
		,[dblDifference]					=	B.dblDifference
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherIds C ON A.intBillId = C.intId
)
