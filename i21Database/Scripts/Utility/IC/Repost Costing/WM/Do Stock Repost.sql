-- USE i21Demo01

------------------------------------------------------------------------------------------------------------------------------------
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
		,dblOnHand NUMERIC(18,6)
		,dblTransaction NUMERIC(18,6)
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
			-- AND ISNULL(ysnIsUnposted, 0) = 0 -- This where clause will exclude all the unposted transactions. 
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
			,@dblQty AS NUMERIC(18, 6)
			,@intTransactionTypeId AS INT

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
		-- ORDER BY dtmDate ASC 
		ORDER BY intInventoryTransactionId ASC 

		-- Detect if the transaction is posted or not. 
		BEGIN 
			SET @ysnPost = 1 

			SELECT	@strTransactionId = 
						CASE	WHEN RTRIM(LTRIM(ISNULL(@strTransactionId, ''))) <> '' THEN 
									@strTransactionId 
								ELSE 
									ICType.strName + '-' + CAST(@intTransactionId AS NVARCHAR(10))  
						END
			FROM	dbo.tblICInventoryTransactionType ICType
			WHERE	intTransactionTypeId = @intTransactionTypeId

			SELECT	@ysnPost = 0 
			FROM	#tmpICPostedTransactions
			WHERE	strTransactionId = @strTransactionId
		END 

		-- Run the post routine. 
		IF ISNULL(@ysnPost, 1) = 1
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

		ELSE IF @ysnPost = 0 
		BEGIN 
			PRINT 'Unposting ' + @strBatchId

			-- Unpost and re-create the Unpost G/L entries. 
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
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
			)	
			EXEC [dbo].[uspICUnpostCosting]
				@intTransactionId = @intTransactionId 
				,@strTransactionId = @strTransactionId 
				,@strBatchId = @strBatchId 
				,@intEntityUserSecurityId = @intUserId 
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

		-- Monitor the posted status of the transaction 
		BEGIN 
			IF ISNULL(@ysnPost, 1) = 1
			BEGIN 
				PRINT 'Inserting ' + @strTransactionId + ' on #tmpICPostedTransactions'

				INSERT INTO #tmpICPostedTransactions (
					strTransactionId 
				)
				SELECT	@strTransactionId
			END 

			IF ISNULL(@ysnPost, 1) = 0 
			BEGIN 
				PRINT 'Removing ' + @strTransactionId + ' on #tmpICPostedTransactions'

				DELETE	FROM #tmpICPostedTransactions 
				WHERE	strTransactionId = @strTransactionId
			END 
		END 	

		-- Detect discrepancies on the on-hand. 
		BEGIN 			
			IF EXISTS (SELECT TOP 1 1 FROM @ItemsToPost)
			BEGIN 
				SELECT TOP 1 
						@intItemId = intItemId 
				FROM	@ItemsToPost
				
				SET @intReturnId = NULL 
				EXEC @intReturnId = dbo.uspICDetectBadOnHand 
						@intItemId
						,@strTransactionId
						,@strBatchId

				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Stock Discrepancies detected!'
					PRINT '@intItemId, @strTransactionId, @strBatchId'
					PRINT @intItemId 
					PRINT @strTransactionId
					PRINT @strBatchId
				END

				DELETE FROM @ItemsToPost
				WHERE @intItemId = intItemId 
			END 			
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


