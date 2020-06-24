CREATE PROCEDURE [dbo].[uspPOProcessItemReceipt]
	@poId INT
	,@userId INT
	,@receiveNonInventory BIT = 0
	,@dtmDate DATETIME
	,@receiptNumber NVARCHAR(50) OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @poDetailIds AS Id
DECLARE @SavePoint NVARCHAR(32) = 'uspPOProcessItemReceipt';

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

INSERT INTO @poDetailIds
SELECT intPurchaseDetailId FROM tblPOPurchaseDetail WHERE intPurchaseId = @poId

-- Validations
BEGIN TRY
	--Purchase order already closed.
	IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND intOrderStatusId = 3)
	BEGIN
		RAISERROR('Purchase Order already closed.', 16, 1)
		RETURN;
	END

	-- IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND dblTotal = 0)
	-- BEGIN
	-- 	RAISERROR('Cannot process Purchase Order with 0 amount.', 16, 1)
	-- 	RETURN;
	-- END

	--CHECK IF ALL QUANTITY ARE RECEIVED
	IF 
	(
		NOT EXISTS
		(
			SELECT 1 
			FROM tblPOPurchaseDetail A
			INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
			WHERE B.strType IN ('Non-Inventory', 'Finished Good', 'Raw Material') 
			-- WHERE strType NOT IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') 
			AND A.dblQtyReceived < A.dblQtyOrdered
			AND intPurchaseId = @poId
			AND @receiveNonInventory = 1
			UNION ALL
			SELECT 1 
			FROM tblPOPurchaseDetail A
			INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
			WHERE B.strType IN ('Inventory') 
			AND A.dblQtyReceived < A.dblQtyOrdered
			AND intPurchaseId = @poId
		)
	)
	BEGIN
		RAISERROR('There is no receivable item on this purchase order.', 16, 1);
		RETURN;
	END
  
   IF  EXISTS(SELECT 1 FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON PO.intPurchaseId = PODetail.intPurchaseId
				AND PODetail.intPurchaseId = @poId WHERE intUnitOfMeasureId IS NULL AND intItemId IS NOT NULL)
	BEGIN
		RAISERROR('Cannot process to receipt, Item UOM is missing.', 16, 1);
		RETURN;
	END

	--PO is for approval
	IF(EXISTS(SELECT 1 FROM vyuAPForApprovalTransaction WHERE intTransactionId = @poId AND strScreenName = 'Purchase Order'))
	BEGIN
		RAISERROR('Cannot process to receipt, PO is for approval.', 16, 1);
		RETURN;
	END
	
    --Missing Currency
	IF EXISTS(SELECT intCurrencyId FROM tblPOPurchase WHERE intPurchaseId = @poId AND intCurrencyId = 0)
	BEGIN
		RAISERROR('Cannot process to receipt, Currency is missing.', 16, 1);
		RETURN;
	END  

