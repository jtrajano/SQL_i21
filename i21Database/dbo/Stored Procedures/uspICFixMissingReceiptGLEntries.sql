CREATE PROCEDURE uspICFixMissingReceiptGLEntries
	@intInventoryReceiptId AS INT = NULL	
	,@strReceiptNumber AS NVARCHAR(50) = NULL
AS

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#tmpFixMissingReceiptGLEntries') IS NULL  
BEGIN 
	CREATE TABLE #tmpFixMissingReceiptGLEntries (
		intInventoryReceiptItemId INT NULL 
	)
END 

DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
		,@STARTING_NUMBER_BATCH AS INT = 3  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'
		,@TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
		,@INBOUND_SHIPMENT_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		-- Receipt Types
		,@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'

		,@SOURCE_TYPE_NONE AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_InboundShipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3
		,@SOURCE_TYPE_SettleStorage AS INT = 4
		,@SOURCE_TYPE_DeliverySheet AS INT = 5
		,@SOURCE_TYPE_PurchaseOrder AS INT = 6
		,@SOURCE_TYPE_Store AS INT = 7

DECLARE @NonInventoryItemsForPost AS ItemCostingTableType  
		,@GLEntries AS RecapTableType 
		,@intReturnValue AS INT 
		,@intEntityVendorId AS INT 
		,@strBatchId AS NVARCHAR(50)
		,@intEntityUserSecurityId AS INT 

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

-- Get the IR information
BEGIN 
	SELECT
		@intEntityVendorId = intEntityVendorId
		,@intEntityUserSecurityId = intEntityId
		,@intInventoryReceiptId = intInventoryReceiptId
		,@strReceiptNumber = strReceiptNumber
	FROM 
		tblICInventoryReceipt r
	WHERE
		(r.intInventoryReceiptId = @intInventoryReceiptId AND @strReceiptNumber IS NULL) 
		OR (r.strReceiptNumber = @strReceiptNumber AND @intInventoryReceiptId IS NULL)
		OR (r.intInventoryReceiptId = @intInventoryReceiptId AND r.strReceiptNumber = @strReceiptNumber) 

	SELECT TOP 1
		@strBatchId = gd.strBatchId
	FROM 
		tblGLDetail gd
	WHERE 
		gd.strTransactionId = @strReceiptNumber
		AND gd.ysnIsUnposted = 0 
END 

