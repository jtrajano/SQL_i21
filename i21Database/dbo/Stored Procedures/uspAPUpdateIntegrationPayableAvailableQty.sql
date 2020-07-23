CREATE PROCEDURE [dbo].[uspAPUpdateIntegrationPayableAvailableQty]
	@billDetailIds AS Id READONLY
	,@decrease BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPUpdateIntegrationPayableAvailableQty';
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @decreaseQty BIT = @decrease;
DECLARE @transCount INT = @@TRANCOUNT;

INSERT INTO @voucherPayables(
	[intBillId]
	,[intEntityVendorId]				
	,[intTransactionType]				
	,[intLocationId]					
	,[intShipToId]						
	,[intShipFromId]					
	,[intShipFromEntityId]				
	,[intPayToAddressId]				
	,[intCurrencyId]					
	,[dtmDate]							
	,[strVendorOrderNumber]				
	,[strReference]						
	,[strSourceNumber]					
	,[intSubCurrencyCents]				
	,[intShipViaId]						
	,[intTermId]						
	,[strBillOfLading]					
	,[intAPAccount]						
	,[strMiscDescription]				
	,[intItemId]						
	,[ysnSubCurrency]					
	,[intAccountId]						
	,[ysnReturn]						
	,[intLineNo]						
	,[intStorageLocationId]				
	,[dblBasis]							
	,[dblFutures]						
	,[intPurchaseDetailId]				
	,[intContractHeaderId]				
	,[intContractCostId]				
	,[intContractSeqId]					
	,[intContractDetailId]				
	,[intScaleTicketId]					
	,[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]		
	,[intInventoryShipmentItemId]		
	,[intInventoryShipmentChargeId]		
	,[intLoadShipmentId]				
	,[intLoadShipmentDetailId]			
	,[intPaycheckHeaderId]				
	,[intCustomerStorageId]		
	,[intSettleStorageId]		
	,[intCCSiteDetailId]				
	,[intInvoiceId]						
	,[intBuybackChargeId]				
	,[dblOrderQty]						
	,[dblOrderUnitQty]					
	,[intOrderUOMId]					
	,[dblQuantityToBill]				
	,[dblQtyToBillUnitQty]				
	,[intQtyToBillUOMId]				
	,[dblCost]							
	,[dblOldCost]						
	,[dblCostUnitQty]					
	,[intCostUOMId]						
	,[intCostCurrencyId]				
	,[dblWeight]						
	,[dblNetWeight]						
	,[dblWeightUnitQty]					
	,[intWeightUOMId]					
	,[intCurrencyExchangeRateTypeId]	
	,[dblExchangeRate]					
	,[intPurchaseTaxGroupId]			
	,[dblTax]							
	,[dblDiscount]						
	,[dblDetailDiscountPercent]			
	,[ysnDiscountOverride]				
	,[intDeferredVoucherId]				
	,[dblPrepayPercentage]				
	,[intPrepayTypeId]					
	,[dblNetShippedWeight]				
	,[dblWeightLoss]					
	,[dblFranchiseWeight]				
	,[dblFranchiseAmount]				
	,[dblActual]						
	,[dblDifference]					
)
SELECT
	[intBillId]
	,[intEntityVendorId]				
	,[intTransactionType]				
	,[intLocationId]					
	,[intShipToId]						
	,[intShipFromId]					
	,[intShipFromEntityId]				
	,[intPayToAddressId]				
	,[intCurrencyId]					
	,[dtmDate]							
	,[strVendorOrderNumber]				
	,[strReference]						
	,[strSourceNumber]					
	,[intSubCurrencyCents]				
	,[intShipViaId]						
	,[intTermId]						
	,[strBillOfLading]					
	,[intAPAccount]						
	,[strMiscDescription]				
	,[intItemId]						
	,[ysnSubCurrency]					
	,[intAccountId]						
	,[ysnReturn]						
	,[intLineNo]						
	,[intStorageLocationId]				
	,[dblBasis]							
	,[dblFutures]						
	,[intPurchaseDetailId]				
	,[intContractHeaderId]				
	,[intContractCostId]				
	,[intContractSeqId]					
	,[intContractDetailId]				
	,[intScaleTicketId]					
	,[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]		
	,[intInventoryShipmentItemId]		
	,[intInventoryShipmentChargeId]		
	,[intLoadShipmentId]				
	,[intLoadShipmentDetailId]			
	,[intPaycheckHeaderId]				
	,[intCustomerStorageId]		
	,[intSettleStorageId]		
	,[intCCSiteDetailId]				
	,[intInvoiceId]						
	,[intBuybackChargeId]				
	,[dblOrderQty]						
	,[dblOrderUnitQty]					
	,[intOrderUOMId]					
	,[dblQuantityToBill]				
	,[dblQtyToBillUnitQty]				
	,[intQtyToBillUOMId]				
	,[dblCost]							
	,[dblOldCost]						
	,[dblCostUnitQty]					
	,[intCostUOMId]						
	,[intCostCurrencyId]				
	,[dblWeight]						
	,[dblNetWeight]						
	,[dblWeightUnitQty]					
	,[intWeightUOMId]					
	,[intCurrencyExchangeRateTypeId]	
	,[dblExchangeRate]					
	,[intPurchaseTaxGroupId]			
	,[dblTax]							
	,[dblDiscount]						
	,[dblDetailDiscountPercent]			
	,[ysnDiscountOverride]				
	,[intDeferredVoucherId]				
	,[dblPrepayPercentage]				
	,[intPrepayTypeId]					
	,[dblNetShippedWeight]				
	,[dblWeightLoss]					
	,[dblFranchiseWeight]				
	,[dblFranchiseAmount]				
	,[dblActual]						
	,[dblDifference]