-- Process the PO to IR 
BEGIN 
	DECLARE @ReceiptStagingTable	ReceiptStagingTable,
			@OtherCharges			ReceiptOtherChargesTableType

	DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
			,@ReceiptType_PurchaseOrderContract AS NVARCHAR(100) = 'Purchase Contract'
			,@intInventoryReceiptId AS INT 

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult 
		(
			intSourceId INT,
			intInventoryReceiptId INT
		)
	END 

	INSERT INTO	@ReceiptStagingTable
	(
			strReceiptType
			,intEntityVendorId
			,intShipFromId
			,intLocationId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intContractHeaderId
			,intContractDetailId
			,dtmDate
			,intShipViaId
			,dblQty
			,intGrossNetUOMId
			,dblGross
			,dblNet
			,dblCost
			,intCostUOMId
			,intCurrencyId
			,intSubCurrencyCents 
			,dblExchangeRate
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsStorage
			,intSourceId	
			,intSourceType		 	
			,strSourceId
			,strSourceScreenName
			,ysnSubCurrency
			,strVendorRefNo
			,intFreightTermId
			,intForexRateTypeId
			,dblForexRate
			,intTaxGroupId
	)
	SELECT	
			strReceiptType			= (CASE WHEN PODetail.intContractHeaderId IS NOT NULL THEN @ReceiptType_PurchaseOrderContract ELSE @ReceiptType_PurchaseOrder END)
			,intEntityVendorId		= PO.intEntityVendorId
			,intShipFromId			= PO.intShipFromId
			,intLocationId			= PO.intShipToId
			,intItemId				= PODetail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= ItemUOM.intItemUOMId
			,intContractHeaderId	= (CASE WHEN PODetail.intContractHeaderId IS NOT NULL THEN PODetail.intContractHeaderId ELSE PODetail.intPurchaseId END)    -- Shown in the Order Id column. 
			,intContractDetailId	= (CASE WHEN PODetail.intContractDetailId IS NOT NULL THEN PODetail.intContractDetailId ELSE PODetail.intPurchaseDetailId END) -- As intLineNo. Link between PO Detail id and IR detail. 
			,dtmDate				= dbo.fnRemoveTimeOnDate(@dtmDate)
			,intShipViaId			= PO.intShipViaId
			,dblQty					= ISNULL(PODetail.dblQtyOrdered,0) - ISNULL(PODetail.dblQtyReceived,0)
			,intGrossNetUOMId		= NULL
			,dblGross				= NULL
			,dblNet					= NULL
			,dblCost				= PODetail.dblCost - (PODetail.dblCost * (ISNULL(PODetail.dblDiscount,0) / 100))
			,intCostUOMId			= PODetail.intCostUOMId
			,intCurrencyId			= PO.intCurrencyId
			,intSubCurrencyCents	= (CASE WHEN PODetail.ysnSubCurrency > 0 THEN PO.intSubCurrencyCents ELSE 1 END)
			,dblExchangeRate		= ISNULL(PO.dblExchangeRate, 1) 
			,intLotId				= NULL 
			,intSubLocationId		= PODetail.intSubLocationId
			,intStorageLocationId	= PODetail.intStorageLocationId
			,ysnIsStorage			= 0
			,intSourceId			= (CASE WHEN PODetail.intContractDetailId IS NOT NULL THEN PODetail.intPurchaseId ELSE NULL END)  
			,intSourceType		 	= (CASE WHEN PODetail.intContractDetailId IS NOT NULL THEN 6 ELSE 0 END)  -- None 
			,strSourceId			= PO.strPurchaseOrderNumber 
			,strSourceScreenName	= @ReceiptType_PurchaseOrder 
			,ysnSubCurrency			= 0 
			,strVendorRefNo			= PO.strReference
			,intFreightTermId		= PO.intFreightTermId
			,intForexRateTypeId		= PODetail.intForexRateTypeId
			,dblForexRate			= PODetail.dblForexRate
			,intTaxGroupId          = ISNULL(PODetail.intTaxGroupId, NULL)


	FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON PO.intPurchaseId = PODetail.intPurchaseId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON PODetail.intItemId = ItemUOM.intItemId
				AND PODetail.intUnitOfMeasureId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON PODetail.intItemId = ItemLocation.intItemId
				-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
				AND PO.intShipToId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICItem item
				ON item.intItemId = PODetail.intItemId
	WHERE	PODetail.intPurchaseId = @poId
			AND 1 = CASE WHEN dbo.fnIsStockTrackingItem(PODetail.intItemId) = 0 AND @receiveNonInventory = 0 THEN 0 ELSE 1 END
			AND PODetail.dblQtyOrdered != PODetail.dblQtyReceived
			AND item.strType IN ('Inventory','Non-Inventory','Finished Good','Raw Material')
	
	INSERT INTO	@OtherCharges
	(
			 [strReceiptType] 
			,[intEntityVendorId] 
			,[intLocationId] 
			,[intShipFromId] 
			,[intChargeId] 
			,[intCurrencyId] 
			,[ysnInventoryCost] 
			,[intCostCurrencyId] 
			,[dblRate] 
			,[dblAmount] 
			,[intCostUOMId] 
			,[intOtherChargeEntityVendorId] 
			,[strCostMethod] 
			,[ysnAccrue] 
			,[ysnPrice] 
			,[intContractHeaderId] 
			,[intContractDetailId]  
			,[ysnSubCurrency] 
			,[intTaxGroupId] 
	)
	SELECT 
		    [strReceiptType]					= @ReceiptType_PurchaseOrderContract          
			,[intEntityVendorId]				= PO.intEntityVendorId
			,[intLocationId]					= PO.intShipToId			
			,[intShipFromId]					= PO.intShipFromId
			,[intChargeId]						= CC.intItemId
			,[intCurrencyId]					= CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END	
			,[ysnInventoryCost]					= CC.ysnInventoryCost
			,[intCostCurrencyId]				= ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
			,[dblRate]							= CC.dblRate
			,[dblAmount]						= CC.dblAmount
			,[intCostUOMId]						= PD.intUnitOfMeasureId
			,[intOtherChargeEntityVendorId]		= CC.intVendorId
			,[strCostMethod]					= CC.strCostMethod
			-- ,[dblAmount]						= CASE	WHEN	CC.strCostMethod = 'Percentage' THEN
			-- 															dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice * (CC.dblRate / 100) *
			-- 															CASE WHEN CC.intCurrencyId = CD.intCurrencyId THEN 1 ELSE ISNULL(CC.dblFX,1) END
			-- 													ELSE	ISNULL(CC.dblRate,0) 
			-- 											END
			,[ysnAccrue]						= CC.ysnAccrue
			,[ysnPrice]							= CC.ysnPrice
			,[intContractHeaderId]				= CD.intContractHeaderId
			,[intContractDetailId]				= CC.intContractDetailId
			,[ysnSubCurrency]					= CY.ysnSubCurrency
			,[intTaxGroupId]					= NULL
	FROM vyuCTContractCostView CC
	JOIN tblCTContractDetail CD	
		ON	CD.intContractDetailId = CC.intContractDetailId
	JOIN tblCTContractHeader CH		
		ON	CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN dbo.tblPOPurchaseDetail PD 
		ON PD.intContractHeaderId = CC.intContractHeaderId 
	INNER JOIN dbo.tblPOPurchase PO
		ON PO.intPurchaseId = PD.intPurchaseId
	LEFT JOIN	tblSMCurrency CY	
		ON	CY.intCurrencyID = CC.intCurrencyId
	LEFT JOIN	tblSMCurrency CU	
		ON	CU.intCurrencyID = CD.intCurrencyId
	WHERE PD.intPurchaseId = @poId

	-- Call this sp to Process the PO to IR. 
	EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable
			,@OtherCharges
			,@userId;

	--REMOVE VOUCHER PAYABLE
