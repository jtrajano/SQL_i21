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
	,ysnINVOpen = 1
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

UPDATE	dbo.tblICLot
SET		dblLastCost = 0 
		--,dblQty = 0 
		--,dblWeight = 0 

-- Execute the repost stored procedure
BEGIN 
	DECLARE @strBatchId AS NVARCHAR(40)
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
								WHEN @strTransactionForm IN ('Consume', 'Produce') THEN 
									'Work in Progress'
								ELSE 
									NULL 
						END

			DELETE FROM @ItemsToPost

			--IF @strBatchId IN ('BATCH-7302', 'BATCH-7309', 'BATCH-7310', 'BATCH-7311')
			--BEGIN 					
			--	SELECT 'DEBUG 1', @strBatchId, dblQty, dblLastCost, * FROM tblICLot WHERE intLotId IN (3168, 3171)
			--	SELECT 'DEBUG 1', @strBatchId, * FROM tblICInventoryTransaction WHERE intLotId IN (3168, 3171)
			--	SELECT 'DEBUG 1', @strBatchId, * FROM @ItemsToPost
			--END 

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
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty)
						,dblCost  = 
							dbo.fnMultiply(
								CASE WHEN ISNULL(Lot.dblLastCost, 0) = 0 THEN 
											(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = ICTrans.intItemId and intItemLocationId = ICTrans.intItemLocationId) 
										ELSE 
											Lot.dblLastCost
								END 
								,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
							)
						,ICTrans.dblSalesPrice  
						,ICTrans.intCurrencyId  
						,ICTrans.dblExchangeRate  
						,ICTrans.intTransactionId  
						,ICTrans.intTransactionDetailId  
						,ICTrans.strTransactionId  
						,ICTrans.intTransactionTypeId  
						,ICTrans.intLotId 
						,ICTrans.intSubLocationId
						,ICTrans.intStorageLocationId
						,strActualCostId = NULL 
				FROM	#tmpICInventoryTransaction ICTrans LEFT JOIN dbo.tblICLot Lot
							ON ICTrans.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
				WHERE	strBatchId = @strBatchId
						AND (
							strTransactionForm = 'Consume'
							OR intTransactionTypeId = 8 
						)

				-- Check if lot is involved in an item change. 
				-- If it is, then update the consume to the new lot id, item id, and item uom id. 
				BEGIN 
					UPDATE	ItemsToConsume
					SET		ItemsToConsume.intItemId = Lot.intItemId
							,ItemsToConsume.intItemUOMId = dbo.fnGetMatchingItemUOMId(Lot.intItemId, ItemsToConsume.intItemUOMId)
							,ItemsToConsume.intItemLocationId = Lot.intItemLocationId 
							,ItemsToConsume.intSubLocationId = Lot.intSubLocationId
							,ItemsToConsume.intStorageLocationId = Lot.intStorageLocationId							
							,ItemsToConsume.intLotId = Lot.intLotId 
					FROM	@ItemsToPost ItemsToConsume LEFT JOIN dbo.tblICLot Lot
								ON ItemsToConsume.intLotId = Lot.intSplitFromLotId
					WHERE	EXISTS (
								SELECT	TOP 1 1
								FROM	#tmpICInventoryTransaction InvTrans
								WHERE	InvTrans.intLotId = Lot.intLotId 
										AND InvTrans.intTransactionTypeId = 15
							)
							AND Lot.intLotId IS NOT NULL
				END 

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
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty)
						,dblCost = ISNULL (
								dbo.fnDivide(
									(SELECT SUM( dbo.fnMultiply(-1, dbo.fnMultiply(dblQty, dblCost)) ) FROM dbo.tblICInventoryTransaction WHERE strTransactionId = @strTransactionId AND strBatchId = @strBatchId) 
									, ICTrans.dblQty
								) 
								, 0
							)
						,ICTrans.dblSalesPrice  
						,ICTrans.intCurrencyId  
						,ICTrans.dblExchangeRate  
						,intTransactionId  
						,ICTrans.intTransactionDetailId  
						,ICTrans.strTransactionId  
						,ICTrans.intTransactionTypeId  
						,ICTrans.intLotId 
						,ICTrans.intSubLocationId
						,ICTrans.intStorageLocationId
						,strActualCostId = NULL 
				FROM	#tmpICInventoryTransaction ICTrans LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
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
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnMultiply(
									(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = ICTrans.intItemId and intItemLocationId = ICTrans.intItemLocationId) 
									,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
								)
						,ICTrans.dblSalesPrice  
						,ICTrans.intCurrencyId  
						,ICTrans.dblExchangeRate  
						,ICTrans.intTransactionId  
						,ICTrans.intTransactionDetailId  
						,ICTrans.strTransactionId  
						,ICTrans.intTransactionTypeId  
						,ICTrans.intLotId 
						,ICTrans.intSubLocationId
						,ICTrans.intStorageLocationId
						,strActualCostId = NULL 
				FROM	#tmpICInventoryTransaction ICTrans LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
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
						,dbo.fnMultiply(TransferSource.dblQty, -1) 
						,ISNULL(ItemUOM.dblUnitQty, TransferSource.dblUOMQty)
						,TransferSource.dblCost 
						,0
						,NULL
						,1
						,TransferSource.intTransactionId  
						,Detail.intInventoryTransferDetailId
						,Header.strTransferNo
						,TransferSource.intTransactionTypeId  
						,Detail.intNewLotId 
						,Detail.intToSubLocationId
						,Detail.intToStorageLocationId
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
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON TransferSource.intItemId = ItemUOM.intItemId
							AND TransferSource.intItemUOMId = ItemUOM.intItemUOMId
				WHERE	Header.strTransferNo = @strTransactionId
						AND TransferSource.strBatchId = @strBatchId

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost
			END
			
			ELSE 
			BEGIN 
								
				-- Update the cost used in the adjustment 
				UPDATE	AdjDetail
				SET		dblCost =	dbo.fnMultiply(
										CASE	WHEN ISNULL(Lot.dblLastCost, 0) = 0 THEN 
													(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = AdjDetail.intItemId and intItemLocationId = dbo.fnICGetItemLocation(AdjDetail.intItemId, Adj.intLocationId))
												ELSE
													ISNULL(Lot.dblLastCost, 0) 
										END								
										,ItemUOM.dblUnitQty 
									)
				FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
						LEFT JOIN dbo.tblICLot Lot
							ON AdjDetail.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
				WHERE	Adj.strAdjustmentNo = @strTransactionId

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
						,ISNULL(ItemUOM.dblUnitQty, RebuilInvTrans.dblUOMQty) 
						,dblCost  = CASE WHEN dblQty < 0 THEN 
											CASE	WHEN Receipt.intInventoryReceiptId IS NOT NULL THEN 
														CASE	-- If there is a Gross/Net UOM, then Cost UOM is relative to the Gross/Net UOM. 
																WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
									
																		CASE	
																				WHEN ISNULL(ReceiptItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ReceiptItem.intItemId) = 0 THEN 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId, RebuilInvTrans.intItemUOMId)
													
																				ELSE 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId, RebuilInvTrans.intItemUOMId)
																		END

																-- If Gross/Net UOM is missing, then Cost UOM is related to the Item UOM. 
																ELSE 

																		CASE	
																				-- It is an non-Lot item. 
																				WHEN ISNULL(ReceiptItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ReceiptItem.intItemId) = 0 THEN 
																					-- Convert the Cost UOM to Item UOM. 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intUnitMeasureId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId, RebuilInvTrans.intItemUOMId)
													
																				-- It is a Lot item. 
																				ELSE 
																					-- Conver the Cost UOM to Item UOM and then to Lot UOM. 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId, RebuilInvTrans.intItemUOMId)
																		END 

														END

													WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														dbo.fnGetItemAverageCost(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) 
													ELSE 
														dbo.fnMultiply(
															(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId) 
															,dblUOMQty
														)
											END 
											
										 WHEN (dblQty > 0 AND ISNULL(Adj.intInventoryAdjustmentId, 0) <> 0) THEN 
											dbo.fnMultiply (
												dbo.fnDivide(
													ISNULL(AdjDetail.dblNewCost, AdjDetail.dblCost) 
													,AdjItemUOM.dblUnitQty
												)
												,ItemUOM.dblUnitQty
											)
											
											
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
						LEFT JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = RebuilInvTrans.intTransactionDetailId 
						LEFT JOIN dbo.tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
						LEFT JOIN dbo.tblARInvoice Invoice
							ON Invoice.intInvoiceId = RebuilInvTrans.intTransactionId
							AND Invoice.strInvoiceNumber = RebuilInvTrans.strTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustment Adj
							ON Adj.strAdjustmentNo = RebuilInvTrans.strTransactionId						
							AND Adj.intInventoryAdjustmentId = RebuilInvTrans.intTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
							AND AdjDetail.intInventoryAdjustmentDetailId = RebuilInvTrans.intTransactionDetailId 
						LEFT JOIN dbo.tblICItemUOM AdjItemUOM
							ON AdjDetail.intItemId = AdjItemUOM.intItemId
							AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuilInvTrans.intItemId = ItemUOM.intItemId
							AND RebuilInvTrans.intItemUOMId = ItemUOM.intItemUOMId
				WHERE	strBatchId = @strBatchId

				--IF @strBatchId IN ('BATCH-7302', 'BATCH-7309', 'BATCH-7310', 'BATCH-7311')
				--BEGIN 					
				--	SELECT 'DEBUG 2', @strBatchId, dblQty, dblLastCost, * FROM tblICLot WHERE intLotId IN (3168, 3171)
				--	SELECT 'DEBUG 2', @strBatchId, * FROM tblICInventoryTransaction WHERE intLotId IN (3168, 3171)
				--	SELECT 'DEBUG 2', @strBatchId, * FROM @ItemsToPost
				--END 

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost
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
					,[strRateType]
					,[intSourceEntityId]
					,[intCommodityId]
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
				
			-- Fix discrepancies when posting Consume and Produce. 
			IF ISNULL(@ysnPost, 1) = 1
			BEGIN 
				PRINT 'Update decimal issue for Produce'

				UPDATE	@GLEntries 
				SET		dblDebit = (SELECT SUM(dblCredit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
				WHERE	strTransactionType = 'Produce'
						--AND dblDebit <> 0 

				UPDATE	@GLEntries 
				SET		dblCredit = (SELECT SUM(dblDebit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
				WHERE	strTransactionType = 'Produce'
						--AND dblCredit <> 0 
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
UPDATE	FYPeriod
SET		ysnOpen = FYPeriodOriginal.ysnOpen
		,ysnINVOpen = FYPeriodOriginal.ysnINVOpen
FROM	tblGLFiscalYearPeriod FYPeriod INNER JOIN tblGLFiscalYearPeriodOriginal FYPeriodOriginal
			ON FYPeriod.intGLFiscalYearPeriodId = FYPeriodOriginal.intGLFiscalYearPeriodId

DROP TABLE tblGLFiscalYearPeriodOriginal

GO

------------------------------------------------------------------------------------------------------------------------------------
-- Update the GL Summary 
------------------------------------------------------------------------------------------------------------------------------------

DELETE [dbo].[tblGLSummary]

INSERT INTO tblGLSummary
SELECT
		intAccountId
		,dtmDate
		,SUM(ISNULL(dblDebit,0)) as dblDebit
		,SUM(ISNULL(dblCredit,0)) as dblCredit
		,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
		,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
		,strCode
		,0 as intConcurrencyId
FROM
	tblGLDetail
WHERE ysnIsUnposted = 0	
GROUP BY intAccountId, dtmDate, strCode

GO