CREATE PROCEDURE [dbo].[uspPOProcessItemReceipt]
	@poId INT
	,@userId INT
	,@receiptNumber NVARCHAR(50) OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Validations
BEGIN 
	--Purchase order already closed.
	IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND intOrderStatusId = 3)
	BEGIN
		RAISERROR(51036, 16, 1)
		RETURN;
	END

	IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND dblTotal = 0)
	BEGIN
		RAISERROR(51039, 16, 1)
		RETURN;
	END

	IF NOT EXISTS(SELECT 1 FROM tblPOPurchaseDetail A
					INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
					WHERE strType NOT IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') AND intPurchaseId = @poId)
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
    
END 

-- Process the PO to IR 
BEGIN 
	DECLARE @ReceiptStagingTable	ReceiptStagingTable,
			@OtherCharges			ReceiptOtherChargesTableType

	DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
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
	)
	SELECT	
			strReceiptType			= @ReceiptType_PurchaseOrder
			,intEntityVendorId		= PO.intEntityVendorId
			,intShipFromId			= PO.intShipFromId
			,intLocationId			= PO.intShipToId
			,intItemId				= PODetail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= ItemUOM.intItemUOMId
			,intContractHeaderId	= PODetail.intPurchaseId -- Shown in the Order Id column. 
			,intContractDetailId	= PODetail.intPurchaseDetailId -- As intLineNo. Link between PO Detail id and IR detail. 
			,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
			,intShipViaId			= PO.intShipViaId
			,dblQty					= ISNULL(PODetail.dblQtyOrdered,0) - ISNULL(PODetail.dblQtyReceived,0)
			,intGrossNetUOMId		= NULL 
			,dblGross				= PODetail.dblQtyOrdered
			,dblNet					= PODetail.dblQtyOrdered
			,dblCost				= PODetail.dblCost
			,intCostUOMId			= ItemUOM.intItemUOMId
			,intCurrencyId			= PO.intCurrencyId
			,intSubCurrencyCents	= (CASE WHEN PODetail.ysnSubCurrency > 0 THEN PO.intSubCurrencyCents ELSE 1 END)
			,dblExchangeRate		= ISNULL(PO.dblExchangeRate, 1) 
			,intLotId				= NULL 
			,intSubLocationId		= PODetail.intSubLocationId
			,intStorageLocationId	= PODetail.intStorageLocationId
			,ysnIsStorage			= 0
			,intSourceId			= NULL 
			,intSourceType		 	= 0 -- None 
			,strSourceId			= PO.strPurchaseOrderNumber
			,strSourceScreenName	= @ReceiptType_PurchaseOrder
			,ysnSubCurrency			= 0 
			,strVendorRefNo			= PO.strReference
			,intFreightTermId		= PO.intFreightTermId
			,intForexRateTypeId		= PODetail.intForexRateTypeId
			,dblForexRate			= PODetail.dblForexRate

	FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON PO.intPurchaseId = PODetail.intPurchaseId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON PODetail.intItemId = ItemUOM.intItemId
				AND PODetail.intUnitOfMeasureId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON PODetail.intItemId = ItemLocation.intItemId
				-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
				AND PO.intShipToId = ItemLocation.intLocationId
	WHERE	PODetail.intPurchaseId = @poId
			AND dbo.fnIsStockTrackingItem(PODetail.intItemId) = 1
			AND PODetail.dblQtyOrdered != PODetail.dblQtyReceived
	
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
			,[intCostUOMId] 
			,[intOtherChargeEntityVendorId] 
			,[strCostMethod] 
			,[dblAmount] 
			,[ysnAccrue] 
			,[ysnPrice] 
			,[intContractHeaderId] 
			,[intContractDetailId]  
			,[ysnSubCurrency] 
			,[intTaxGroupId] 
	)
	SELECT 
		    [strReceiptType]					= @ReceiptType_PurchaseOrder          
			,[intEntityVendorId]				= PO.intEntityVendorId
			,[intLocationId]					= PO.intShipToId			
			,[intShipFromId]					= PO.intShipFromId
			,[intChargeId]						= CC.intItemId
			,[intCurrencyId]					= CASE WHEN CY.ysnSubCurrency > 0 
															 THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															 ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END	
			,[ysnInventoryCost]					= 0
			,[intCostCurrencyId]				= ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))	
			,[dblRate]							= CC.dblFX
			,[intCostUOMId]						= PD.intUnitOfMeasureId
			,[intOtherChargeEntityVendorId]		= CC.intVendorId
			,[strCostMethod]					= CC.strCostMethod
			,[dblAmount]						= CC.dblRate
			,[ysnAccrue]						= CC.ysnAccrue
			,[ysnPrice]							= CC.ysnPrice
			,[intContractHeaderId]				= CD.intContractHeaderId
			,[intContractDetailId]				= CC.intContractDetailId
			,[ysnSubCurrency]					= 0
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

	-- Get the receipt number generated by uspICAddItemReceipt
	SELECT	TOP 1 
			@receiptNumber = strReceiptNumber 
	FROM	tblICInventoryReceipt r INNER JOIN #tmpAddItemReceiptResult tempR
				ON r.intInventoryReceiptId = tempR.intInventoryReceiptId

	-- Update the PO Status 
	EXEC dbo.uspPOUpdateStatus @poId
END