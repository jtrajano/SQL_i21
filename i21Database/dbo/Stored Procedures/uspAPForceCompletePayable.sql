/**
	Use this script when we want the partially vouchered payable move to complete table.
*/
CREATE PROCEDURE [dbo].[uspAPForceCompletePayable]
	@voucherPayable AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY,
	@throwError BIT = 1,
	@error NVARCHAR(1000) = NULL OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @deleted TABLE(intVoucherPayableId INT, intNewPayableId INT, intVoucherPayableKey INT);
DECLARE @taxDeleted TABLE(intVoucherPayableId INT);
DECLARE @validPayables AS VoucherPayable
DECLARE @payablesKey TABLE(intOldPayableId int, intNewPayableId int);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPForceCompletePayable';

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF NOT EXISTS(
	SELECT TOP 1 1
		FROM tblAPVoucherPayable A
		INNER JOIN @voucherPayable C
			ON	A.intTransactionType = C.intTransactionType
			AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
			AND ISNULL(C.intSettleStorageId,-1) = ISNULL(A.intSettleStorageId,-1)
			AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
	)
BEGIN
	IF @throwError = 1
	BEGIN
		RAISERROR('One of the record do not exists in tblAPVoucherPayable.', 16, 1);
		RETURN;
	END
END
BEGIN TRY

	INSERT INTO @payablesKey(intOldPayableId, intNewPayableId)
	SELECT
		intOldPayableId
		,intNewPayableId
	FROM dbo.fnAPGetPayableKeyInfo(@voucherPayable)
	
	--FILTER VALID PAYABLES
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherValidForcePayables')) DROP TABLE #tmpVoucherValidForcePayables

	--ADD THOSE PARTIALLY VOUCHERED ONLY
	SELECT
		C.*
	INTO #tmpVoucherValidForcePayables
	FROM tblAPVoucherPayable B
	INNER JOIN @payablesKey B2
		ON B.intVoucherPayableId = B2.intNewPayableId
	INNER JOIN @voucherPayable C
		ON B2.intOldPayableId = C.intVoucherPayableId
	WHERE B.dblQuantityBilled != 0

	--REMOVE NOT PARTIALLY VOUCHERED
	DELETE A
	FROM @payablesKey A
	WHERE A.intOldPayableId NOT IN (
		SELECT intVoucherPayableId FROM #tmpVoucherValidForcePayables
	)

	ALTER TABLE #tmpVoucherValidForcePayables DROP COLUMN intVoucherPayableId
	INSERT INTO @validPayables
	SELECT * FROM #tmpVoucherValidForcePayables

	IF NOT EXISTS(SELECT 1 FROM @validPayables)
	BEGIN
		--IF NO VALID PARTIAL PAYABLES
		RETURN;
	END

	--UPDATE THE dblQuantityToBill to 0 before moving to completed table
	UPDATE B
		SET B.dblQuantityToBill = 0
	FROM tblAPVoucherPayable B
	INNER JOIN @payablesKey B2
		ON B.intVoucherPayableId = B2.intNewPayableId
	INNER JOIN @validPayables C
		ON B2.intOldPayableId = C.intVoucherPayableId

	UPDATE A
		SET A.dblTax = taxData.dblTax, A.dblAdjustedTax = taxData.dblAdjustedTax
	FROM tblAPVoucherPayableTaxStaging A
	INNER JOIN @payablesKey A2
		ON A.intVoucherPayableId = A2.intNewPayableId
	INNER JOIN @validPayables B
		ON A2.intOldPayableId = B.intVoucherPayableId
	INNER JOIN tblAPVoucherPayable C
		ON A2.intNewPayableId = C.intVoucherPayableId
	CROSS APPLY (
		SELECT
			*
		FROM dbo.fnAPRecomputeStagingTaxes(A.intVoucherPayableId, B.dblCost, C.dblQuantityToBill) taxes
		WHERE A.intTaxCodeId = taxes.intTaxCodeId AND A.intTaxGroupId = taxes.intTaxGroupId
	) taxData

	MERGE INTO tblAPVoucherPayableCompleted AS destination
		USING (
			SELECT
				B.intTransactionType
				,B.[intEntityVendorId]				
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
				,B.[intPriceFixationDetailId]			
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
				,B.[intLoadShipmentCostId]	
				,B.[intCustomerStorageId]	
				,B.[intSettleStorageId]
				,B.[intItemId]						
				,B.[strItemNo]						
				,B.[intPurchaseTaxGroupId]			
				,B.[strTaxGroup]			
				,B.[intItemLocationId]			
				,B.[strItemLocationName]		
				,B.[intStorageLocationId]			
				,B.[strStorageLocationName]		
				,B.[intSubLocationId]			
				,B.[strSubLocationName]				
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
				,B.[dbl1099]
				,B.[str1099Type]					
				,B.[ysnReturn]	
				,B.[intVoucherPayableId]
				,C.intOldPayableId AS intVoucherPayableKey
			FROM tblAPVoucherPayable B
			INNER JOIN @payablesKey C
				ON B.intVoucherPayableId = C.intNewPayableId
			WHERE B.dblQuantityToBill = 0
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT (
			[intTransactionType]
			,[intEntityVendorId]				
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
			,[intPriceFixationDetailId]	
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
			,[intLoadShipmentCostId]	
			,[intCustomerStorageId]	
			,[intSettleStorageId]
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intItemLocationId]			
			,[strItemLocationName]	
			,[intStorageLocationId]			
			,[strStorageLocationName]	
			,[intSubLocationId]			
			,[strSubLocationName]					
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
			,[dbl1099]			
			,[str1099Type]					
			,[ysnReturn]		
		)
		VALUES (
			[intTransactionType]
			,[intEntityVendorId]				
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
			,[intPriceFixationDetailId]			
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
			,[intLoadShipmentCostId]	
			,[intCustomerStorageId]	
			,[intSettleStorageId]
			,[intItemId]						
			,[strItemNo]						
			,[intPurchaseTaxGroupId]			
			,[strTaxGroup]					
			,[intItemLocationId]			
			,[strItemLocationName]	
			,[intStorageLocationId]			
			,[strStorageLocationName]	
			,[intSubLocationId]			
			,[strSubLocationName]						
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
			,[dbl1099]			
			,[str1099Type]					
			,[ysnReturn]			
		)
		OUTPUT
			SourceData.intVoucherPayableId,
			inserted.intVoucherPayableId,
			SourceData.intVoucherPayableKey
		INTO @deleted;

		--Back up taxes with 0 tax amount
		MERGE INTO tblAPVoucherPayableTaxCompleted AS destination
		USING (
			SELECT
				del.[intNewPayableId]
				,taxes.intVoucherPayableId
				,taxes.[intTaxGroupId]				
				,taxes.[intTaxCodeId]				
				,taxes.[intTaxClassId]				
				,taxes.[strTaxableByOtherTaxes]	
				,taxes.[strCalculationMethod]		
				,taxes.[dblRate]					
				,taxes.[intAccountId]				
				,taxes.[dblTax]					
				,taxes.[dblAdjustedTax]			
				,taxes.[ysnTaxAdjusted]			
				,taxes.[ysnSeparateOnBill]			
				,taxes.[ysnCheckOffTax]			
				,taxes.[ysnTaxOnly]
				,taxes.[ysnTaxExempt]
			FROM tblAPVoucherPayableTaxStaging taxes
			INNER JOIN @deleted del ON taxes.intVoucherPayableId = del.intVoucherPayableId
			WHERE taxes.dblTax = 0
		) AS SourceData
		 --handle key clashing, there could be already payable id exists on tax completed
		ON (destination.intVoucherPayableId = SourceData.intNewPayableId)
		WHEN MATCHED THEN
		UPDATE 
			SET 
			[intTaxGroupId]				=	SourceData.intTaxGroupId,				
			[intTaxCodeId]				=	SourceData.intTaxCodeId,				
			[intTaxClassId]				=	SourceData.intTaxClassId,		
			[strTaxableByOtherTaxes]	=	SourceData.strTaxableByOtherTaxes,
			[strCalculationMethod]		=	SourceData.strCalculationMethod,
			[dblRate]					=	SourceData.dblRate,
			[intAccountId]				=	SourceData.intAccountId,
			[dblTax]					=	SourceData.dblTax,
			[dblAdjustedTax]			=	SourceData.dblAdjustedTax,
			[ysnTaxAdjusted]			=	SourceData.ysnTaxAdjusted,
			[ysnSeparateOnBill]			=	SourceData.ysnSeparateOnBill,
			[ysnCheckOffTax]			=	SourceData.ysnCheckOffTax,
			[ysnTaxOnly]				=	SourceData.ysnTaxOnly,
			[ysnTaxExempt]				=	SourceData.ysnTaxExempt
		WHEN NOT MATCHED THEN
		INSERT (
			[intVoucherPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		)
		VALUES (
			[intNewPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]			
			,[ysnTaxOnly]
			,[ysnTaxExempt]
		)
		OUTPUT 
			SourceData.intVoucherPayableId
		INTO @taxDeleted;

		--if post, remove if the available qty is 0
		DELETE A
		FROM tblAPVoucherPayable A
		INNER JOIN @deleted B ON A.intVoucherPayableId = B.intVoucherPayableId

		DELETE A
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @taxDeleted B ON A.intVoucherPayableId = B.intVoucherPayableId

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

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END