--IF THERE IS PARTIALLY VOUCHERED, MOVE IT TO COMPLETE
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;
DECLARE @error NVARCHAR(1000);

IF @receiveNonInventory = 1 
	AND EXISTS(SELECT 1 FROM tblPOPurchaseDetail WHERE (dbo.fnIsStockTrackingItem(intItemId) = 0 OR intItemId IS NULL) AND intPurchaseId = @poId)
BEGIN

	--IF THERE IS PARTIALLY VOUCHERED NON-INVENTORY ITEM, FORCE COMPLETE THE NON-INVENTORY AS WE WILL RECEIVE THE NON-INVENTORY TO IR
		INSERT INTO @voucherPayables(
			[intEntityVendorId]			
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
			,[intPurchaseDetailId]				
			,[intContractHeaderId]				
			,[intContractDetailId]				
			,[intContractSeqId]					
			,[intScaleTicketId]					
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]		
			,[intInventoryShipmentChargeId]		
			,[intLoadShipmentId]				
			,[intLoadShipmentDetailId]			
			,[intItemId]						
			,[intPurchaseTaxGroupId]			
			,[strMiscDescription]				
			,[dblOrderQty]						
			,[dblOrderUnitQty]					
			,[intOrderUOMId]					
			,[dblQuantityToBill]				
			,[dblQtyToBillUnitQty]				
			,[intQtyToBillUOMId]				
			,[dblCost]							
			,[dblCostUnitQty]					
			,[intCostUOMId]						
			,[dblNetWeight]						
			,[dblWeightUnitQty]					
			,[intWeightUOMId]					
			,[intCostCurrencyId]
			,[dblTax]							
			,[dblDiscount]
			,[intCurrencyExchangeRateTypeId]	
			,[dblExchangeRate]					
			,[ysnSubCurrency]					
			,[intSubCurrencyCents]				
			,[intAccountId]						
			,[intShipViaId]						
			,[intTermId]						
			,[strBillOfLading]					
			,[ysnReturn]						
		)
		SELECT * FROM dbo.fnAPCreatePOVoucherPayable(@poDetailIds)
		WHERE 
			(dbo.fnIsStockTrackingItem(intItemId) = 0 OR intItemId IS NULL); --NON-INVENTORY ONLY

		INSERT INTO @voucherPayableTax (
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
			,[ysnTaxExempt]	
			,[ysnTaxOnly]
		)
		SELECT
			[intVoucherPayableId]		=	payables.intVoucherPayableId,
			[intTaxGroupId]				=	A.intTaxGroupId, 
			[intTaxCodeId]				=	A.intTaxCodeId, 
			[intTaxClassId]				=	A.intTaxClassId, 
			[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
			[strCalculationMethod]		=	A.strCalculationMethod, 
			[dblRate]					=	A.dblRate, 
			[intAccountId]				=	A.intAccountId, 
			[dblTax]					=	A.dblTax, 
			[dblAdjustedTax]			=	ISNULL(A.dblAdjustedTax,0), 
			[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
			[ysnSeparateOnBill]			=	A.ysnSeparateOnBill, 
			[ysnCheckOffTax]			=	A.ysnCheckOffTax,
			[ysnTaxExempt]				=	A.ysnTaxExempt,
			[ysnTaxOnly]				=	A.ysnTaxOnly
		FROM tblPOPurchaseDetailTax A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
		INNER JOIN @voucherPayables payables ON B.intPurchaseDetailId = payables.intPurchaseDetailId
		LEFT JOIN tblICItem C ON B.intItemId = C.intItemId
		WHERE 
			(dbo.fnIsStockTrackingItem(C.intItemId) = 0 OR C.intItemId IS NULL)
		AND payables.dblTax != 0


	IF (EXISTS(SELECT 1 FROM tblPOPurchaseDetail WHERE intPurchaseId = @poId AND dblQtyReceived != 0))
	BEGIN
		--FORCE COMPLETE THOSE PARTIALLY VOUCHERD NON-INVENTORY		
		EXEC uspAPForceCompletePayable @voucherPayable = @voucherPayables, @voucherPayableTax = @voucherPayableTax, @throwError = 1, @error = @error OUT;
	END
	ELSE
	BEGIN
		--IF THERE IS NO PARTIALLY RECEIVED FOR NON-INVENTORY, REMOVE IT ON PAYABLES AS THE PAYABLES RECORD WILL BE CREATED BY RECEIPT
		EXEC uspAPRemoveVoucherPayable @voucherPayable = @voucherPayables, @throwError = 1, @error = @error OUT;
	END
END

	-- Get the receipt number generated by uspICAddItemReceipt
	SELECT	TOP 1 
			@receiptNumber = strReceiptNumber 
	FROM	tblICInventoryReceipt r INNER JOIN #tmpAddItemReceiptResult tempR
				ON r.intInventoryReceiptId = tempR.intInventoryReceiptId

	-- Update the On-Order Qty
	BEGIN 
		DECLARE @ItemToUpdateOnOrderQty ItemCostingTableType

		-- Create the list. 
		INSERT INTO @ItemToUpdateOnOrderQty (
				dtmDate
				,intItemId
				,intItemLocationId
				,intItemUOMId
				-- ,intSubLocationId
				,dblQty
				,dblUOMQty
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intSubLocationId
				,intStorageLocationId
		)
		SELECT	dtmDate					= PO.dtmDate
				,intItemId				= POD.intItemId
				,intItemLocationId		= il.intItemLocationId 
				,intItemUOMId			= POD.intUnitOfMeasureId  
				-- ,intSubLocationId		= NULL 
				,dblQty					= -(POD.dblQtyOrdered - POD.dblQtyReceived)
				,dblUOMQty				= iu.dblUnitQty
				,intTransactionId		= PO.intPurchaseId
				,intTransactionDetailId = POD.intPurchaseDetailId 
				,strTransactionId		= PO.strPurchaseOrderNumber
				,intTransactionTypeId	= -1 -- Any value
				,POD.intSubLocationId
				,POD.intStorageLocationId
		FROM	tblPOPurchase PO INNER JOIN tblPOPurchaseDetail POD
					ON PO.intPurchaseId = POD.intPurchaseId
				LEFT JOIN tblICItemLocation il
					ON il.intItemId = POD.intItemId
					AND il.intLocationId = PO.intShipToId
				LEFT JOIN tblICItemUOM iu
					ON iu.intItemId = POD.intItemId 
					AND iu.intItemUOMId = POD.intUnitOfMeasureId 
				LEFT JOIN tblICItem i
					ON i.intItemId = POD.intItemId
		WHERE	PO.intPurchaseId = @poId  
				AND POD.intItemId IS NOT NULL			--DO NOT UPDATE MISC ENTRY
				AND i.strType NOT IN ('Other Charge')   --DOT NOT UPDATE OTHER CHARGES TYPE     

		-- Call the stored procedure that updates the on order qty. 
		EXEC dbo.uspICIncreaseOnOrderQty 
			@ItemToUpdateOnOrderQty
	END 
END

-- Update the PO Received Qty
UPDATE	pod
SET		pod.dblQtyReceived = pod.dblQtyOrdered
FROM	tblPOPurchase po INNER JOIN tblPOPurchaseDetail pod
			ON po.intPurchaseId = pod.intPurchaseId
		LEFT JOIN tblICItem i
				ON i.intItemId = pod.intItemId
WHERE	po.intPurchaseId = @poId 
		AND pod.intItemId IS NOT NULL				--DO NOT UPDATE MISC ENTRY
		AND i.strType NOT IN ('Other Charge')		--DOT NOT UPDATE OTHER CHARGES TYPE
	
-- Update the PO Status 
EXEC dbo.uspPOUpdateStatus @poId

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