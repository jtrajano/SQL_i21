PRINT 'Populate the IC-AP-Clearing'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICAPClearing) 
BEGIN 
	DECLARE 
	@intVoucherInvoiceNoOption TINYINT
	,	@voucherInvoiceOption_Blank TINYINT = 1 
	,	@voucherInvoiceOption_BOL TINYINT = 2
	,	@voucherInvoiceOption_VendorRefNo TINYINT = 3
	,@intDebitMemoInvoiceNoOption TINYINT
	,	@debitMemoInvoiceOption_Blank TINYINT = 1
	,	@debitMemoInvoiceOption_BOL TINYINT = 2
	,	@debitMemoInvoiceOption_VendorRefNo TINYINT = 3	

	SELECT TOP 1 
		@intVoucherInvoiceNoOption = intVoucherInvoiceNoOption
		,@intDebitMemoInvoiceNoOption = intDebitMemoInvoiceNoOption
	FROM tblAPCompanyPreference

	DECLARE 
		@intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

		,@INVENTORY_RECEIPT_TYPE AS INT = 4
		,@STARTING_NUMBER_BATCH AS INT = 3  

		-- Receipt Types
		,@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'

	-- Populate the Receipt Items. 
	BEGIN 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)	
		SELECT 
			[intTransactionId] = r.intInventoryReceiptId
			,[strTransactionId] = r.strReceiptNumber
			,[intTransactionType] = 1 -- RECEIPT
			,[strReferenceNumber] = 
				CASE 
					WHEN r.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN r.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN r.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN r.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN r.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo)
						END 						
				END			
			,[dtmDate] = r.dtmReceiptDate
			,[intEntityVendorId] = r.intEntityVendorId
			,[intLocationId] = r.intLocationId
			,[intInventoryReceiptItemId] = ri.intInventoryReceiptItemId
			,[intInventoryReceiptItemTaxId] = NULL
			,[intInventoryReceiptChargeId] = NULL
			,[intInventoryReceiptChargeTaxId] = NULL
			,[intInventoryShipmentChargeId] = NULL
			,[intInventoryShipmentChargeTaxId] = NULL
			,[intAccountId] = ga.intAccountId
			,[intItemId] = i.intItemId
			,[intItemUOMId] = ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId) 			
			,[dblQuantity] = 
				CASE 
					WHEN ri.intWeightUOMId IS NOT NULL THEN ri.dblNet 
					ELSE ri.dblOpenReceive
				END 
			,[dblAmount] = ri.dblLineTotal
			,strBatchId = t.strBatchId	
		FROM (
				SELECT DISTINCT 
					t.strTransactionId
					,t.intItemId
					,t.intTransactionDetailId
					,t.strBatchId
				FROM	
					tblICInventoryTransaction t 
				WHERE
					t.dblQty <> 0
					AND t.ysnIsUnposted = 0 
			) t
			INNER JOIN tblICInventoryReceipt r 
				ON r.strReceiptNumber = t.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri 
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				AND ri.intItemId = t.intItemId
				AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
			INNER JOIN tblICItem i 
				ON i.intItemId = ri.intItemId
			INNER JOIN tblICItemLocation il
				ON il.intItemId = i.intItemId
				AND il.intLocationId = r.intLocationId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				i.intItemId
				,il.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
		WHERE
			r.strReceiptType NOT IN ('Transfer Order')
	END

	-- Populate the non-inventory items from Inventory Receipt
	BEGIN 
		DECLARE
			@NonInventoryItem AS ItemCostingTableType
			,@ItemsForPost AS ItemCostingTableType

		BEGIN 
			INSERT INTO @ItemsForPost (  
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
					,intSourceEntityId
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
												,DetailItem.intComputeItemTotalOption
												,DetailItem.dblOpenReceive
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
												,DetailItem.intComputeItemTotalOption
												,DetailItem.dblOpenReceive
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
							,DetailItem.intComputeItemTotalOption
							,DetailItem.dblOpenReceive
						)
					,intSourceEntityId = Header.intEntityVendorId
			FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
						ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
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

			WHERE	Header.ysnPosted = 1
					AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND i.strType <> 'Bundle' -- Do not include Bundle items in the item costing. Bundle components are the ones included in the item costing. 
					AND CASE	
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
										,DetailItem.intComputeItemTotalOption
										,DetailItem.dblOpenReceive
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
										,DetailItem.intComputeItemTotalOption
										,DetailItem.dblOpenReceive
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
						END IS NOT NULL 
					AND CASE		
							-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
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
						END IS NOT NULL 

			-- Update currency fields to functional currency. 
			BEGIN 
				UPDATE	itemCost
				SET		dblExchangeRate = 1
						,dblForexRate = 1
						,intCurrencyId = @intFunctionalCurrencyId
				FROM	@ItemsForPost itemCost
				WHERE	ISNULL(itemCost.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId 

				UPDATE	itemCost
				SET		dblCost = dbo.fnMultiply(dblCost, ISNULL(dblForexRate, 1)) 
						,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, ISNULL(dblForexRate, 1)) 
						,dblValue = dbo.fnMultiply(dblValue, ISNULL(dblForexRate, 1)) 
				FROM	@ItemsForPost itemCost
				WHERE	itemCost.intCurrencyId <> @intFunctionalCurrencyId 
			END
		END

		INSERT INTO @NonInventoryItem (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblCost] 
			,[dblValue]
			,[dblSalesPrice] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 
			,[intInTransitSourceLocationId] 
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[intStorageScheduleTypeId] 
			,[dblUnitRetail] 
			,[intCategoryId] 
			,[dblAdjustCostValue] 
			,[dblAdjustRetailValue] 
			,[intCostingMethod] 
			,[ysnAllowVoucher] 
		)
		SELECT 
			itemsToPost.intItemId
			,itemsToPost.intItemLocationId
			,itemsToPost.intItemUOMId
			,itemsToPost.dtmDate
			,itemsToPost.dblQty
			,itemsToPost.dblUOMQty
			,itemsToPost.dblCost
			,itemsToPost.dblValue
			,itemsToPost.dblSalesPrice
			,itemsToPost.intCurrencyId
			,itemsToPost.dblExchangeRate
			,itemsToPost.intTransactionId
			,itemsToPost.intTransactionDetailId
			,itemsToPost.strTransactionId
			,itemsToPost.intTransactionTypeId
			,itemsToPost.intLotId
			,itemsToPost.intSubLocationId
			,itemsToPost.intStorageLocationId
			,itemsToPost.ysnIsStorage
			,itemsToPost.strActualCostId
			,itemsToPost.intSourceTransactionId
			,itemsToPost.strSourceTransactionId
			,itemsToPost.intInTransitSourceLocationId
			,itemsToPost.intForexRateTypeId
			,itemsToPost.dblForexRate
			,itemsToPost.intStorageScheduleTypeId
			,itemsToPost.dblUnitRetail
			,itemsToPost.intCategoryId
			,itemsToPost.dblAdjustCostValue
			,itemsToPost.dblAdjustRetailValue
			,itemsToPost.intCostingMethod
			,itemsToPost.ysnAllowVoucher
		FROM	
			@ItemsForPost itemsToPost INNER JOIN tblICItem i 
				ON itemsToPost.intItemId = i.intItemId
		WHERE
			i.strType = 'Non-Inventory'

		INSERT INTO tblICAPClearing (
				[intTransactionId]
				,[strTransactionId]
				,[intTransactionType]
				,[strReferenceNumber]
				,[dtmDate]
				,[intEntityVendorId]
				,[intLocationId]
				,[intInventoryReceiptItemId]
				,[intInventoryReceiptItemTaxId]
				,[intInventoryReceiptChargeId]
				,[intInventoryReceiptChargeTaxId]
				,[intInventoryShipmentChargeId]
				,[intInventoryShipmentChargeTaxId]
				,[intAccountId]
				,[intItemId]
				,[intItemUOMId]
				,[dblQuantity]
				,[dblAmount]
				,[strBatchId]
			)
		SELECT 
				[intTransactionId] = t.intTransactionId
				,[strTransactionId] = t.strTransactionId
				,[intTransactionType] = 1 -- RECEIPT 
				,[strReferenceNumber] =
					CASE 
						WHEN r.strReceiptType = 'Inventory Return' THEN 
							CASE 
								WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
								WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN r.strBillOfLading 
								WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN r.strVendorRefNo 
								ELSE ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo)
							END 
						ELSE
							CASE 
								WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
								WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN r.strBillOfLading 
								WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN r.strVendorRefNo 
								ELSE ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo)
							END 						
					END	
				,[dtmDate] = t.dtmDate
				,[intEntityVendorId] = r.intEntityVendorId
				,[intLocationId] = r.intLocationId
				,[intInventoryReceiptItemId] = t.intTransactionDetailId
				,[intInventoryReceiptItemTaxId] = NULL 
				,[intInventoryReceiptChargeId] = NULL 
				,[intInventoryReceiptChargeTaxId] = NULL 
				,[intInventoryShipmentChargeId] = NULL 
				,[intInventoryShipmentChargeTaxId] = NULL 
				,[intAccountId] = 1
				,[intItemId] = t.intItemId
				,[intItemUOMId] = t.intItemUOMId
				,[dblQuantity] = t.dblQty
				,[dblAmount] = 
						t.dblQty *
						dbo.fnCalculateReceiptUnitCost(
							ri.intItemId
							,ri.intUnitMeasureId		
							,ri.intCostUOMId
							,ri.intWeightUOMId
							,ri.dblUnitCost
							,ri.dblNet
							,t.intLotId
							,t.intItemUOMId
							,NULL --AggregrateItemLots.dblTotalNet
							,ri.ysnSubCurrency
							,r.intSubCurrencyCents
							,DEFAULT
							,ri.intComputeItemTotalOption
							,ri.dblOpenReceive
						)
				,strBatchId = gd.strBatchId
			FROM 
				@NonInventoryItem t INNER JOIN tblICInventoryTransactionType TransType 
					ON t.intTransactionTypeId = TransType.intTransactionTypeId
				INNER JOIN tblICItem i 
					ON i.intItemId = t.intItemId
				INNER JOIN tblICInventoryReceipt r 
					ON r.strReceiptNumber = t.strTransactionId
					AND r.intInventoryReceiptId = t.intTransactionId			
				INNER JOIN tblICInventoryReceiptItem ri 
					ON ri.intInventoryReceiptId = r.intInventoryReceiptId
					AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
				CROSS APPLY dbo.fnGetItemGLAccountAsTable(
					i.intItemId
					,t.intItemLocationId
					,'AP Clearing'
				) apClearing
				INNER JOIN tblGLAccount ga
					ON ga.intAccountId = apClearing.intAccountId
				CROSS APPLY (
					SELECT TOP 1 
						gd.strBatchId
					FROM tblGLDetail gd
					WHERE
						gd.strTransactionId = t.strTransactionId
						AND gd.ysnIsUnposted = 0 
				) gd
	END 	   	

	-- Populate the Receipt Charges
	BEGIN 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT
			[intTransactionId] = Receipt.intInventoryReceiptId
			,[strTransactionId] = Receipt.strReceiptNumber
			,[intTransactionType] = 2 -- 'RECEIPT CHARGE 
			,[strReferenceNumber] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 						
				END			
			
			,[dtmDate] = Receipt.dtmReceiptDate
			,[intEntityVendorId] = 
				CASE 
					WHEN ISNULL(ReceiptCharges.ysnPrice, 0) = 1 THEN Receipt.intEntityVendorId
					WHEN ISNULL(ReceiptCharges.ysnAccrue, 0) = 1 THEN ISNULL(ReceiptCharges.intEntityVendorId, Receipt.intEntityVendorId) 
				END 
			,[intLocationId] = Receipt.intLocationId
			--DETAIL
			--,[intTransactionDetailId] = ReceiptCharges.intInventoryReceiptChargeId
			,[intInventoryReceiptItemId] = NULL 
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = ReceiptCharges.intInventoryReceiptChargeId
			,[intInventoryReceiptChargeTaxId] = NULL 
			,[intInventoryShipmentChargeId] = NULL 
			,[intInventoryShipmentChargeTaxId] = NULL 
			,[intAccountId] = GLAccount.intAccountId
			,[intItemId] = Charge.intItemId
			,[intItemUOMId] = ReceiptCharges.intCostUOMId
			,[dblQuantity] = 
				CASE 
					/*Negate the other charge if it is an Inventory Return*/
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ReceiptCharges.dblQuantity 

					/*Negate the other charge if it is a "Charge Entity"*/
					WHEN ISNULL(ReceiptCharges.ysnPrice, 0) = 1 THEN 
						-ReceiptCharges.dblQuantity 

					ELSE 
						ReceiptCharges.dblQuantity
				END	
			,[dblAmount] = ReceiptCharges.dblAmount
			,strBatchId = gd.strBatchId
		FROM	dbo.tblICInventoryReceipt Receipt 
				INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharges
					ON ReceiptCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId		
				INNER JOIN tblICItem Charge
					ON Charge.intItemId = ReceiptCharges.intChargeId
				INNER JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ReceiptCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Receipt.intLocationId
				CROSS APPLY dbo.fnGetItemGLAccountAsTable (
					Charge.intItemId
					,ChargeItemLocation.intItemLocationId
					,'AP Clearing'
				) OtherChargesGLAccounts
				INNER JOIN dbo.tblGLAccount GLAccount
					ON GLAccount.intAccountId = OtherChargesGLAccounts.intAccountId							
				CROSS APPLY (
					SELECT TOP 1 
						gd.strBatchId
					FROM tblGLDetail gd
					WHERE
						gd.strTransactionId = Receipt.strReceiptNumber
						AND gd.ysnIsUnposted = 0 
				) gd
		WHERE	Receipt.ysnPosted = 1
				AND (
					ISNULL(ReceiptCharges.ysnAccrue, 0) = 1
					OR ISNULL(ReceiptCharges.ysnPrice, 0) = 1	
				)
				AND ReceiptCharges.dblQuantity IS NOT NULL 
	END 

	-- Populate the Receipt Taxes
	BEGIN 
		-- Receipt Item Taxes
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Receipt.intInventoryReceiptId
			,[strTransactionId] = Receipt.strReceiptNumber
			,[intTransactionType] = 1
			,[strReferenceNumber] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 						
				END	
			,[dtmDate] = Receipt.dtmReceiptDate
			,[intEntityVendorId] = Receipt.intEntityVendorId
			,[intLocationId] = Receipt.intLocationId
			,[intInventoryReceiptItemId] = ReceiptItem.intInventoryReceiptItemId
			,[intInventoryReceiptItemTaxId] = ReceiptTaxes.intInventoryReceiptItemTaxId
			,[intInventoryReceiptChargeId] = NULL 
			,[intInventoryReceiptChargeTaxId] = NULL 
			,[intInventoryShipmentChargeId] = NULL 
			,[intInventoryShipmentChargeTaxId] = NULL 
			,[intAccountId] = ga.intAccountId
			,[intItemId] = ReceiptItem.intItemId
			,[intItemUOMId] = ISNULL(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 			
			,[dblQuantity] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ReceiptTaxes.dblQty
					ELSE
						ReceiptTaxes.dblQty
				END
			,[dblAmount] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ReceiptTaxes.dblTax 
					ELSE
						ReceiptTaxes.dblTax 
				END
			,strBatchId = gd.strBatchId
		FROM	
			dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ReceiptItem.intItemId
				AND ItemLocation.intLocationId = Receipt.intLocationId		
			INNER JOIN tblICItem item
				ON item.intItemId = ReceiptItem.intItemId 
			INNER JOIN dbo.vyuICGetInventoryReceiptItemTax ReceiptTaxes
				ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				item.intItemId
				,ItemLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Receipt.strReceiptNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Receipt.ysnPosted = 1
			AND Receipt.strReceiptType NOT IN ('Transfer Order')
			AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own	

		-- Taxes from the Other Charges that is for the Receipt Vendor. 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Receipt.intInventoryReceiptId
			,[strTransactionId] = Receipt.strReceiptNumber
			,[intTransactionType] = 1 -- RECEIPT
			,[strReferenceNumber] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 						
				END		
			,[dtmDate] = Receipt.dtmReceiptDate
			,[intEntityVendorId] = Receipt.intEntityVendorId
			,[intLocationId] = Receipt.intLocationId
			,[intInventoryReceiptItemId] = NULL 
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = ReceiptCharge.intInventoryReceiptChargeId
			,[intInventoryReceiptChargeTaxId] = ChargeTaxes.intInventoryReceiptChargeTaxId 
			,[intInventoryShipmentChargeId] = NULL  
			,[intInventoryShipmentChargeTaxId] = NULL 
			,[intAccountId] = ga.intAccountId
			,[intItemId] = charge.intItemId
			,[intItemUOMId] = ReceiptCharge.intCostUOMId
			,[dblQuantity] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ChargeTaxes.dblQty
					ELSE
						ChargeTaxes.dblQty
				END
			,[dblAmount] =  
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ChargeTaxes.dblTax
					ELSE
						ChargeTaxes.dblTax
				END
			,strBatchId = gd.strBatchId
		FROM	
			dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
				ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ReceiptCharge.intChargeId
				AND ItemLocation.intLocationId = Receipt.intLocationId		
			INNER JOIN tblICItem charge
				ON charge.intItemId = ReceiptCharge.intChargeId 				
			INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
				ON ReceiptCharge.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				charge.intItemId
				,ItemLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Receipt.strReceiptNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Receipt.ysnPosted = 1
			AND (ReceiptCharge.ysnAccrue = 1 OR ReceiptCharge.ysnPrice = 1) -- Note: Tax is only computed if ysnAccrue is Y or ysnPrice is Y. 

		-- Taxes from the Other Charges that is for the 3rd Party Vendor. 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Receipt.intInventoryReceiptId
			,[strTransactionId] = Receipt.strReceiptNumber
			,[intTransactionType] = 1 -- RECEIPT
			,[strReferenceNumber] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						CASE 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_Blank THEN NULL 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intDebitMemoInvoiceNoOption = @debitMemoInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 
					ELSE
						CASE 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_Blank THEN NULL 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_BOL THEN Receipt.strBillOfLading 
							WHEN @intVoucherInvoiceNoOption = @voucherInvoiceOption_VendorRefNo THEN Receipt.strVendorRefNo 
							ELSE ISNULL(NULLIF(LTRIM(RTRIM(Receipt.strBillOfLading)), ''), Receipt.strVendorRefNo)
						END 						
				END		
			,[dtmDate] = Receipt.dtmReceiptDate
			,[intEntityVendorId] = ReceiptCharge.intEntityVendorId
			,[intLocationId] = Receipt.intLocationId
			,[intInventoryReceiptItemId] = NULL 
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = ReceiptCharge.intInventoryReceiptChargeId
			,[intInventoryReceiptChargeTaxId] = ChargeTaxes.intInventoryReceiptChargeTaxId
			,[intInventoryShipmentChargeId] = NULL 
			,[intInventoryShipmentChargeTaxId] = NULL 
			,[intAccountId] = ga.intAccountId
			,[intItemId] = charge.intItemId
			,[intItemUOMId] = ReceiptCharge.intCostUOMId
			,[dblQuantity] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ChargeTaxes.dblQty
					ELSE
						ChargeTaxes.dblQty
				END
			,[dblAmount] = 
				CASE 
					WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
						-ChargeTaxes.dblTax 
					ELSE
						ChargeTaxes.dblTax 
				END
			,strBatchId = gd.strBatchId
		FROM	
			dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
				ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ReceiptCharge.intChargeId
				AND ItemLocation.intLocationId = Receipt.intLocationId		
			INNER JOIN tblICItem charge
				ON charge.intItemId = ReceiptCharge.intChargeId 				
			INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
				ON ReceiptCharge.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				charge.intItemId
				,ItemLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Receipt.strReceiptNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Receipt.ysnPosted = 1
			AND ReceiptCharge.ysnAccrue = 1 
			AND ReceiptCharge.ysnPrice = 1 		
	END 

	-- Populate the Shipment Charges
	BEGIN 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Shipment.intInventoryShipmentId
			,[strTransactionId] = Shipment.strShipmentNumber
			,[intTransactionType] = 3 -- SHIPMENT CHARGE
			,[strReferenceNumber] = NULL 
			,[dtmDate] = Shipment.dtmShipDate
			,[intEntityVendorId] = ShipmentCharges.intEntityVendorId
			,[intLocationId] = chargeItemLocation.intLocationId 
			,[intInventoryReceiptItemId] = NULL
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = NULL 
			,[intInventoryReceiptChargeTaxId] = NULL 
			,[intInventoryShipmentChargeId] = ShipmentCharges.intInventoryShipmentChargeId
			,[intInventoryShipmentChargeTaxId] = NULL 
			,[intAccountId] = ga.intAccountId
			,[intItemId] = charge.intItemId
			,[intItemUOMId] = ShipmentCharges.intCostUOMId
			,[dblQuantity] = ShipmentCharges.dblQuantity
			,[dblAmount] = ShipmentCharges.dblAmount
			,[strBatchId] = gd.strBatchId
		FROM	
			dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharges
				ON ShipmentCharges.intInventoryShipmentId = Shipment.intInventoryShipmentId
			INNER JOIN tblICItem charge	
				ON charge.intItemId = ShipmentCharges.intChargeId
			INNER JOIN dbo.tblICItemLocation chargeItemLocation
				ON chargeItemLocation.intItemId = ShipmentCharges.intChargeId
				AND chargeItemLocation.intLocationId = Shipment.intShipFromLocationId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				charge.intItemId
				,chargeItemLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Shipment.strShipmentNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Shipment.ysnPosted = 1
			AND ShipmentCharges.ysnAccrue = 1 		
	END 

	-- Populate the Shipment Charge Taxes
	BEGIN 
		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Shipment.intInventoryShipmentId
			,[strTransactionId] = Shipment.strShipmentNumber
			,[intTransactionType] = 3 -- Shipment Charge
			,[strReferenceNumber] = NULL 
			,[dtmDate] = Shipment.dtmShipDate
			,[intEntityVendorId] = ShipmentCharge.intEntityVendorId
			,[intLocationId] = chargeLocation.intLocationId
			,[intInventoryReceiptItemId] = NULL 
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = NULL 
			,[intInventoryReceiptChargeTaxId] = NULL 
			,[intInventoryShipmentChargeId] = ShipmentCharge.intInventoryShipmentChargeId
			,[intInventoryShipmentChargeTaxId] = ChargeTaxes.intInventoryShipmentChargeTaxId
			,[intAccountId] = ga.intAccountId
			,[intItemId] = ShipmentCharge.intChargeId
			,[intItemUOMId] = ShipmentCharge.intCostUOMId
			,[dblQuantity] = ChargeTaxes.dblQty
			,[dblAmount] = CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -ChargeTaxes.dblTax ELSE ChargeTaxes.dblTax END
			,[strBatchId] = gd.strBatchId
		FROM	
			dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
				ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation chargeLocation
				ON chargeLocation.intItemId = ShipmentCharge.intChargeId
				AND chargeLocation.intLocationId = Shipment.intShipFromLocationId		
			INNER JOIN tblICItem charge
				ON charge.intItemId = ShipmentCharge.intChargeId 				
			INNER JOIN dbo.tblICInventoryShipmentChargeTax ChargeTaxes
				ON ShipmentCharge.intInventoryShipmentChargeId = ChargeTaxes.intInventoryShipmentChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				charge.intItemId
				,chargeLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Shipment.strShipmentNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Shipment.ysnPosted = 1
			AND (ShipmentCharge.ysnAccrue = 1 OR ShipmentCharge.ysnPrice = 1) -- Note: Tax is only computed if ysnAccrue is Y or ysnPrice is Y. 

		INSERT INTO tblICAPClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intInventoryReceiptItemId]
			,[intInventoryReceiptItemTaxId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptChargeTaxId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentChargeTaxId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]
			,[strBatchId]
		)
		SELECT 
			[intTransactionId] = Shipment.intInventoryShipmentId
			,[strTransactionId] = Shipment.strShipmentNumber
			,[intTransactionType] = 3 -- Shipment Charge
			,[strReferenceNumber] = NULL 
			,[dtmDate] = Shipment.dtmShipDate
			,[intEntityVendorId] = ShipmentCharge.intEntityVendorId
			,[intLocationId] = chargeLocation.intLocationId
			,[intInventoryReceiptItemId] = NULL 
			,[intInventoryReceiptItemTaxId] = NULL 
			,[intInventoryReceiptChargeId] = NULL 
			,[intInventoryReceiptChargeTaxId] = NULL 
			,[intInventoryShipmentChargeId] = ShipmentCharge.intInventoryShipmentChargeId
			,[intInventoryShipmentChargeTaxId] = ChargeTaxes.intInventoryShipmentChargeTaxId
			,[intAccountId] = ga.intAccountId
			,[intItemId] = ShipmentCharge.intChargeId
			,[intItemUOMId] = ShipmentCharge.intCostUOMId
			,[dblQuantity] = ChargeTaxes.dblQty
			,[dblAmount] = ChargeTaxes.dblTax
			,[strBatchId] = gd.strBatchId
		FROM	
			dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
				ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation chargeLocation
				ON chargeLocation.intItemId = ShipmentCharge.intChargeId
				AND chargeLocation.intLocationId = Shipment.intShipFromLocationId		
			INNER JOIN tblICItem charge
				ON charge.intItemId = ShipmentCharge.intChargeId 				
			INNER JOIN dbo.tblICInventoryShipmentChargeTax ChargeTaxes
				ON ShipmentCharge.intInventoryShipmentChargeId = ChargeTaxes.intInventoryShipmentChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			CROSS APPLY dbo.fnGetItemGLAccountAsTable(
				charge.intItemId
				,chargeLocation.intItemLocationId
				,'AP Clearing'
			) apClearing
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = apClearing.intAccountId
			CROSS APPLY (
				SELECT TOP 1 
					gd.strBatchId
				FROM tblGLDetail gd
				WHERE
					gd.strTransactionId = Shipment.strShipmentNumber
					AND gd.ysnIsUnposted = 0 
			) gd
		WHERE	
			Shipment.ysnPosted = 1
			AND ShipmentCharge.ysnAccrue = 1 
			AND ShipmentCharge.ysnPrice = 1 
	END 
END 

GO

PRINT 'Finished Populating the IC-AP-Clearing'