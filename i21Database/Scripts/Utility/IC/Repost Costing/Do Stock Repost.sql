﻿------------------------------------------------------------------------------------------------------------------------------------
-- Open the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
-- Open the fiscal year periods
IF OBJECT_ID('tblGLFiscalYearPeriodOriginal') IS NULL 
BEGIN 
	SELECT	* 
	INTO	tblGLFiscalYearPeriodOriginal
	FROM	tblGLFiscalYearPeriod
END 

UPDATE tblGLFiscalYearPeriod
SET ysnOpen = 1

GO

BEGIN TRANSACTION 

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


BEGIN 
	IF OBJECT_ID('tempdb..#tmpStockDiscrepancies') IS NOT NULL  
		DROP TABLE #tmpStockDiscrepancies

	CREATE TABLE #tmpStockDiscrepancies (
		id INT IDENTITY(1, 1) PRIMARY KEY 
		,strType NVARCHAR(500) 
		,intItemId INT
		,strTransactionId NVARCHAR(50)
		,strBatchId NVARCHAR(50) 
		,intItemUOMId INT 
		,dblOnHand NUMERIC(38, 20)
		,dblTransaction NUMERIC(38, 20)
	)
END 

-- Create a temp table that holds all the items for reposting. 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransaction') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransaction

	SELECT * 
	INTO	#tmpICInventoryTransaction
	FROM	tblICInventoryTransaction
	WHERE	ISNULL(dblQty, 0) <> 0
			AND ISNULL(ysnIsUnposted, 0) = 0 -- This part of the 'WHERE' clause will exclude any unposted transactions during the re-post. 
END

BEGIN 
	IF OBJECT_ID('tempdb..#tmpICPostedTransactions') IS NOT NULL  
		DROP TABLE #tmpICPostedTransactions

	CREATE TABLE #tmpICPostedTransactions (
		strTransactionId NVARCHAR(50) PRIMARY KEY 
	)
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
			,@intTransactionId AS INT 
			,@strTransactionId AS NVARCHAR(50)
			,@GLEntries AS RecapTableType 
			,@intItemId AS INT 
			,@intReturnId AS INT
			,@ysnPost AS BIT 
			,@dblQty AS NUMERIC(38, 20)
			,@intTransactionTypeId AS INT

	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4
			,@ACTUALCOST AS INT = 5

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpICInventoryTransaction) 
	BEGIN 
		SELECT	TOP 1 
				@strBatchId = strBatchId
				,@intUserId = intCreatedUserId
				,@strTransactionForm = strTransactionForm
				,@strTransactionId = strTransactionId
				,@intTransactionId = intTransactionId
				,@intItemId = intItemId
				,@dblQty = dblQty 
				,@intTransactionTypeId = intTransactionTypeId
		FROM	#tmpICInventoryTransaction
		ORDER BY CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC
		-- ORDER BY DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) ASC, CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC 
		-- ORDER BY intInventoryTransactionId ASC 

		-- Run the post routine. 
		BEGIN 
			PRINT 'Posting ' + @strBatchId

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
								WHEN @strTransactionForm = 'Inventory Shipment' AND @strTransactionId LIKE 'SI%' THEN 
									'Cost of Goods'
								WHEN @strTransactionForm = 'Inventory Shipment' AND @strTransactionId NOT LIKE 'SI%' THEN 
									'Inventory In-Transit'
								WHEN @strTransactionForm = 'Inventory Transfer' THEN 
									CASE WHEN EXISTS (SELECT 1 FROM dbo.tblICInventoryTransfer WHERE strTransferNo = @strTransactionId AND strTransferType = 'Location to Location') THEN 
											NULL
										ELSE 
											'Inventory In-Transit'
									END 									
								ELSE 
									NULL 
						END

			DELETE FROM @ItemsToPost

			--IF @strTransactionForm IN ('Consume', 'Produce') 
			IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Consume', 'Produce'))
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
						,dblCost  = (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = #tmpICInventoryTransaction.intItemId and intItemLocationId = #tmpICInventoryTransaction.intItemLocationId) * dblUOMQty  
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
						AND (
							strTransactionForm = 'Consume'
							OR intTransactionTypeId = 8 
						)


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
						,dblCost = ISNULL(
								(SELECT SUM( -1 * dblQty * dblCost ) FROM dbo.tblICInventoryTransaction WHERE strTransactionId = @strTransactionId AND strBatchId = @strBatchId) 
								/ dblQty
								, 0
							)
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
						AND (
							strTransactionForm = 'Produce'
							OR intTransactionTypeId = 9
						)

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost
			END
			--ELSE IF @strTransactionForm = 'Inventory Transfer'
			ELSE IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Inventory Transfer'))
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
						,dblCost  = (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = #tmpICInventoryTransaction.intItemId and intItemLocationId = #tmpICInventoryTransaction.intItemLocationId) * dblUOMQty  
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
						AND dblQty < 0 
					
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
				SELECT 	Detail.intItemId  
						,dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId)
						,TransferSource.intItemUOMId  
						,TransferSource.dtmDate  
						,TransferSource.dblQty * -1 
						,TransferSource.dblUOMQty  
						,TransferSource.dblCost 
						,0
						,NULL
						,1
						,TransferSource.intTransactionId  
						,Detail.intInventoryTransferDetailId
						,Header.strTransferNo
						,TransferSource.intTransactionTypeId  
						,Detail.intLotId 
						,Detail.intFromSubLocationId
						,Detail.intFromStorageLocationId
						,strActualCostId = NULL 
				FROM	tblICInventoryTransferDetail Detail INNER JOIN tblICInventoryTransfer Header 
							ON Header.intInventoryTransferId = Detail.intInventoryTransferId
						INNER JOIN dbo.tblICInventoryTransaction TransferSource
							ON TransferSource.intItemId = Detail.intItemId
							AND TransferSource.intTransactionDetailId = Detail.intInventoryTransferDetailId
							AND TransferSource.intTransactionId = Header.intInventoryTransferId
							AND TransferSource.strTransactionId = Header.strTransferNo
							AND TransferSource.strBatchId = @strBatchId
							AND TransferSource.dblQty < 0
				WHERE	Header.strTransferNo = @strTransactionId
						AND TransferSource.strBatchId = @strBatchId

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost
			END
			
			---- Process Credit Memo
			--ELSE IF (@strTransactionId LIKE 'SI%' AND @dblQty > 0)
			--BEGIN 			
			--	INSERT INTO @ItemsToPost (
			--			intItemId  
			--			,intItemLocationId 
			--			,intItemUOMId  
			--			,dtmDate  
			--			,dblQty  
			--			,dblUOMQty  
			--			,dblCost  
			--			,dblSalesPrice  
			--			,intCurrencyId  
			--			,dblExchangeRate  
			--			,intTransactionId  
			--			,intTransactionDetailId  
			--			,strTransactionId  
			--			,intTransactionTypeId  
			--			,intLotId 
			--			,intSubLocationId
			--			,intStorageLocationId	
			--			,strActualCostId 	
			--	)
			--	SELECT 	RebuilInvTrans.intItemId  
			--			,RebuilInvTrans.intItemLocationId 
			--			,RebuilInvTrans.intItemUOMId  
			--			,RebuilInvTrans.dtmDate  
			--			,RebuilInvTrans.dblQty  
			--			,RebuilInvTrans.dblUOMQty  
			--			,dblCost = CASE		WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
			--									dbo.fnGetItemAverageCost(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) 
			--								ELSE 
			--									(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId) * RebuilInvTrans.dblUOMQty  
			--						END 
			--			,RebuilInvTrans.dblSalesPrice  
			--			,RebuilInvTrans.intCurrencyId  
			--			,RebuilInvTrans.dblExchangeRate  
			--			,RebuilInvTrans.intTransactionId  
			--			,RebuilInvTrans.intTransactionDetailId  
			--			,RebuilInvTrans.strTransactionId  
			--			,RebuilInvTrans.intTransactionTypeId  
			--			,RebuilInvTrans.intLotId 
			--			,RebuilInvTrans.intSubLocationId
			--			,RebuilInvTrans.intStorageLocationId
			--			,strActualCostId = ISNULL(Receipt.strActualCostId, Invoice.strActualCostId) 
			--	FROM	#tmpICInventoryTransaction RebuilInvTrans LEFT JOIN dbo.tblICInventoryReceipt Receipt
			--				ON Receipt.intInventoryReceiptId = RebuilInvTrans.intTransactionId
			--				AND Receipt.strReceiptNumber = RebuilInvTrans.strTransactionId
			--			LEFT JOIN dbo.tblARInvoice Invoice
			--				ON Invoice.intInvoiceId = RebuilInvTrans.intTransactionId
			--				AND Invoice.strInvoiceNumber = RebuilInvTrans.strTransactionId
			--	WHERE	strBatchId = @strBatchId

			--	SELECT 'DEBUG @ItemsToPost', * FROM @ItemsToPost WHERE strTransactionId = ''

			--	EXEC dbo.uspICRepostCosting
			--		@strBatchId
			--		,@strAccountToCounterInventory
			--		,@intUserId
			--		,@strGLDescription
			--		,@ItemsToPost
			--END 
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
											CASE	WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														dbo.fnGetItemAverageCost(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) 
													ELSE 
														(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId) * dblUOMQty  
											END 
											
										 WHEN (dblQty > 0 AND ISNULL(Adj.intInventoryAdjustmentId, 0) <> 0 AND AdjDetail.dblNewCost IS NULL) THEN 
											(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId) * dblUOMQty  

										 WHEN (dblQty > 0 AND strTransactionId LIKE 'SI%' AND dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST) THEN 
											dbo.fnGetItemAverageCost(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) 

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
						,strActualCostId = ISNULL(Receipt.strActualCostId, Invoice.strActualCostId) 
				FROM	#tmpICInventoryTransaction RebuilInvTrans LEFT JOIN dbo.tblICInventoryReceipt Receipt
							ON Receipt.intInventoryReceiptId = RebuilInvTrans.intTransactionId
							AND Receipt.strReceiptNumber = RebuilInvTrans.strTransactionId
						LEFT JOIN dbo.tblARInvoice Invoice
							ON Invoice.intInvoiceId = RebuilInvTrans.intTransactionId
							AND Invoice.strInvoiceNumber = RebuilInvTrans.strTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustment Adj
							ON Adj.strAdjustmentNo = RebuilInvTrans.strTransactionId						
							AND Adj.intInventoryAdjustmentId = RebuilInvTrans.intTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
							AND AdjDetail.intInventoryAdjustmentDetailId = RebuilInvTrans.intTransactionDetailId 
				WHERE	strBatchId = @strBatchId

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost

				UPDATE	AdjDetail
				SET		dblCost =	CASE	WHEN ISNULL(Lot.intLotId, 0) <> 0 THEN Lot.dblLastCost 
											ELSE (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = AdjDetail.intItemId and intItemLocationId = dbo.fnICGetItemLocation(AdjDetail.intItemId, Adj.intLocationId)) --AdjDetail.dblCost 
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

			-- Re-create the Post g/l entries 
			DELETE FROM @GLEntries
			SET @intReturnId = NULL 
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
			)			
			EXEC @intReturnId = dbo.uspICCreateGLEntries
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription					

			IF @intReturnId <> 0 
			BEGIN 
				PRINT 'Error found in uspICCreateGLEntries'
				GOTO STOP_QUERY
			END 
				
			-- For Post
			IF ISNULL(@ysnPost, 1) = 1
			BEGIN 
				PRINT 'Update decimal issue for Produce'

				UPDATE	@GLEntries 
				SET		dblDebit = (SELECT SUM(dblCredit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
				WHERE	strTransactionType = 'Produce'
			END 							
		END 

		-- Book the G/L Entries
		BEGIN 
			BEGIN TRY

				EXEC dbo.uspGLBookEntries @GLEntries, 1 

			END TRY
			BEGIN CATCH
				PRINT 'Error in posting the g/l entries.'
				PRINT @intItemId 
				PRINT @strTransactionId
				PRINT @strBatchId

				SELECT * FROM @GLEntries

				ROLLBACK TRANSACTION 

				GOTO STOP_QUERY
			END CATCH 
		END 

		DELETE FROM #tmpICInventoryTransaction
		WHERE strBatchId = @strBatchId
	END 
END 

COMMIT TRANSACTION 

SELECT '#tmpStockDiscrepancies', * FROM #tmpStockDiscrepancies

STOP_QUERY: 

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
