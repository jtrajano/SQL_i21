﻿CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuation]
	@dtmStartDate AS DATETIME 
	,@strItemNo AS NVARCHAR(50) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intItemId AS INT 

SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo

IF @intItemId IS NULL AND @strItemNo IS NOT NULL 
BEGIN 
	-- 'Item id is invalid or missing.'
	RAISERROR(80001, 11, 1)
	RETURN -1; 
END

-- 'Unable to find an open fiscal year period to match the transaction date.'
IF (dbo.isOpenAccountingDate(@dtmStartDate) = 0) 
BEGIN 
	RAISERROR(50005, 11, 1)
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Inventory') = 0)
BEGIN 
	RAISERROR(51189, 11, 1, 'Inventory')
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Accounts Receivable') = 0)
BEGIN 
	RAISERROR(51189, 11, 1, 'Accounts Receivable')
	RETURN -1; 
END 

DECLARE	@AdjustmentTypeQtyChange AS INT = 1
		,@AdjustmentTypeUOMChange AS INT = 2
		,@AdjustmentTypeItemChange AS INT = 3
		,@AdjustmentTypeLotStatusChange AS INT = 4
		,@AdjustmentTypeSplitLot AS INT = 5
		,@AdjustmentTypeExpiryDateChange AS INT = 6
		,@AdjustmentTypeLotMerge AS INT = 7
		,@AdjustmentTypeLotMove AS INT = 8 

BEGIN TRANSACTION 

-- Return all the "Out" stock qty back to the cost buckets. 
BEGIN 
	UPDATE	LotCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(LotOut.dblQty), 0) 
				FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
							ON LotOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	dbo.fnDateGreaterThanEquals(InvTrans.dtmDate, @dtmStartDate) = 1
						AND LotCostBucket.intInventoryLotId = LotOut.intInventoryLotId
						AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			)
	FROM	dbo.tblICInventoryLot LotCostBucket			
	WHERE	LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId)

	UPDATE	FIFOCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(FIFOOut.dblQty), 0) 
				FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
							ON FIFOOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	dbo.fnDateGreaterThanEquals(InvTrans.dtmDate, @dtmStartDate) = 1
						AND FIFOCostBucket.intInventoryFIFOId = FIFOOut.intInventoryFIFOId
						AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			)
	FROM	dbo.tblICInventoryFIFO FIFOCostBucket
	WHERE	FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId)

	UPDATE	LIFOCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(LIFOOut.dblQty), 0) 
				FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
							ON LIFOOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	dbo.fnDateGreaterThanEquals(InvTrans.dtmDate, @dtmStartDate) = 1
						AND LIFOCostBucket.intInventoryLIFOId = LIFOOut.intInventoryLIFOId
						AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			)
	FROM	dbo.tblICInventoryLIFO LIFOCostBucket
	WHERE	LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId)

	UPDATE	ActualCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(ActualCostOut.dblQty), 0) 
				FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
							ON ActualCostOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	dbo.fnDateGreaterThanEquals(InvTrans.dtmDate, @dtmStartDate) = 1
						AND ActualCostBucket.intInventoryActualCostId = ActualCostOut.intInventoryActualCostId
						AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			)
	FROM	dbo.tblICInventoryActualCost ActualCostBucket
	WHERE	ActualCostBucket.intItemId = ISNULL(@intItemId, ActualCostBucket.intItemId)
END 

-- If stock is received within the date range, then remove also the "out" stock records. 
BEGIN 
	DELETE	LotOut
	FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryLot LotCostBucket
				ON LotOut.intInventoryLotId = LotCostBucket.intInventoryLotId
	WHERE	dbo.fnDateGreaterThanEquals(LotCostBucket.dtmDate, @dtmStartDate) = 1
			AND LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId) 

	DELETE	FIFOOut
	FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN dbo.tblICInventoryFIFO FIFOCostBucket
				ON FIFOOut.intInventoryFIFOId = FIFOCostBucket.intInventoryFIFOId
	WHERE	dbo.fnDateGreaterThanEquals(FIFOCostBucket.dtmDate, @dtmStartDate) = 1
			AND FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId) 

	DELETE	LIFOOut
	FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN dbo.tblICInventoryLIFO LIFOCostBucket
				ON LIFOOut.intInventoryLIFOId = LIFOCostBucket.intInventoryLIFOId
	WHERE	dbo.fnDateGreaterThanEquals(LIFOCostBucket.dtmDate, @dtmStartDate) = 1
			AND LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId) 

	DELETE	ActualCostOut
	FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN dbo.tblICInventoryActualCost ActualCostCostBucket
				ON ActualCostOut.intInventoryActualCostId = ActualCostCostBucket.intInventoryActualCostId
	WHERE	dbo.fnDateGreaterThanEquals(ActualCostCostBucket.dtmDate, @dtmStartDate) = 1
			AND ActualCostCostBucket.intItemId = ISNULL(@intItemId, ActualCostCostBucket.intItemId) 
