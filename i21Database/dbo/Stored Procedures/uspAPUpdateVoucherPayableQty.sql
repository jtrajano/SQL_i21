CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayableQty]
	@voucherPayable AS VoucherPayable READONLY
	,@post BIT = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @deleted TABLE(intVoucherPayableId INT);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPUpdateVoucherPayableQty';
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

	--IF PAYABLE HAVE NEVER BEEN ADDED YET
	IF NOT EXISTS(
		SELECT TOP 1 1
			FROM tblAPVoucherPayable A
			INNER JOIN @voucherPayable C
				ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(A.intPurchaseDetailId,1)
				AND ISNULL(C.intContractDetailId,1) = ISNULL(A.intContractDetailId,1)
				AND ISNULL(C.intScaleTicketId,1) = ISNULL(A.intScaleTicketId,1)
				AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(A.intInventoryReceiptChargeId,1)
				AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(A.intInventoryReceiptItemId,1)
				--AND ISNULL(C.intInventoryShipmentItemId,1) = ISNULL(A.intInventoryShipmentItemId,1)
				AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(A.intInventoryShipmentChargeId,1)
				AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(A.intLoadShipmentDetailId,1)
				AND ISNULL(C.intEntityVendorId,1) = ISNULL(A.intEntityVendorId,1))
		AND NOT EXISTS(
			SELECT TOP 1 1
			FROM tblAPVoucherPayableCompleted A
			INNER JOIN @voucherPayable C
				ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(A.intPurchaseDetailId,1)
				AND ISNULL(C.intContractDetailId,1) = ISNULL(A.intContractDetailId,1)
				AND ISNULL(C.intScaleTicketId,1) = ISNULL(A.intScaleTicketId,1)
				AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(A.intInventoryReceiptChargeId,1)
				AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(A.intInventoryReceiptItemId,1)
				--AND ISNULL(C.intInventoryShipmentItemId,1) = ISNULL(A.intInventoryShipmentItemId,1)
				AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(A.intInventoryShipmentChargeId,1)
				AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(A.intLoadShipmentDetailId,1)
				AND ISNULL(C.intEntityVendorId,1) = ISNULL(A.intEntityVendorId,1))
	BEGIN
		EXEC uspAPAddVoucherPayable @voucherPayable = @voucherPayable, @throwError = 1
		RETURN;
	END

	IF @post = 1
	BEGIN
		--UPDATE THE QTY BEFORE DELETING
		--UPDATE QTY IF THERE ARE STILL QTY LEFT TO BILL	
		UPDATE B
			SET B.dblQuantityToBill = CASE WHEN @post = 0 THEN (B.dblQuantityToBill + C.dblQuantityToBill) 
										ELSE (B.dblQuantityToBill - C.dblQuantityToBill) END
		FROM tblAPVoucherPayable B
		INNER JOIN @voucherPayable C
		--LEFT JOIN (tblAPBillDetail C INNER JOIN tblAPBill C2 ON C.intBillId = C2.intBillId)
			ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
			AND ISNULL(C.intEntityVendorId,1) = ISNULL(B.intEntityVendorId,1)
			AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
			AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
			AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
			AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
			--AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
		--WHERE C.intBillId IN (SELECT intId FROM @voucherIds)
		--back up to tblAPVoucherPayableCompleted if qty to bill is 0
		MERGE INTO tblAPVoucherPayableCompleted AS destination
		USING (
			SELECT
				B.[intEntityVendorId]				
				,B.[strVendorId]					
				,B.[strName]						
				,B.[intLocationId]					
				,B.[strLocationName] 				
				,B.[intCurrencyId]					
				,B.[strCurrency]					
				,B.[dtmDate]						
				,B.[strReference]					
				,B.[strSourceNumber]				
				,B.[intPurchaseDetailId]			
				,B.[strPurchaseOrderNumber]		
				,B.[intContractHeaderId]			
				,B.[intContractDetailId]			
				,B.[intContractSeqId]				
				,B.[intContractCostId]				
				,B.[strContractNumber]				
				,B.[intScaleTicketId]				
				,B.[strScaleTicketNumber]			
				,B.[intInventoryReceiptItemId]		
				,B.[intInventoryReceiptChargeId]	
				,B.[intInventoryShipmentItemId]	
				,B.[intInventoryShipmentChargeId]
				,B.[intLoadShipmentId]				
				,B.[intLoadShipmentDetailId]		
				,B.[intItemId]						
				,B.[strItemNo]						
				,B.[intPurchaseTaxGroupId]			
				,B.[strTaxGroup]					
				,B.[intStorageLocationId]			
				,B.[strStorageLocationName]		
				,B.[strMiscDescription]			
				,B.[dblOrderQty]					
				,B.[dblOrderUnitQty]				
				,B.[intOrderUOMId]					
				,B.[strOrderUOM]					
				,B.[dblQuantityToBill]				
				,B.[dblQtyToBillUnitQty]			
				,B.[intQtyToBillUOMId]				
				,B.[strQtyToBillUOM]				
				,B.[dblCost]						
				,B.[dblCostUnitQty]				
				,B.[intCostUOMId]					
				,B.[strCostUOM]					
				,B.[dblNetWeight]					
				,B.[dblWeightUnitQty]				
				,B.[intWeightUOMId]				
				,B.[strWeightUOM]					
				,B.[intCostCurrencyId]				
				,B.[strCostCurrency]				
				,B.[dblTax]						
				,B.[dblDiscount]					
				,B.[intCurrencyExchangeRateTypeId]
				,B.[strRateType]					
				,B.[dblExchangeRate]				
				,B.[ysnSubCurrency]				
				,B.[intSubCurrencyCents]			
				,B.[intAccountId]					
				,B.[strAccountId]					
				,B.[strAccountDesc]				
				,B.[intShipViaId]					
				,B.[strShipVia]					
				,B.[intTermId]						
				,B.[strTerm]						
				,B.[strBillOfLading]				
				,B.[int1099Form]					
				,B.[str1099Form]					
				,B.[int1099Category]				
				,B.[str1099Type]					
				,B.[ysnReturn]	
				,B.[intVoucherPayableId]
			FROM tblAPVoucherPayable B
			LEFT JOIN @voucherPayable C
			ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
				AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
				AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
				AND ISNULL(C.intEntityVendorId,1) = ISNULL(B.intEntityVendorId,1)
				AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
				AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
				--AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
				AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
				AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
			--WHERE C.intBillId IN (SELECT intId FROM @voucherIds)
			AND B.dblQuantityToBill = 0
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]					
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]			
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]		
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intStorageLocationId]			
			,[strStorageLocationName]		
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]				
			,[str1099Type]					
			,[ysnReturn]		
		)
		VALUES (
			[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]					
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]			
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]		
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intStorageLocationId]			
			,[strStorageLocationName]		
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]				
			,[str1099Type]					
			,[ysnReturn]			
		)
		OUTPUT
			SourceData.intVoucherPayableId
		INTO @deleted;

		--if post, remove if the available qty is 0
		DELETE A
		FROM tblAPVoucherPayable A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId
	END
	ELSE IF @post = 0
	BEGIN
		--if unpost and the record were already removed because it has 0 qty, re-insert
		MERGE INTO tblAPVoucherPayable AS destination
		USING (
			SELECT
				D.[intEntityVendorId]				
				,D.[strVendorId]					
				,D.[strName]						
				,D.[intLocationId]					
				,D.[strLocationName] 				
				,D.[intCurrencyId]					
				,D.[strCurrency]					
				,D.[dtmDate]						
				,D.[strReference]					
				,D.[strSourceNumber]				
				,D.[intPurchaseDetailId]			
				,D.[strPurchaseOrderNumber]		
				,D.[intContractHeaderId]			
				,D.[intContractDetailId]			
				,D.[intContractSeqId]				
				,D.[intContractCostId]				
				,D.[strContractNumber]				
				,D.[intScaleTicketId]				
				,D.[strScaleTicketNumber]			
				,D.[intInventoryReceiptItemId]		
				,D.[intInventoryReceiptChargeId]	
				,D.[intInventoryShipmentItemId]	
				,D.[intInventoryShipmentChargeId]
				,D.[intLoadShipmentId]				
				,D.[intLoadShipmentDetailId]		
				,D.[intItemId]						
				,D.[strItemNo]						
				,D.[intPurchaseTaxGroupId]			
				,D.[strTaxGroup]					
				,D.[intStorageLocationId]			
				,D.[strStorageLocationName]		
				,D.[strMiscDescription]			
				,D.[dblOrderQty]					
				,D.[dblOrderUnitQty]				
				,D.[intOrderUOMId]					
				,D.[strOrderUOM]					
				,D.[dblQuantityToBill]				
				,D.[dblQtyToBillUnitQty]			
				,D.[intQtyToBillUOMId]				
				,D.[strQtyToBillUOM]				
				,D.[dblCost]						
				,D.[dblCostUnitQty]				
				,D.[intCostUOMId]					
				,D.[strCostUOM]					
				,D.[dblNetWeight]					
				,D.[dblWeightUnitQty]				
				,D.[intWeightUOMId]				
				,D.[strWeightUOM]					
				,D.[intCostCurrencyId]				
				,D.[strCostCurrency]				
				,D.[dblTax]						
				,D.[dblDiscount]					
				,D.[intCurrencyExchangeRateTypeId]
				,D.[strRateType]					
				,D.[dblExchangeRate]				
				,D.[ysnSubCurrency]				
				,D.[intSubCurrencyCents]			
				,D.[intAccountId]					
				,D.[strAccountId]					
				,D.[strAccountDesc]				
				,D.[intShipViaId]					
				,D.[strShipVia]					
				,D.[intTermId]						
				,D.[strTerm]						
				,D.[strBillOfLading]				
				,D.[int1099Form]					
				,D.[str1099Form]					
				,D.[int1099Category]				
				,D.[str1099Type]					
				,D.[ysnReturn]		
				,D.[intVoucherPayableId]			
			-- FROM tblAPBillDetail A
			-- INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			-- INNER JOIN @voucherIds C ON B.intBillId = C.intId
			FROM @voucherPayable B
			INNER JOIN tblAPVoucherPayableCompleted D --ON A.intBillDetailId = D.intBillDetailId
					ON ISNULL(D.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
			AND ISNULL(D.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
			AND ISNULL(D.intEntityVendorId,1) = ISNULL(B.intEntityVendorId,1)
			AND ISNULL(D.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
			AND ISNULL(D.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
			AND ISNULL(D.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
			--AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(D.intLoadShipmentDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(D.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]					
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]			
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]		
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intStorageLocationId]			
			,[strStorageLocationName]		
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]				
			,[str1099Type]					
			,[ysnReturn]	
		)
		VALUES(
			[intEntityVendorId]				
			,[strVendorId]					
			,[strName]						
			,[intLocationId]					
			,[strLocationName] 				
			,[intCurrencyId]					
			,[strCurrency]					
			,[dtmDate]						
			,[strReference]					
			,[strSourceNumber]				
			,[intPurchaseDetailId]			
			,[strPurchaseOrderNumber]		
			,[intContractHeaderId]			
			,[intContractDetailId]			
			,[intContractSeqId]				
			,[intContractCostId]				
			,[strContractNumber]				
			,[intScaleTicketId]				
			,[strScaleTicketNumber]			
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]	
			,[intInventoryShipmentItemId]	
			,[intInventoryShipmentChargeId]
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]		
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intStorageLocationId]			
			,[strStorageLocationName]		
			,[strMiscDescription]			
			,[dblOrderQty]					
			,[dblOrderUnitQty]				
			,[intOrderUOMId]					
			,[strOrderUOM]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]			
			,[intQtyToBillUOMId]				
			,[strQtyToBillUOM]				
			,[dblCost]						
			,[dblCostUnitQty]				
			,[intCostUOMId]					
			,[strCostUOM]					
			,[dblNetWeight]					
			,[dblWeightUnitQty]				
			,[intWeightUOMId]				
			,[strWeightUOM]					
			,[intCostCurrencyId]				
			,[strCostCurrency]				
			,[dblTax]						
			,[dblDiscount]					
			,[intCurrencyExchangeRateTypeId]
			,[strRateType]					
			,[dblExchangeRate]				
			,[ysnSubCurrency]				
			,[intSubCurrencyCents]			
			,[intAccountId]					
			,[strAccountId]					
			,[strAccountDesc]				
			,[intShipViaId]					
			,[strShipVia]					
			,[intTermId]						
			,[strTerm]						
			,[strBillOfLading]				
			,[int1099Form]					
			,[str1099Form]					
			,[int1099Category]				
			,[str1099Type]					
			,[ysnReturn]	
		)
		OUTPUT SourceData.intVoucherPayableId INTO @deleted;

		DELETE A
		FROM tblAPVoucherPayableCompleted A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		--UPDATE QTY AFTER REINSERTING
		--UPDATE QTY IF THERE ARE STILL QTY LEFT TO BILL	
		UPDATE B
			SET B.dblQuantityToBill = CASE WHEN @post = 0 THEN (B.dblQuantityToBill + C.dblQuantityToBill) 
										ELSE (B.dblQuantityToBill - C.dblQuantityToBill) END
		FROM tblAPVoucherPayable B
		INNER JOIN @voucherPayable C
		--LEFT JOIN (tblAPBillDetail C INNER JOIN tblAPBill C2 ON C.intBillId = C2.intBillId)
			ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
			AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
			AND ISNULL(C.intEntityVendorId,1) = ISNULL(B.intEntityVendorId,1)
			AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
			AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
			AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
			--AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
		--WHERE C.intBillId IN (SELECT intId FROM @voucherIds)
	END
	ELSE
	BEGIN

		--PROVISION ON EDITING THE VoucherPayable,
		--If allowed, what data will be allowed to edit?
		--Ex, if cost, it is not valid as there might be a voucher already created on that cost

		BEGIN
			-- --IF NOT VOUCHER POSTING, THE PROCEDURE WAS CALLED BY INTEGRATED MODULE, EDITED THE DATA
			-- UPDATE B
			-- 	SET B.dblQuantityToBill = C.dblQuantityToBill
			-- 	,B.dblCost = C.dblCost
			-- FROM tblAPVoucherPayable B
			-- INNER JOIN @voucherPayable C
			-- --LEFT JOIN (tblAPBillDetail C INNER JOIN tblAPBill C2 ON C.intBillId = C2.intBillId)
			-- 	ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
			-- 	AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
			-- 	AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
			-- 	AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
			-- 	AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
			-- 	--AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			-- 	AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			-- 	AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)

			-- --VALIDATE
			-- --QTY OF VOUCHER PAYABLE SHOULD NOT BE GREATER THAN THE QTY VOUCHERED
			-- DECLARE @overQtyError NVARCHAR(1000);
			-- SELECT TOP 1
			-- 	@overQtyError = C2.strBillId
			-- FROM tblAPBill C2 
			-- INNER JOIN tblAPBillDetail C ON C.intBillId = C2.intBillId
			-- INNER JOIN @voucherPayable B
			-- 	ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
			-- 	AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
			-- 	AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
			-- 	AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
			-- 	AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
			-- 	AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
			-- 	AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
			-- GROUP BY C.intPurchaseDetailId
			-- ,C.intContractDetailId
			-- ,C.intScaleTicketId
			-- ,C.intInventoryReceiptChargeId
			-- ,C.intInventoryReceiptItemId
			-- ,C.intLoadDetailId
			-- ,C.intInventoryShipmentChargeId
			-- ,C2.strBillId
			-- HAVING SUM(C.dblQtyReceived) > SUM(DISTINCT B.dblQuantityToBill)

			-- IF @overQtyError IS NOT NULL
			-- BEGIN
			-- 	SET @overQtyError = 'Unable to update the payable quantity. Please check the quantity of vouchers created.'
			-- 	RETURN;
			-- END

			EXEC uspAPRemoveVoucherPayable @voucherPayable = @voucherPayable, @throwError = 1
			EXEC uspAPAddVoucherPayable @voucherPayable = @voucherPayable, @throwError = 1
		END

	END

	IF @transCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION
		END
		ELSE IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION
		END
	END		
ELSE
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION  @SavePoint
		END
	END	
END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END