INSERT INTO @NonInventoryItemsForPost (  
		intItemId  
		,intItemLocationId 
		,intItemUOMId  
		,dtmDate  
		,dblQty  
		,dblUOMQty  
		,dblCost  
		,dblSalesPrice  
		,intCurrencyId  
		,dblExchangeRate  
		,intTransactionId  
		,intTransactionDetailId   
		,strTransactionId  
		,intTransactionTypeId  
		,intLotId 
		,intSubLocationId
		,intStorageLocationId
		,strActualCostId
		,intInTransitSourceLocationId
		,intForexRateTypeId
		,dblForexRate
		,intCategoryId
		,dblUnitRetail
) 
SELECT	intItemId = DetailItem.intItemId  
		,intItemLocationId = ItemLocation.intItemLocationId
		,intItemUOMId = 
					-- New Hierarchy:
					-- 1. Use the Gross/Net UOM (intWeightUOMId) 
					-- 2. If there is no Gross/Net UOM, then check the lot. 
						-- 2.1. If it is a Lot, use the Lot UOM. 
						-- 2.2. If it is not a Lot, use the Item UOM. 
					ISNULL( 
						DetailItem.intWeightUOMId, 
						CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
									DetailItemLot.intItemUnitMeasureId
								ELSE 
									DetailItem.intUnitMeasureId
						END 
					)

		,dtmDate = Header.dtmReceiptDate  
		,dblQty =
					-- New Hierarchy:
					-- 1. If there is a Gross/Net UOM, use the Net Qty. 
						-- 2.1. If it is not a Lot, use the item's Net Qty. 
						-- 2.2. If it is a Lot, use the Lot's Net Qty. 
					-- 2. If there is no Gross/Net UOM, use the item or lot qty. 
						-- 2.1. If it is not a Lot, use the item Qty. 
						-- 2.2. If it is a Lot, use the lot qty. 
					CASE		-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
								WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 									
									CASE	-- When item is NOT a Lot, receive it by the item's net qty. 
											WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
												ISNULL(DetailItem.dblNet, 0)
													
											-- When item is a LOT, get the net qty from the Lot record. 
											-- 1. If Net Qty is not provided, convert the Lot Qty into Gross/Net UOM. 
											-- 2. Else, get the Net Qty by using this formula: Gross Weight - Tare Weight. 
											ELSE 
														-- When Net Qty is missing, then convert the Lot Qty to Gross/Net UOM. 
												CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
															dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
														-- Calculate the Net Qty
														ELSE 
															ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
												END 
									END 

							-- If Gross/Net UOM is missing, then get the item/lot qty. 
							ELSE 
								CASE	-- When item is NOT a Lot, receive it by the item qty.
										WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
											DetailItem.dblOpenReceive
												
										-- When item is a LOT, receive it by the Lot Qty. 
										ELSE 
											ISNULL(DetailItemLot.dblQuantity, 0)
								END

					END 

		,dblUOMQty = 
					-- New Hierarchy:
					-- 1. Use the Gross/Net UOM (intWeightUOMId) 
					-- 2. If there is no Gross/Net UOM, then check the lot. 
						-- 2.1. If it is a Lot, use the Lot UOM. 
						-- 2.2. If it is not a Lot, use the Item UOM. 
					ISNULL( 
						WeightUOM.dblUnitQty, 
						CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
									LotItemUOM.dblUnitQty
								ELSE 
									ItemUOM.dblUnitQty
						END 
					)
							
		,dblCost =	
					-- New Hierarchy:
					-- 1. If there is a Gross/Net UOM, convert the cost from Cost UOM to Gross/Net UOM. 
					-- 2. If Gross/Net UOM is not specified, then: 
						-- 2.1. If it is not a Lot, convert the cost from Cost UOM to Receive UOM. 
						-- 2.2. If it is a Lot, convert the cost from Cost UOM to Lot UOM. 
					-- 3. If sub-currency exists, then convert it to sub-currency. 

					-- If Sub-Currency: (A / C + B) 
					-- Else: (A + B) 

					CASE	
						WHEN DetailItem.ysnSubCurrency = 1 AND ISNULL(Header.intSubCurrencyCents, 1) <> 0 THEN 
							(
								-- (A) Item Cost
								dbo.fnCalculateReceiptUnitCost(
									DetailItem.intItemId
									,DetailItem.intUnitMeasureId		
									,DetailItem.intCostUOMId
									,DetailItem.intWeightUOMId
									,DetailItem.dblUnitCost
									,DetailItem.dblNet
									,DetailItemLot.intLotId
									,DetailItemLot.intItemUnitMeasureId
									,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
									,DetailItem.ysnSubCurrency
									,Header.intSubCurrencyCents
									,DEFAULT 
								)
								--/ Header.intSubCurrencyCents 

								-- (B) Other Charge
								+ 
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										-- Convert the other charge to the currency used by the detail item. 
										dbo.fnDivide(
											dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
											,DetailItem.dblForexRate
										)
									ELSE 
										-- No conversion. Detail item is already in functional currency. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
								END 									
								+
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										dbo.fnDivide(
											dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
											,DetailItem.dblForexRate
										)
									ELSE 												
										dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
								END 									
							)										
						ELSE 
							(
								-- (A) Item Cost
								dbo.fnCalculateReceiptUnitCost(
									DetailItem.intItemId
									,DetailItem.intUnitMeasureId		
									,DetailItem.intCostUOMId
									,DetailItem.intWeightUOMId
									,DetailItem.dblUnitCost
									,DetailItem.dblNet
									,DetailItemLot.intLotId
									,DetailItemLot.intItemUnitMeasureId
									,AggregrateItemLots.dblTotalNet
									,NULL--DetailItem.ysnSubCurrency
									,NULL--Header.intSubCurrencyCents
									,DEFAULT 
								)
								-- (B) Other Charge
								+ 
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										-- Convert the other charge to the currency used by the detail item. 
										dbo.fnDivide(
											dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
											,DetailItem.dblForexRate
										)
									ELSE 
										-- No conversion. Detail item is already in functional currency. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
								END	 									
								+
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										dbo.fnDivide(
											dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
											,DetailItem.dblForexRate
										)
									ELSE 
										dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
								END
							)							
					END

		,dblSalesPrice = 0  
		,intCurrencyId = Header.intCurrencyId  
		,dblExchangeRate = ISNULL(DetailItem.dblForexRate, 1)   
		,intTransactionId = Header.intInventoryReceiptId  
		,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
		,strTransactionId = Header.strReceiptNumber  
		,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
		,intLotId = DetailItemLot.intLotId 
		,intSubLocationId = DetailItem.intSubLocationId --ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
		,intStorageLocationId = ISNULL(DetailItemLot.intStorageLocationId, DetailItem.intStorageLocationId)
		,strActualCostId = DetailItem.strActualCostId
		,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
		,intForexRateTypeId = DetailItem.intForexRateTypeId
		,dblForexRate = DetailItem.dblForexRate
		,intCategoryId = i.intCategoryId
		,dblUnitRetail = 
			dbo.fnCalculateReceiptUnitCost(
				DetailItem.intItemId
				,DetailItem.intUnitMeasureId		
				,DetailItem.intCostUOMId
				,DetailItem.intWeightUOMId
				,DetailItem.dblUnitRetail
				,DetailItem.dblNet
				,DetailItemLot.intLotId
				,DetailItemLot.intItemUnitMeasureId
				,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
				,NULL--DetailItem.ysnSubCurrency
				,NULL--Header.intSubCurrencyCents
				,DEFAULT 
			)
FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
			ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
		INNER JOIN #tmpFixMissingReceiptGLEntries list
			ON list.intInventoryReceiptItemId = DetailItem.intInventoryReceiptItemId
		INNER JOIN tblICItem i 
			ON DetailItem.intItemId = i.intItemId 
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ItemLocation.intLocationId = (
				CASE WHEN Header.strReceiptNumber = @RECEIPT_TYPE_TRANSFER_ORDER THEN Header.intTransferorId ELSE Header.intLocationId END 
			)
			AND ItemLocation.intItemId = DetailItem.intItemId
		LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
			ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
			AND dbo.fnGetItemLotType(DetailItem.intItemId) IN (1,2,3)
		OUTER APPLY (
			SELECT  dblTotalNet = SUM(
						CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
									ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
								ELSE 
									ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
						END 
					)
			FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
						ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
			WHERE	ReceiptItem.intInventoryReceiptItemId = DetailItem.intInventoryReceiptItemId
		) AggregrateItemLots
		LEFT JOIN dbo.tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = DetailItem.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM LotItemUOM
			ON LotItemUOM.intItemUOMId = DetailItemLot.intItemUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM WeightUOM
			ON WeightUOM.intItemUOMId = DetailItem.intWeightUOMId
		LEFT JOIN dbo.tblICItemUOM CostUOM
			ON CostUOM.intItemUOMId = DetailItem.intCostUOMId
		LEFT JOIN dbo.tblICItemLocation InTransitSourceLocation 
			ON InTransitSourceLocation.intItemId = DetailItem.intItemId 
			AND InTransitSourceLocation.intLocationId = Header.intTransferorId
		OUTER APPLY (
			SELECT TOP 1 intItemUOMId FROM tblICItemUOM iu WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
		) stockUOM
WHERE	ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
		AND i.strType = 'Non-Inventory'		

IF EXISTS (SELECT TOP 1 1 FROM @NonInventoryItemsForPost)
BEGIN 	
	INSERT INTO @GLEntries (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
	)
	EXEC @intReturnValue = uspICCreateReceiptGLEntriesForNonStockItems
		@NonInventoryItemsForPost 
		,@strBatchId
		,@intInventoryReceiptId 
		,@intEntityUserSecurityId

	IF @intReturnValue < 0 GOTO _Exit

	-- Clean up the recap data. 
	BEGIN 
		UPDATE @GLEntries
		SET dblDebitForeign = ISNULL(dblDebitForeign, 0)
			,dblCreditForeign = ISNULL(dblCreditForeign, 0) 
	END 

	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
        UPDATE @GLEntries
        SET intEntityId = @intEntityVendorId
        WHERE intEntityId IS NULL 

		EXEC dbo.uspGLBookEntries @GLEntries, 1
	END 
END 

_Exit: 