END 

-- Remove the cost buckets if it is posted within the date range. 
BEGIN 
	DELETE FROM tblICInventoryLot WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1 AND intItemId = ISNULL(@intItemId, intItemId) 
	DELETE FROM tblICInventoryFIFO WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1 AND intItemId = ISNULL(@intItemId, intItemId) 
	DELETE FROM tblICInventoryLIFO WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1 AND intItemId = ISNULL(@intItemId, intItemId) 
	DELETE FROM tblICInventoryActualCost WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1 AND intItemId = ISNULL(@intItemId, intItemId) 
END 

-- Clear the G/L entries 
BEGIN 
	DELETE	GLDetail
	FROM	dbo.tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InvTrans
				ON GLDetail.intJournalLineNo = InvTrans.intInventoryTransactionId
				AND GLDetail.strTransactionId = InvTrans.strTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(GLDetail.dtmDate, @dtmStartDate) = 1
			AND intItemId = ISNULL(@intItemId, intItemId) 
END 

-- Create the temp table. 
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
			AND dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1
			AND intItemId = ISNULL(@intItemId, intItemId) 
END

BEGIN 
	IF OBJECT_ID('tempdb..#tmpICPostedTransactions') IS NOT NULL  
		DROP TABLE #tmpICPostedTransactions

	CREATE TABLE #tmpICPostedTransactions (
		strTransactionId NVARCHAR(50) PRIMARY KEY 
	)
END 

-- Delete the inventory transaction record if it falls within the date range. 
BEGIN 
	DELETE FROM tblICInventoryTransaction WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1
	DELETE FROM tblICInventoryLotTransaction WHERE dbo.fnDateGreaterThanEquals(dtmDate, @dtmStartDate) = 1
END 

--------------------------------------------------------------------
-- Retroactively compute the stocks on Stock-UOM and Stock tables. 
--------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICFixStockQuantities
END 

--------------------------------------------------------------------
-- Retroactively compute the lot Qty and Weight. 
--------------------------------------------------------------------
BEGIN 
	UPDATE	dbo.tblICLot
	SET		dblQty = 0
			,dblWeight = 0 
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 

	UPDATE	UpdateLot
	SET		dblQty = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									InvTrans.intItemUOMId
									, Lot.intItemUOMId
									, InvTrans.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICLot Lot
							ON InvTrans.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
			)
	FROM	dbo.tblICLot UpdateLot 
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 

	UPDATE	dbo.tblICLot
	SET		dblWeight = dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblWeightPerQty, 0)) 	
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 
END 

------------------------------------------------------------------------------
-- Retroactively determine the last cost of the item/lot and also the ave cost.
------------------------------------------------------------------------------
BEGIN 
	UPDATE	ItemPricing 
	SET		dblLastCost = (
				SELECT	TOP 1 
						dbo.fnMultiply(InvTrans.dblCost, InvTrans.dblUOMQty) 
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = ItemPricing.intItemId
						AND InvTrans.intItemLocationId = ItemPricing.intItemLocationId
						AND InvTrans.dblQty > 0 
				ORDER BY InvTrans.dtmDate DESC 
			)
	FROM	tblICItemPricing ItemPricing
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 

	UPDATE	tblICItemPricing 
	SET		dblLastCost = ISNULL(dblLastCost, 0.00) 

	UPDATE	Lot
	SET		dblLastCost = (
				SELECT	TOP 1 
						dbo.fnMultiply(InvTrans.dblCost, InvTrans.dblUOMQty) 
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = Lot.intItemId
						AND InvTrans.intItemLocationId = Lot.intItemLocationId
						AND InvTrans.intLotId = Lot.intLotId
						AND InvTrans.dblQty > 0 
				ORDER BY InvTrans.dtmDate DESC 
			)
	FROM	tblICLot Lot
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 

	UPDATE	tblICLot 
	SET		dblLastCost = ISNULL(dblLastCost, 0.00) 

	UPDATE	ItemPricing
	SET		dblAverageCost = ISNULL(
				dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
				, dblLastCost
			) 
	FROM	dbo.tblICItemPricing ItemPricing 
	WHERE	intItemId = ISNULL(@intItemId, intItemId) 
