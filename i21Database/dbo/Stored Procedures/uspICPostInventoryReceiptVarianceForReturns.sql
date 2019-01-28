CREATE PROCEDURE [dbo].[uspICPostInventoryReceiptVarianceForReturns]
	@intInventoryReceiptId AS INT 
	,@strInventortReceiptId AS NVARCHAR(50) 
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intRebuildItemId AS INT = NULL -- Used when rebuilding the stocks. 
AS

DECLARE @AUTO_VARIANCE AS INT = 1

INSERT INTO dbo.tblICInventoryTransaction (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[strTransactionId]
		,[strBatchId]
		,[intTransactionTypeId]
		,[intLotId]
		,[ysnIsUnposted]
		,[intRelatedInventoryTransactionId]
		,[intRelatedTransactionId]
		,[strRelatedTransactionId]
		,[strTransactionForm]
		,[dtmCreated]
		,[intCreatedEntityId]
		,[intConcurrencyId]
		,[intCostingMethod]
		,[strDescription]
		,[intForexRateTypeId]
		,[dblForexRate]
)



SELECT	
		[intItemId] = t.intItemId
		,[intItemLocationId] = t.intItemLocationId
		,[intItemUOMId] = NULL 
		,[intSubLocationId] = NULL 
		,[intStorageLocationId] = NULL 
		,[dtmDate] = t.dtmDate
		,[dblQty] = 0
		,[dblUOMQty] = 0
		,[dblCost] = 0 
		,[dblValue] = 
			-- Return Value
			(
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
					,AggregrateItemLots.dblTotalNet
					,ri.ysnSubCurrency
					,r.intSubCurrencyCents
				)					
			)
			-- Less the Cost Bucket Value
			- 
			(				
				t.dblQty * t.dblCost 
			)
		,[dblSalesPrice] = 0
		,[intCurrencyId] = t.intCurrencyId
		,[dblExchangeRate] = t.dblExchangeRate
		,[intTransactionId] = t.intTransactionId
		,[strTransactionId]	= t.strTransactionId
		,[strBatchId] = t.strBatchId
		,[intTransactionTypeId] = @AUTO_VARIANCE
		,[intLotId] = NULL 
		,[ysnIsUnposted] = 0 
		,[intRelatedInventoryTransactionId] = NULL 
		,[intRelatedTransactionId] = NULL 
		,[strRelatedTransactionId] = NULL 
		,[strTransactionForm] = TransType.strTransactionForm
		,[dtmCreated] = GETDATE()
		,[intCreatedEntityId] = @intEntityUserSecurityId
		,[intConcurrencyId] = 1
		,[intCostingMethod] = t.intCostingMethod
		,[strDescription] = 
					-- 'Returning {Qty} for {Item No}. Return cost is {IR Cost} and cb cost is {Cb Cost}. The inventory adjustment is {Adjustment Value}.'
					dbo.fnFormatMessage(
						'Returning %f %s for %s. Return cost is %f and the costing method is at %f. The inventory adjustment is %f.'
						, ABS(t.dblQty) 
						, u.strUnitMeasure
						, i.strItemNo
						, dbo.fnCalculateReceiptUnitCost(
							ri.intItemId
							,ri.intUnitMeasureId		
							,ri.intCostUOMId
							,ri.intWeightUOMId
							,ri.dblUnitCost
							,ri.dblNet
							,t.intLotId
							,t.intItemUOMId
							,AggregrateItemLots.dblTotalNet
							,ri.ysnSubCurrency
							,r.intSubCurrencyCents
						)	
						, t.dblCost
						, (
							-- Return Value
							(
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
									,AggregrateItemLots.dblTotalNet
									,ri.ysnSubCurrency
									,r.intSubCurrencyCents
								)					
							)
							-- Less the Cost Bucket Value
							- 
							(				
								t.dblQty * t.dblCost 
							)						
						)
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					)
		,[intForexRateTypeId] = t.intForexRateTypeId
		,[dblForexRate]	 = t.dblForexRate	
FROM	dbo.tblICInventoryTransaction t 
		INNER JOIN dbo.tblICInventoryTransactionType TransType
			ON t.intTransactionTypeId = TransType.intTransactionTypeId
		INNER JOIN tblICItem i
			ON i.intItemId = t.intItemId
		INNER JOIN tblICInventoryReceipt r
			ON  r.strReceiptNumber = t.strTransactionId
			AND r.intInventoryReceiptId = t.intTransactionId
		INNER JOIN (
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		)
			ON iu.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICInventoryReceiptItem ri
			ON  ri.intInventoryReceiptId = r.intInventoryReceiptId
			AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
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
			WHERE	ReceiptItem.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		) AggregrateItemLots
		LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
			ON 
			currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
WHERE
	t.intTransactionId = @intInventoryReceiptId
	AND t.strTransactionId = @strInventortReceiptId
	AND t.strBatchId = @strBatchId
	AND t.dblQty < 0 
	AND 
		-- Return Value
		(
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
				,AggregrateItemLots.dblTotalNet
				,ri.ysnSubCurrency
				,r.intSubCurrencyCents
			)					
		)
		-- Less the Cost Bucket Value
		- 
		(				
			t.dblQty * t.dblCost 
		)
		<> 0 	
	AND t.intInTransitSourceLocationId IS NULL
	AND (@intRebuildItemId IS NULL OR t.intItemId = @intRebuildItemId) 
