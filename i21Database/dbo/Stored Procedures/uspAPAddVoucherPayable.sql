CREATE PROCEDURE [dbo].[uspAPAddVoucherPayable]
	@voucherPayable AS VoucherPayable READONLY,
	@throwError BIT = 0,
	@error NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPAddVoucherPayable';
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF EXISTS(SELECT TOP 1 1 FROM @voucherPayable)
BEGIN
	INSERT INTO tblAPVoucherPayable(
		[intVoucherPayableId]			
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
		,[intContractSeqId]				
		,[strContractNumber]				
		,[intScaleTicketId]				
		,[strScaleTicketNumber]			
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		
		,[intItemId]						
		,[strItemNo]						
		,[intPurchaseTaxGroupId]			
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
		,[dblRate]						
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
		,[str1099Form]					
		,[str1099Type]					
	)
	SELECT
		[intVoucherPayableId]				=
		,[intEntityVendorId]				=
		,[strVendorId]						=
		,[strName]							=
		,[intLocationId]					=
		,[strLocationName] 					=
		,[intCurrencyId]					=
		,[strCurrency]						=
		,[dtmDate]							=
		,[strReference]						=
		,[strSourceNumber]					=
		,[intPurchaseDetailId]				=
		,[strPurchaseOrderNumber]			=
		,[intContractHeaderId]				=
		,[intContractDetailId]				=
		,[intContractSeqId]					=
		,[strContractNumber]				=
		,[intScaleTicketId]					=
		,[strScaleTicketNumber]				=
		,[intInventoryReceiptItemId]		=
		,[intInventoryReceiptChargeId]		=
		,[intLoadShipmentId]				=
		,[intLoadShipmentDetailId]			=
		,[intItemId]						=
		,[strItemNo]						=
		,[intPurchaseTaxGroupId]			=
		,[strMiscDescription]				=
		,[dblOrderQty]						=	
		,[dblOrderUnitQty]					=
		,[intOrderUOMId]					=
		,[strOrderUOM]						=
		,[dblQuantityToBill]				=
		,[dblQtyToBillUnitQty]				=
		,[intQtyToBillUOMId]				=
		,[strQtyToBillUOM]					=
		,[dblCost]							=
		,[dblCostUnitQty]					=
		,[intCostUOMId]						=
		,[strCostUOM]						=
		,[dblNetWeight]						=
		,[dblWeightUnitQty]					=
		,[intWeightUOMId]					=
		,[strWeightUOM]						=
		,[intCostCurrencyId]				=
		,[strCostCurrency]					=
		,[dblTax]							=
		,[dblRate]							=
		,[ysnSubCurrency]					=
		,[intSubCurrencyCents]				=
		,[intAccountId]						=
		,[strAccountId]						=
		,[strAccountDesc]					=
		,[intShipViaId]						=
		,[strShipVia]						=
		,[intTermId]						=
		,[strTerm]							=	term.strTerm
		,[strBillOfLading]					=	A.strBillOfLading
		,[int1099Form]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
															AND A.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
														WHEN vendor.str1099Form = '1099-MISC' THEN 1
														WHEN vendor.str1099Form = '1099-INT' THEN 2
														WHEN vendor.str1099Form = '1099-B' THEN 3
												ELSE 0
												END,
		,[int1099Category]					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
															AND A.intItemId > 0
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
														THEN 3
												ELSE
													ISNULL(F.int1099CategoryId,0)
												END,
		,[str1099Form]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																AND item.ysn1099Box3 = 1
																AND patron.ysnStockStatusQualified = 1 
																THEN '1099 PATR'
														ELSE vendor.str1099Form	END
		,[str1099Type]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																AND item.ysn1099Box3 = 1
																AND patron.ysnStockStatusQualified = 1 
																THEN 'Per-unit retain allocations'
															ELSE vendor.str1099Type END
	FROM @voucherPayable A
	INNER JOIN tblAPVendor vendor ON A.intEntityVendorId = vendor.intEntityId
	LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
	LEFT JOIN tblSMTerm term ON term.intTermID = A.intTermId
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

	SET @error = @ErrorMessage;
	
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH
