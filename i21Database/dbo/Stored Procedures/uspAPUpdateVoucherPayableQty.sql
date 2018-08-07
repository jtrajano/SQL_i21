CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayableQty]
	@voucherIds AS Id READONLY,
	@post BIT = 0
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

	UPDATE B
		SET B.dblQuantityToBill = CASE WHEN @post = 0 THEN (B.dblQuantityToBill + C.dblQtyReceived) 
									ELSE (B.dblQuantityToBill - C.dblQtyReceived) END
	FROM tblAPVoucherPayable B
	LEFT JOIN tblAPBillDetail C
		ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
		AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
		AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
		AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
		AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
		AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
		AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
	WHERE C.intBillId IN (SELECT intId FROM @voucherIds)

	IF @post = 1
	BEGIN
		--if post, remove if the available qty is 0
		--back up to tblAPVoucherPayableCompleted
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
				,C.intBillDetailId
			FROM tblAPVoucherPayable B
			LEFT JOIN tblAPBillDetail C
			ON ISNULL(C.intPurchaseDetailId,1) = ISNULL(B.intPurchaseDetailId,1)
				AND ISNULL(C.intContractDetailId,1) = ISNULL(B.intContractDetailId,1)
				AND ISNULL(C.intScaleTicketId,1) = ISNULL(B.intScaleTicketId,1)
				AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(B.intInventoryReceiptChargeId,1)
				AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(B.intInventoryReceiptItemId,1)
				AND ISNULL(C.intLoadDetailId,1) = ISNULL(B.intLoadShipmentDetailId,1)
				AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(B.intInventoryShipmentChargeId,1)
			WHERE C.intBillId IN (SELECT intId FROM @voucherIds)
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
			,[intBillDetailId]				
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
			,[intBillDetailId]						
		)
		OUTPUT
			SourceData.intVoucherPayableId
		INTO @deleted;

		DELETE A
		FROM tblAPVoucherPayable A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId
	END
	ELSE
	BEGIN
		--if unpost and the record were already removed because it has 0 qty, re-insert
		MERGE INTO tblAPVoucherPayable AS destination
		USING (
			SELECT
				D.[intEntityVendorId]					
				,D.[intLocationId]					
				,D.[intCurrencyId]					
				,D.[dtmDate]							
				,D.[strReference]						
				,D.[strSourceNumber]					
				,D.[intPurchaseDetailId]				
				,D.[intContractHeaderId]				
				,D.[intContractDetailId]				
				,D.[intContractSeqId]					
				,D.[intScaleTicketId]					
				,D.[intInventoryReceiptItemId]		
				,D.[intInventoryReceiptChargeId]		
				,D.[intInventoryShipmentItemId]		
				,D.[intInventoryShipmentChargeId]		
				,D.[intLoadShipmentId]				
				,D.[intLoadShipmentDetailId]			
				,D.[intItemId]						
				,D.[intPurchaseTaxGroupId]			
				,D.[strMiscDescription]				
				,D.[dblOrderQty]						
				,D.[dblOrderUnitQty]					
				,D.[intOrderUOMId]					
				,D.[dblQuantityToBill]				
				,D.[dblQtyToBillUnitQty]				
				,D.[intQtyToBillUOMId]				
				,D.[dblCost]							
				,D.[dblCostUnitQty]					
				,D.[intCostUOMId]						
				,D.[dblNetWeight]						
				,D.[dblWeightUnitQty]					
				,D.[intWeightUOMId]					
				,D.[intCostCurrencyId]				
				,D.[dblTax]							
				,D.[intCurrencyExchangeRateTypeId]	
				,D.[dblExchangeRate]					
				,D.[ysnSubCurrency]					
				,D.[intSubCurrencyCents]				
				,D.[intAccountId]						
				,D.[intShipViaId]						
				,D.[intTermId]						
				,D.[strBillOfLading]					
			FROM tblAPBillDetail A
			INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			INNER JOIN @voucherIds C ON B.intBillId = C.intId
			INNER JOIN tblAPVoucherPayableCompleted D ON A.intBillDetailId = D.intBillDetailId
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
		OUTPUT inserted.intVoucherPayableId INTO @deleted;

		DELETE A
		FROM tblAPVoucherPayableCompleted A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId
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