﻿CREATE FUNCTION [dbo].[fnAPCreateVoucherPayableFromDetail]
(
	@voucherDetailIds AS Id READONLY,
	@integrationUpdate AS BIT = 0
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intBillId]							=	A.intBillId
		,[intEntityVendorId]				=	A.intEntityVendorId
		,[intTransactionType]				=	CASE WHEN A.intTransactionType = 16 THEN 1 ELSE A.intTransactionType END
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
		,[strBillOfLading]					=	B.strBillOfLading
		,[intAPAccount]						=	A.intAccountId
		,[strMiscDescription]				=	B.strMiscDescription
		,[intItemId]						=	B.intItemId
		,[ysnSubCurrency]					=	B.ysnSubCurrency
		,[intAccountId]						=	B.intAccountId
		,[ysnReturn]						=	CASE WHEN A.intTransactionType NOT IN (3, 11) THEN 0 ELSE 1 END
		,[intLineNo]						=	B.intLineNo
		,[intStorageLocationId]				=	B.intStorageLocationId
		,[dblBasis]							=	B.dblBasis
		,[dblFutures]						=	B.dblFutures
		,[intPurchaseDetailId]				=	B.intPurchaseDetailId
		,[intContractHeaderId]				=	B.intContractHeaderId
		,[intContractCostId]				=	B.intContractCostId
		,[intContractSeqId]					=	B.intContractSeq
		,[intContractDetailId]				=	B.intContractDetailId
		,[intPriceFixationDetailId]			=	B.intPriceFixationDetailId
		,[intInsuranceChargeDetailId]		=	B.intInsuranceChargeDetailId
		,[intStorageChargeId]				=	B.intStorageChargeId
		,[intScaleTicketId]					=	B.intScaleTicketId
		,[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]		=	B.intInventoryReceiptChargeId
		,[intInventoryShipmentItemId]		=	B.intItemId
		,[intInventoryShipmentChargeId]		=	B.intInventoryShipmentChargeId
		,[intLoadShipmentId]				=	B.intLoadId
		,[intLoadShipmentDetailId]			=	B.intLoadDetailId
		,[intLoadShipmentCostId]			=	B.intLoadShipmentCostId
		,[intWeightClaimId]					=	B.intWeightClaimId
		,[intWeightClaimDetailId]			=	B.intWeightClaimDetailId
		,[intPaycheckHeaderId]				=	B.intPaycheckHeaderId
		,[intCustomerStorageId]				=	B.intCustomerStorageId
		,[intSettleStorageId]				=	B.intSettleStorageId
		,[intCCSiteDetailId]				=	B.intCCSiteDetailId
		,[intInvoiceId]						=	B.intInvoiceId
		,[intBuybackChargeId]				=	B.intBuybackChargeId
		,[intLinkingId]						=	B.intLinkingId
		,[intComputeTotalOption]			=	B.intComputeTotalOption
		,[intLotId]							=	B.intLotId
		,[intTicketDistributionAllocationId]=	B.intTicketDistributionAllocationId
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
		,[intFreightTermId]					=	B.intFreightTermId
		,[ysnStage]							=	B.ysnStage
		,[intBillDetailId]					=	B.intBillDetailId
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherDetailIds C ON B.intBillDetailId = C.intId
	LEFT JOIN tblICInventoryReceiptItem D ON D.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	WHERE
	A.intTransactionType IN (1, 3, 11,16) AND
	1 = (CASE WHEN @integrationUpdate = 1 THEN 1 ELSE --ALWAYS INCLUDE VOUCHER DETAIL FOR INTEGRATION UPDATE
			(CASE WHEN ISNULL(D.ysnAddPayable, 1) <> 0 THEN 1 ELSE 0 END) 
		END) AND
	(
		B.intPurchaseDetailId > 0
		OR	B.intInventoryReceiptItemId > 0
		OR 	B.intInventoryReceiptChargeId > 0
		OR	B.intContractCostId > 0
		OR	B.intContractDetailId > 0
		OR	B.intLoadDetailId > 0
		OR	B.intLoadShipmentCostId > 0
		OR	B.intCustomerStorageId > 0
		OR	B.intSettleStorageId > 0
		OR	B.intPaycheckHeaderId > 0
		OR	B.intBuybackChargeId > 0
		OR	B.intScaleTicketId > 0
		OR	B.intInventoryShipmentChargeId > 0
		OR	B.intPriceFixationDetailId > 0
		OR	B.intInsuranceChargeDetailId > 0
		OR	B.intStorageChargeId > 0
		OR 	B.intWeightClaimDetailId > 0
	)
)