FROM dbo.fnAPCreateVoucherPayableFromDetail(@billDetailIds)
WHERE ysnStage = 1

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

BEGIN --MISC PO ITEM
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpMiscPOPayables')) DROP TABLE #tmpMiscPOPayables

	SELECT * 
	INTO #tmpMiscPOPayables
	FROM @voucherPayables WHERE intPurchaseDetailId > 0 AND intInventoryReceiptItemId IS NULL

	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @voucherPayablesMiscPO AS VoucherPayable;
		DECLARE @descreasePO BIT = ~@decreaseQty
		ALTER TABLE #tmpMiscPOPayables DROP COLUMN intVoucherPayableId
		INSERT INTO @voucherPayablesMiscPO
		SELECT * FROM #tmpMiscPOPayables
		EXEC uspPOReceivedMiscItem @voucherPayables = @voucherPayablesMiscPO, @decrease = @descreasePO

		--decrease on order qty for po misc item
		DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType
		INSERT INTO @ItemToUpdateOnOrderQty (
			dtmDate
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,dblQty
			,dblUOMQty
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
		)
		SELECT
			dtmDate						=	A.dtmDate
			,intItemId					=	A.intItemId
			,intItemLocationId			=	loc.intItemLocationId
			,intItemUOMId				=	B.intUnitOfMeasureId
			,intSubLocationId			=	B.intStorageLocationId
			,dblQty						=	CASE WHEN @decreaseQty = 1 
												THEN A.dblQuantityToBill
											ELSE -A.dblQuantityToBill
											END
			,dblUOMQty					=	A.dblQtyToBillUnitQty
			,intTransactionId			=	B.intBillId
			,intTransactionDetailId		=	B.intBillDetailId
			,strTransactionId			=	B2.strBillId
			,intTransactionTypeId		=	-1
		FROM @voucherPayables A
		INNER JOIN tblAPBill B2 
			ON A.intBillId = B2.intBillId
		INNER JOIN tblAPBillDetail B
			ON A.intBillId = B.intBillId
		INNER JOIN tblICItemLocation loc
			ON A.intItemId = loc.intItemId AND A.intShipToId = loc.intLocationId
		LEFT JOIN tblICItem C
			ON B.intItemId = C.intItemId
		WHERE 
			B.intPurchaseDetailId > 0 AND B.intUnitOfMeasureId > 0
		AND B.intInventoryReceiptItemId IS NULL
		AND (dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
		-- AND EXISTS 
		-- (
		-- 	--MAKE SURE TO CALL THE SP IF PO MISC ITEM IS ALREADY VOUCHERED
		-- 	SELECT 1
		-- 	FROM tblAPBillDetail B3
		-- 	WHERE B3.intPurchaseDetailId = B.intPurchaseDetailId
		-- 	AND B3.intBillDetailId != B.intBillDetailId
		-- )
		-- Call the stored procedure that updates the on order qty. 
		IF EXISTS(SELECT 1 FROM @ItemToUpdateOnOrderQty)
		BEGIN
			--NOTE: WE NEED TO REMOVE THIS WHEN WE ALLOW RECEIVING OF MISC ITEMS ON RECEIPT
			BEGIN TRY
				EXEC dbo.uspICIncreaseOnOrderQty @ItemToUpdateOnOrderQty
			END TRY
			BEGIN CATCH
				DECLARE @errorIncreaserOrderQty NVARCHAR(4000);
				SET @errorIncreaserOrderQty  = 'Error occurred on uspICIncreaseOnOrderQty. ' + ERROR_MESSAGE()
				RAISERROR(@errorIncreaserOrderQty, 16, 1);
			END CATCH
		END
	END
END

--INVENTORY RECEIPT
BEGIN 
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryReceipt')) DROP TABLE #tmpInventoryReceipt

	SELECT * 
	INTO #tmpInventoryReceipt
	FROM @voucherPayables 
	WHERE 
		(intInventoryReceiptItemId > 0)
	OR
		(intInventoryReceiptChargeId > 0)
	OR
		(intInventoryShipmentChargeId > 0)

	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @receiptDetails AS InventoryUpdateBillQty

		INSERT INTO @receiptDetails
		(
			[intInventoryReceiptItemId],
			[intInventoryReceiptChargeId],
			[intInventoryShipmentChargeId],
			[intSourceTransactionNoId],
			[strSourceTransactionNo],
			[intItemId],
			[intToBillUOMId],
			[dblToBillQty],
			[intEntityVendorId],
			[dblAmountToBill]
		)
		SELECT
			[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId,
			[intInventoryReceiptChargeId]	=	A.intInventoryReceiptChargeId,
			[intInventoryShipmentChargeId]	=	A.intInventoryShipmentChargeId,
			[intSourceTransactionNoId]		=	B.intBillId,
			[strSourceTransactionNo]		=	B.strBillId,
			[intItemId]						=	A.intItemId,
			[intToBillUOMId]				=	A.intQtyToBillUOMId,--CASE WHEN A.intWeightUOMId > 0 THEN A.intWeightUOMId ELSE A.intQtyToBillUOMId END,
			[dblToBillQty]					=	--A.dblQuantityToBill--CASE WHEN A.intWeightUOMId > 0 THEN A.dblNetWeight ELSE A.dblQuantityToBill END
												 (CASE WHEN @decreaseQty = 0 
														THEN -A.dblQuantityToBill
													ELSE A.dblQuantityToBill
													END),
			[intEntityVendorId]				=	B.intEntityVendorId,
			[dblAmountToBill]				=   
												CASE 
													WHEN @decreaseQty = 0 THEN 
														-ROUND(
															dbo.fnMultiply(
																CASE 
																	WHEN ISNULL(A.intCostUOMId, A.intQtyToBillUOMId) IS NOT NULL THEN 
																		dbo.fnCalculateCostBetweenUOM(
																			ISNULL(A.intCostUOMId, A.intQtyToBillUOMId)
																			,A.intQtyToBillUOMId
																			,A.dblCost
																		)
																	ELSE 
																		A.dblCost
																END
																,A.dblQuantityToBill --ABS(A.dblQuantityToBill)
															)
															,2 
														)														
													ELSE 
														ROUND(
															dbo.fnMultiply(
																CASE 
																	WHEN ISNULL(A.intCostUOMId, A.intQtyToBillUOMId) IS NOT NULL THEN
																		dbo.fnCalculateCostBetweenUOM(
																			ISNULL(A.intCostUOMId, A.intQtyToBillUOMId)
																			,A.intQtyToBillUOMId
																			,A.dblCost
																		)
																	ELSE 
																		A.dblCost
																END 
																,A.dblQuantityToBill --ABS(A.dblQuantityToBill)
															)
															,2 
														)
												END

		FROM #tmpInventoryReceipt A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId

		EXEC uspICUpdateBillQty @updateDetails = @receiptDetails
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
-- ELSE
-- 	BEGIN
-- 		IF (XACT_STATE()) = -1
-- 		BEGIN
-- 			ROLLBACK TRANSACTION  @SavePoint
-- 		END
-- 	END	
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
	-- ELSE
	-- 	BEGIN
	-- 		IF (XACT_STATE()) = -1 AND @transCount > 0
	-- 		BEGIN
	-- 			ROLLBACK TRANSACTION  @SavePoint
	-- 		END
	-- 	END	

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH