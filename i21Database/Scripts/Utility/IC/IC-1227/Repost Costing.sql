------------------------------------------------------------------------------------------------------------------------------------
-- Fix the cost in the Inventory Adjustment 
------------------------------------------------------------------------------------------------------------------------------------

UPDATE	Lot
SET		dblLastCost = 0 
FROM	dbo.tblICLot Lot 

UPDATE	Lot
SET		dblLastCost = dbo.fnCalculateUnitCost(ReceiptItem.dblUnitCost , ItemUOM.dblUnitQty)
FROM	dbo.tblICLot Lot INNER JOIN dbo.tblICInventoryReceiptItemLot ReceiptLot
			ON Lot.intLotId = ReceiptLot.intLotId
		INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
		LEFT JOIN dbo.tblICItemUOM ItemUOM
			ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId

UPDATE	AdjDetail
SET		dblCost =	CASE	WHEN Lot.dblLastCost <> 0 THEN Lot.dblLastCost 
							ELSE AdjDetail.dblCost 
					END 
					* ItemUOM.dblUnitQty 
FROM	dbo.tblICInventoryAdjustmentDetail AdjDetail LEFT JOIN dbo.tblICLot Lot
			ON AdjDetail.intLotId = Lot.intLotId
		LEFT JOIN dbo.tblICItemUOM ItemUOM
			ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId

UPDATE	InvTrans
SET		dblCost = Lot.dblLastCost * ItemUOM.dblUnitQty 
FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICLot Lot
			ON InvTrans.intLotId = Lot.intLotId
		LEFT JOIN dbo.tblICItemUOM ItemUOM
			ON ItemUOM.intItemUOMId = InvTrans.intItemUOMId
WHERE	InvTrans.ysnIsUnposted = 0 
		AND InvTrans.strTransactionId LIKE 'ADJ%'

GO 

------------------------------------------------------------------------------------------------------------------------------------
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

-- Clearing the cost bucket tables. 
DELETE FROM tblICInventoryLot
DELETE FROM tblICInventoryFIFO
DELETE FROM tblICInventoryLIFO

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
		ORDER BY intInventoryTransactionId ASC 

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
			)
			SELECT 	intItemId  
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
			)
			SELECT 	intItemId  
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
			FROM	#tmpICInventoryTransaction
			WHERE	strBatchId = @strBatchId

			EXEC dbo.uspICRepostCosting
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription
				,@ItemsToPost
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