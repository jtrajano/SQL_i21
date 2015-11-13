﻿------------------------------------------------------------------------------------------------------------------------------------
-- Open the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
SELECT	* 
INTO	tblGLFiscalYearPeriodOriginal
FROM	tblGLFiscalYearPeriod

UPDATE tblGLFiscalYearPeriod
SET ysnOpen = 1

GO

-- Clearing the out tables. 
DELETE FROM tblICInventoryLotOut
DELETE FROM tblICInventoryFIFOOut
DELETE FROM tblICInventoryLIFOOut
DELETE FROM tblICInventoryActualCostOut

-- Clearing the cost bucket tables. 
DELETE FROM tblICInventoryLot
DELETE FROM tblICInventoryFIFO
DELETE FROM tblICInventoryLIFO
DELETE FROM tblICInventoryActualCost

-- Clear the G/L entries 
DELETE	GLDetail
FROM	dbo.tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InvTrans
			ON GLDetail.intJournalLineNo = InvTrans.intInventoryTransactionId
			AND GLDetail.strTransactionId = InvTrans.strTransactionId

-- Create a temp table that holds all the items for reposting. 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransaction') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransaction

	SELECT * 
	INTO	#tmpICInventoryTransaction
	FROM	tblICInventoryTransaction
	WHERE	ISNULL(ysnIsUnposted, 0) = 0
			AND ISNULL(dblQty, 0) <> 0
END 

-- Clear the transaction table. 
DELETE FROM tblICInventoryTransaction
DELETE FROM tblICInventoryLotTransaction

--------------------------
-- Zero out the stocks 
--------------------------
UPDATE tblICItemStockUOM 
SET dblOnHand = 0 

UPDATE tblICItemStock
SET dblUnitOnHand = 0 

UPDATE dbo.tblICLot
SET dblQty = 0
	,dblWeight = 0 

--------------------------
-- Zero out the costs
--------------------------
UPDATE tblICItemPricing
SET dblLastCost = 0 
	,dblAverageCost = 0 
	,dblStandardCost = 0 

UPDATE dbo.tblICLot
SET dblLastCost = 0 

-- Execute the repost stored procedure
BEGIN 
	DECLARE @strBatchId AS NVARCHAR(20)
			,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
			,@intUserId AS INT
			,@strGLDescription AS NVARCHAR(255) = NULL 
			,@ItemsToPost AS ItemCostingTableType 
			,@strTransactionForm AS NVARCHAR(50)
			,@strTransactionId AS NVARCHAR(50)
			,@GLEntries AS RecapTableType 

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpICInventoryTransaction) 
	BEGIN 
		SELECT	TOP 1 
				@strBatchId = strBatchId
				,@intUserId = intCreatedUserId
				,@strTransactionForm = strTransactionForm
				,@strTransactionId = strTransactionId
		FROM	#tmpICInventoryTransaction
		ORDER BY dtmDate ASC 
		-- ORDER BY intInventoryTransactionId ASC 

		PRINT 'PROCESSING ' + @strBatchId

		SET @strGLDescription = 
					CASE	WHEN @strTransactionForm = 'Inventory Adjustment' THEN 
								(SELECT strDescription FROM dbo.tblICInventoryAdjustment WHERE strAdjustmentNo = @strTransactionId)
							ELSE 
								NULL
					END

		SET @strAccountToCounterInventory = 
					CASE	WHEN @strTransactionForm = 'Inventory Adjustment' THEN 
								'Inventory Adjustment'
							WHEN @strTransactionForm = 'Inventory Receipt' THEN 
								'AP Clearing'
							WHEN @strTransactionForm = 'Inventory Shipment' THEN 
								'Inventory In-Transit'
							WHEN @strTransactionForm = 'Inventory Transfer' THEN 
								'Inventory In-Transit'
							ELSE 
								NULL 
					END

		DELETE FROM @ItemsToPost

		IF @strTransactionForm IN ('Consume', 'Produce') 
		BEGIN 
			INSERT INTO @ItemsToPost (
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
			)
			SELECT 	intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost  = (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = #tmpICInventoryTransaction.intItemId) * dblUOMQty  
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
					,strActualCostId = NULL 
			FROM	#tmpICInventoryTransaction
			WHERE	strBatchId = @strBatchId
					AND strTransactionForm = 'Consume'

			EXEC dbo.uspICRepostCosting
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription
				,@ItemsToPost

			DELETE FROM @ItemsToPost

			INSERT INTO @ItemsToPost (
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
			)
			SELECT 	intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost = 
						(SELECT SUM( -1 * dblQty * dblCost ) FROM dbo.tblICInventoryTransaction WHERE strTransactionId = @strTransactionId AND strBatchId = @strBatchId) 
						/ dblQty
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
					,strActualCostId = NULL 
			FROM	#tmpICInventoryTransaction
			WHERE	strBatchId = @strBatchId
					AND strTransactionForm = 'Produce'

			EXEC dbo.uspICRepostCosting
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription
				,@ItemsToPost
		END 
		ELSE 
		BEGIN 
			INSERT INTO @ItemsToPost (
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
			)
			SELECT 	RebuilInvTrans.intItemId  
					,RebuilInvTrans.intItemLocationId 
					,RebuilInvTrans.intItemUOMId  
					,RebuilInvTrans.dtmDate  
					,RebuilInvTrans.dblQty  
					,RebuilInvTrans.dblUOMQty  
					,dblCost  = CASE WHEN dblQty < 0 THEN 
										(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId) * dblUOMQty  
									 --WHEN dblQty > 0 AND strTransactionId LIKE 'ADJ%' THEN 
										--(	
										--	SELECT	TOP 1 
										--			CASE	WHEN ISNULL(Lot.dblLastCost, 0) = 0 THEN ItemPricing.dblLastCost 
										--					ELSE Lot.dblLastCost 
										--			END 
										--	FROM	tblICItem Item LEFT JOIN dbo.tblICItemPricing ItemPricing
										--				ON Item.intItemId = ItemPricing.intItemId
										--				AND ItemPricing.intItemLocationId = RebuilInvTrans.intItemLocationId
										--			LEFT JOIN dbo.tblICLot Lot
										--				ON Lot.intItemId = Item.intItemId 
										--				AND Lot.intLotId = RebuilInvTrans.intLotId
										--				AND Lot.intItemLocationId = RebuilInvTrans.intItemLocationId
										--	WHERE	Item.intItemId = RebuilInvTrans.intItemId
										--) * RebuilInvTrans.dblUOMQty  
									 ELSE 
										RebuilInvTrans.dblCost
								END 
					,RebuilInvTrans.dblSalesPrice  
					,RebuilInvTrans.intCurrencyId  
					,RebuilInvTrans.dblExchangeRate  
					,RebuilInvTrans.intTransactionId  
					,RebuilInvTrans.intTransactionDetailId  
					,RebuilInvTrans.strTransactionId  
					,RebuilInvTrans.intTransactionTypeId  
					,RebuilInvTrans.intLotId 
					,RebuilInvTrans.intSubLocationId
					,RebuilInvTrans.intStorageLocationId
					,strActualCostId = Receipt.strActualCostId
			FROM	#tmpICInventoryTransaction RebuilInvTrans LEFT JOIN dbo.tblICInventoryReceipt Receipt
						ON Receipt.intInventoryReceiptId = RebuilInvTrans.intTransactionId
						AND Receipt.strReceiptNumber = RebuilInvTrans.strTransactionId
			WHERE	strBatchId = @strBatchId

			EXEC dbo.uspICRepostCosting
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription
				,@ItemsToPost

			UPDATE	AdjDetail
			SET		dblCost =	CASE	WHEN ISNULL(Lot.dblLastCost, 0) <> 0 THEN Lot.dblLastCost 
										ELSE AdjDetail.dblCost 
								END 
								* ItemUOM.dblUnitQty 
			FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
						ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
					LEFT JOIN dbo.tblICLot Lot
						ON AdjDetail.intLotId = Lot.intLotId
					LEFT JOIN dbo.tblICItemUOM ItemUOM
						ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
			WHERE	Adj.strAdjustmentNo = @strTransactionId
		END 		

		-- Create the GL Entries
		BEGIN 
			DELETE FROM @GLEntries

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
			)			
			EXEC dbo.uspICCreateGLEntries
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription

			UPDATE	@GLEntries 
			SET		dblDebit = (SELECT SUM(dblCredit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
			WHERE	strTransactionType = 'Produce'

			EXEC dbo.uspGLBookEntries @GLEntries, 1 
		END 

		DELETE FROM #tmpICInventoryTransaction
		WHERE strBatchId = @strBatchId
	END 
END 

GO

------------------------------------------------------------------------------------------------------------------------------------
-- Re-close the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
UPDATE FYPeriod
SET ysnOpen = FYPeriodOriginal.ysnOpen
FROM	tblGLFiscalYearPeriod FYPeriod INNER JOIN tblGLFiscalYearPeriodOriginal FYPeriodOriginal
			ON FYPeriod.intGLFiscalYearPeriodId = FYPeriodOriginal.intGLFiscalYearPeriodId

DROP TABLE tblGLFiscalYearPeriodOriginal

GO