END 

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
			--,@intItemId AS INT 
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
		IF ISNULL(@isPeriodic, 1) = 1
		BEGIN 
			SELECT	TOP 1 
					@strBatchId = strBatchId
					,@intUserId = intCreatedUserId
					,@strTransactionForm = strTransactionForm
					,@strTransactionId = strTransactionId
					,@intTransactionId = intTransactionId
					--,@intItemId = intItemId
					,@dblQty = dblQty 
					,@intTransactionTypeId = intTransactionTypeId
			FROM	#tmpICInventoryTransaction			
			ORDER BY DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) ASC, CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC 
		END 
		ELSE 
		BEGIN 
			SELECT	TOP 1 
					@strBatchId = strBatchId
					,@intUserId = intCreatedUserId
					,@strTransactionForm = strTransactionForm
					,@strTransactionId = strTransactionId
					,@intTransactionId = intTransactionId
					--,@intItemId = intItemId
					,@dblQty = dblQty 
					,@intTransactionTypeId = intTransactionTypeId
			FROM	#tmpICInventoryTransaction
			ORDER BY CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC
		END 

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
								WHEN @strTransactionForm = 'Invoice' AND @strTransactionId LIKE 'SI%' THEN 
									'Cost of Goods'
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
						,Header.strActualCostId 
				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN dbo.tblICInventoryTransfer Header
							ON ICTrans.strTransactionId = Header.strTransferNo				
						LEFT JOIN dbo.tblICItemUOM ItemUOM
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
						,Header.strActualCostId 
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
						AND Detail.intItemId = ISNULL(@intItemId, Detail.intItemId)

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intUserId
					,@strGLDescription
					,@ItemsToPost
			END	

			-- Special repost routine for the following Inventory adjustments: 
			ELSE IF EXISTS (
				SELECT	1 
				FROM	dbo.tblICInventoryTransactionType 
				WHERE	intTransactionTypeId = @intTransactionTypeId 
						AND strName IN (
							'Inventory Adjustment - Item Change'
							, 'Inventory Adjustment - Split Lot'
							, 'Inventory Adjustment - Lot Merge'
							, 'Inventory Adjustment - Lot Move'
						)
			)
			BEGIN 
				-- Update the cost used in the adjustment 
				UPDATE	AdjDetail
				SET		dblCost =	dbo.fnMultiply(
										CASE	WHEN Lot.intLotId IS NOT NULL  THEN 
													-- If Lot, then get the Lot's last cost. Otherwise, get the item's last cost. 
													CASE	WHEN ISNULL(Lot.dblLastCost, 0) = 0 THEN 
																(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = AdjDetail.intItemId and intItemLocationId = dbo.fnICGetItemLocation(AdjDetail.intItemId, Adj.intLocationId))
															ELSE 
																ISNULL(Lot.dblLastCost, 0) 
													END 
												WHEN dbo.fnGetCostingMethod(AdjDetail.intItemId, ItemLocation.intItemLocationId) = @AVERAGECOST THEN 
													-- It item is using Average Costing, then get the Average Cost. 
													dbo.fnGetItemAverageCost(
														AdjDetail.intItemId
														, ItemLocation.intItemLocationId
														, AdjDetail.intItemUOMId
													) 
												ELSE
													-- Otherwise, get the item's last cost. 
													(	
														SELECT	TOP 1 
																dblLastCost 
														FROM	tblICItemPricing 
														WHERE	intItemId = AdjDetail.intItemId 
																AND intItemLocationId = ItemLocation.intItemLocationId
													)
										END								
										,ItemUOM.dblUnitQty 
									)
				FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intLocationId = Adj.intLocationId 
							AND ItemLocation.intItemId = AdjDetail.intItemId
						LEFT JOIN dbo.tblICLot Lot
							ON AdjDetail.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
				WHERE	Adj.strAdjustmentNo = @strTransactionId
						AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)

				-- Reduce the stock from the source lot. 
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
							,ISNULL(ItemUOM.dblUnitQty, RebuilInvTrans.dblUOMQty) 
							,dblCost = AdjDetail.dblCost
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
							,strActualCostId = NULL 
					FROM	#tmpICInventoryTransaction RebuilInvTrans LEFT JOIN dbo.tblICInventoryAdjustment Adj
								ON Adj.strAdjustmentNo = RebuilInvTrans.strTransactionId						
								AND Adj.intInventoryAdjustmentId = RebuilInvTrans.intTransactionId
							LEFT JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
								AND AdjDetail.intInventoryAdjustmentDetailId = RebuilInvTrans.intTransactionDetailId 
								AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							LEFT JOIN dbo.tblICItemUOM AdjItemUOM
								ON AdjDetail.intItemId = AdjItemUOM.intItemId
								AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
							LEFT JOIN dbo.tblICItemUOM ItemUOM
								ON RebuilInvTrans.intItemId = ItemUOM.intItemId
								AND RebuilInvTrans.intItemUOMId = ItemUOM.intItemUOMId
					WHERE	RebuilInvTrans.strBatchId = @strBatchId
							AND RebuilInvTrans.dblQty < 0

					EXEC dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intUserId
						,@strGLDescription
						,@ItemsToPost
				END 

				-- Add stock to the target lot. 
				BEGIN 
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
					SELECT 	RebuilInvTrans.intItemId  
							,RebuilInvTrans.intItemLocationId 
							,RebuilInvTrans.intItemUOMId  
							,RebuilInvTrans.dtmDate  
							,RebuilInvTrans.dblQty  
							,ISNULL(ItemUOM.dblUnitQty, RebuilInvTrans.dblUOMQty) 
							,dblCost = 
								CASE	WHEN ABS(SourceLot.dblQty) = ABS(RebuilInvTrans.dblQty) AND SourceLot.intItemUOMId = RebuilInvTrans.intItemUOMId THEN	 
											-- Use the same cost from the source lot. 
											SourceLot.dblCost
										ELSE 
											-- Calculate the new cost. 
											dbo.fnDivide(
												dbo.fnMultiply(ABS(SourceLot.dblQty), SourceLot.dblCost) 
												, RebuilInvTrans.dblQty
											) 
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
							,strActualCostId = NULL 
					FROM	#tmpICInventoryTransaction RebuilInvTrans INNER JOIN dbo.tblICInventoryAdjustment Adj
								ON Adj.strAdjustmentNo = RebuilInvTrans.strTransactionId						
								AND Adj.intInventoryAdjustmentId = RebuilInvTrans.intTransactionId
							INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
								AND AdjDetail.intInventoryAdjustmentDetailId = RebuilInvTrans.intTransactionDetailId 
								AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							INNER JOIN dbo.tblICInventoryTransaction SourceLot 
								ON SourceLot.intLotId = AdjDetail.intLotId 
								AND SourceLot.intTransactionId = Adj.intInventoryAdjustmentId 
								AND SourceLot.strTransactionId = Adj.strAdjustmentNo
								AND SourceLot.intTransactionDetailId = AdjDetail.intInventoryAdjustmentDetailId
								AND SourceLot.dblQty < 0

							LEFT JOIN dbo.tblICItemUOM AdjItemUOM
								ON AdjDetail.intItemId = AdjItemUOM.intItemId
								AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
							LEFT JOIN dbo.tblICItemUOM ItemUOM
								ON RebuilInvTrans.intItemId = ItemUOM.intItemId
								AND RebuilInvTrans.intItemUOMId = ItemUOM.intItemUOMId
					WHERE	RebuilInvTrans.strBatchId = @strBatchId
							AND RebuilInvTrans.dblQty > 0
				END
			END 					
			ELSE 
			BEGIN 								
				-- Update the cost used in the adjustment 
				UPDATE	AdjDetail
				SET		dblCost =	dbo.fnMultiply(
										CASE	WHEN Lot.intLotId IS NOT NULL  THEN 
													-- If Lot, then get the Lot's last cost. Otherwise, get the item's last cost. 
													CASE	WHEN ISNULL(Lot.dblLastCost, 0) = 0 THEN 
																(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = AdjDetail.intItemId and intItemLocationId = dbo.fnICGetItemLocation(AdjDetail.intItemId, Adj.intLocationId))
															ELSE 
																ISNULL(Lot.dblLastCost, 0) 
													END 
												WHEN dbo.fnGetCostingMethod(AdjDetail.intItemId, ItemLocation.intItemLocationId) = @AVERAGECOST THEN 
													-- It item is using Average Costing, then get the Average Cost. 
													dbo.fnGetItemAverageCost(
														AdjDetail.intItemId
														, ItemLocation.intItemLocationId
														, AdjDetail.intItemUOMId
													) 
												ELSE
													-- Otherwise, get the item's last cost. 
													(	
														SELECT	TOP 1 
																dblLastCost 
														FROM	tblICItemPricing 
														WHERE	intItemId = AdjDetail.intItemId 
																AND intItemLocationId = ItemLocation.intItemLocationId
													)
										END								
										,ItemUOM.dblUnitQty 
									)
				FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intLocationId = Adj.intLocationId 
							AND ItemLocation.intItemId = AdjDetail.intItemId
						LEFT JOIN dbo.tblICLot Lot
							ON AdjDetail.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
				WHERE	Adj.strAdjustmentNo = @strTransactionId
						AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)

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
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId)
													
																				ELSE 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId)
																		END

																-- If Gross/Net UOM is missing, then Cost UOM is related to the Item UOM. 
																ELSE 

																		CASE	
																				-- It is an non-Lot item. 
																				WHEN ISNULL(ReceiptItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ReceiptItem.intItemId) = 0 THEN 
																					-- Convert the Cost UOM to Item UOM. 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intUnitMeasureId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId)
													
																				-- It is a Lot item. 
																				ELSE 
																					-- Conver the Cost UOM to Item UOM and then to Lot UOM. 
																					dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.dblUnitCost) 
																					+ dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId)
																		END 

														END

													WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														dbo.fnGetItemAverageCost(
															RebuilInvTrans.intItemId
															, RebuilInvTrans.intItemLocationId
															, RebuilInvTrans.intItemUOMId
														) 
													ELSE 
														dbo.fnMultiply(
															(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId) 
															,dblUOMQty
														)
											END 
											
										 WHEN (dblQty > 0 AND ISNULL(Adj.intInventoryAdjustmentId, 0) <> 0) THEN 
											CASE	WHEN Adj.intAdjustmentType = @AdjustmentTypeLotMerge THEN 1 

													ELSE 
														dbo.fnMultiply (
															dbo.fnDivide(
																ISNULL(AdjDetail.dblNewCost, AdjDetail.dblCost) 
																,AdjItemUOM.dblUnitQty
															)
															,ItemUOM.dblUnitQty
														)
											END 											
											
											CASE	WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														-- If using Average Costing, use Ave Cost.
														dbo.fnGetItemAverageCost(
															RebuilInvTrans.intItemId
															, RebuilInvTrans.intItemLocationId
															, RebuilInvTrans.intItemUOMId
														) 
													ELSE
														-- Otherwise, get the last cost. 
														(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId)
											END 

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
							AND ReceiptItem.intItemId = ISNULL(@intItemId, ReceiptItem.intItemId)
						LEFT JOIN dbo.tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							AND ReceiptItemLot.intLotId = RebuilInvTrans.intLotId 
						LEFT JOIN dbo.tblARInvoice Invoice
							ON Invoice.intInvoiceId = RebuilInvTrans.intTransactionId
							AND Invoice.strInvoiceNumber = RebuilInvTrans.strTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustment Adj
							ON Adj.strAdjustmentNo = RebuilInvTrans.strTransactionId						
							AND Adj.intInventoryAdjustmentId = RebuilInvTrans.intTransactionId
						LEFT JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
							AND AdjDetail.intInventoryAdjustmentDetailId = RebuilInvTrans.intTransactionDetailId 
							AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
						LEFT JOIN dbo.tblICItemUOM AdjItemUOM
							ON AdjDetail.intItemId = AdjItemUOM.intItemId
							AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuilInvTrans.intItemId = ItemUOM.intItemId
							AND RebuilInvTrans.intItemUOMId = ItemUOM.intItemUOMId
				WHERE	strBatchId = @strBatchId

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
			)			
			EXEC @intReturnId = dbo.uspICCreateGLEntries
				@strBatchId
				,@strAccountToCounterInventory
				,@intUserId
				,@strGLDescription					

			IF @intReturnId <> 0 
			BEGIN 
				PRINT 'Error found in uspICCreateGLEntries'
				GOTO _EXIT_WITH_ERROR
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
				PRINT @strAccountToCounterInventory

				SELECT * FROM @GLEntries
				GOTO _EXIT_WITH_ERROR
			END CATCH 
		END 

		DELETE FROM #tmpICInventoryTransaction
		WHERE strBatchId = @strBatchId
	END 
END 

-- Rebuild the G/L Summary 
BEGIN 
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
END

COMMIT TRANSACTION 
GOTO _EXIT

_EXIT_WITH_ERROR: 
ROLLBACK TRANSACTION 

_EXIT: 