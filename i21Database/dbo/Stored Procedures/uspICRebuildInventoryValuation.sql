CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuation]
	@dtmStartDate AS DATETIME 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intUserId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intItemId AS INT
		,@dtmRebuildDate AS DATETIME = GETDATE() 
		,@intFobPointId AS INT 

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

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

-- Create a snapshot of the gl values
BEGIN
	EXEC uspICCreateGLSnapshotOnRebuildInventoryValuation
		@dtmRebuildDate
END

--BEGIN TRANSACTION 

-- Backup Inventory
DECLARE @strRemarks VARCHAR(200)
DECLARE @strItems VARCHAR(50)

SET @strItems = (CASE WHEN @intItemId IS NOT NULL THEN '"' + @strItemNo + '" item' ELSE 'all items' END)
SET @strRemarks = 'Rebuild inventory for ' + @strItems + ' in a '+
	(CASE @isPeriodic WHEN 1 THEN 'periodic' ELSE 'perpetual' END) + ' order' +
	' from '+ CONVERT(VARCHAR(10), @dtmStartDate, 101) + ' onwards.' 

EXEC dbo.uspICBackupInventory @intUserId = @intUserId, @strOperation = 'Rebuild Inventory', @strRemarks = @strRemarks

-- Return all the "Out" stock qty back to the cost buckets. 
BEGIN 
	UPDATE	LotCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(LotOut.dblQty), 0) 
				FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
							ON LotOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	dbo.fnDateGreaterThanEquals(							
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate
						) = 1
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
				WHERE	dbo.fnDateGreaterThanEquals(
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate
						) = 1
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
				WHERE	dbo.fnDateGreaterThanEquals(
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate
						) = 1
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
				WHERE	dbo.fnDateGreaterThanEquals(
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate
						) = 1
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
	WHERE	dbo.fnDateGreaterThanEquals(				
				CASE WHEN @isPeriodic = 0 THEN LotCostBucket.dtmCreated ELSE LotCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId) 

	DELETE	FIFOOut
	FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN dbo.tblICInventoryFIFO FIFOCostBucket
				ON FIFOOut.intInventoryFIFOId = FIFOCostBucket.intInventoryFIFOId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN FIFOCostBucket.dtmCreated ELSE FIFOCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId) 

	DELETE	LIFOOut
	FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN dbo.tblICInventoryLIFO LIFOCostBucket
				ON LIFOOut.intInventoryLIFOId = LIFOCostBucket.intInventoryLIFOId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN LIFOCostBucket.dtmCreated ELSE LIFOCostBucket.dtmDate END
				, @dtmStartDate
				) = 1
			AND LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId) 

	DELETE	ActualCostOut
	FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN dbo.tblICInventoryActualCost ActualCostCostBucket
				ON ActualCostOut.intInventoryActualCostId = ActualCostCostBucket.intInventoryActualCostId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN ActualCostCostBucket.dtmCreated ELSE ActualCostCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND ActualCostCostBucket.intItemId = ISNULL(@intItemId, ActualCostCostBucket.intItemId) 
END 

-- Restore the original costs
BEGIN 
	UPDATE	CostBucket
	SET		dblCost = CostAdjustment.dblCost
	FROM	dbo.tblICInventoryLotCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			INNER JOIN dbo.tblICInventoryLot CostBucket
				ON CostBucket.intInventoryLotId = CostAdjustment.intInventoryLotId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			AND CostAdjustment.intInventoryCostAdjustmentTypeId = 1 -- Original cost. 
END 

-- Clear the cost adjustments
BEGIN 
	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryLotCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryFIFOCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryLIFOCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryActualCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, intItemId) 
END 

-- Remove the cost buckets if it is posted within the date range. 
BEGIN 
	DELETE	FROM tblICInventoryLot 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 
	
	DELETE	FROM tblICInventoryFIFO 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	FROM tblICInventoryLIFO 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	FROM tblICInventoryActualCost 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 
END 

-- Clear the G/L entries 
BEGIN 
	DELETE	GLDetail
	FROM	dbo.tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InvTrans
				ON  GLDetail.strTransactionId = InvTrans.strTransactionId
				AND GLDetail.intJournalLineNo = InvTrans.intInventoryTransactionId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, intItemId) 
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

	IF OBJECT_ID('tempdb..#tmpUnOrderedICTransaction') IS NOT NULL  
		DROP TABLE #tmpUnOrderedICTransaction

	SELECT	t.* 
	INTO	#tmpUnOrderedICTransaction
	FROM	tblICInventoryTransaction t LEFT JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
	WHERE	1 = CASE	WHEN ty.strName = 'Cost Adjustment' THEN 1 
						WHEN ISNULL(dblQty, 0) <> 0 THEN 1
						ELSE 0
				END 	
			AND ISNULL(ysnIsUnposted, 0) = 0 -- This part of the 'WHERE' clause will exclude any unposted transactions during the re-post. 
			AND dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1
			AND intItemId = ISNULL(@intItemId, intItemId) 

	-- Backup the created dates. 
	BEGIN 
		IF OBJECT_ID('tblICInventoryTransaction_BackupCreatedDate') IS NOT NULL 
		BEGIN 
			DROP TABLE tblICInventoryTransaction_BackupCreatedDate
		END 	

		SELECT	DISTINCT 
				t.strBatchId 
				,t.dtmCreated
		INTO	tblICInventoryTransaction_BackupCreatedDate
		FROM	tblICInventoryTransaction t 
				CROSS APPLY (
					SELECT	TOP 1 *
					FROM	tblICInventoryTransaction 
					WHERE	strBatchId = t.strBatchId
				) result
		WHERE	dbo.fnDateGreaterThanEquals(
					CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
					, @dtmStartDate
				) = 1
				AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
	END 

	-- Intialize #tmpICInventoryTransaction
	SELECT	id = CAST(0 AS INT) 
			,id2 = CAST(0 AS INT) 
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionDetailId
			,strBatchId
			,intTransactionTypeId
			,intLotId
			,ysnIsUnposted
			,intRelatedInventoryTransactionId
			,intRelatedTransactionId
			,strRelatedTransactionId
			,strTransactionForm
			,intCostingMethod
			,dtmCreated
			,strDescription
			,intCreatedUserId
			,intCreatedEntityId
			,intConcurrencyId 
			,intForexRateTypeId
			,dblForexRate
	INTO	#tmpICInventoryTransaction
	FROM	#tmpUnOrderedICTransaction
	WHERE	1 = 0 

	IF ISNULL(@isPeriodic, 0) = 1
	BEGIN 	
		INSERT INTO #tmpICInventoryTransaction
		SELECT	CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
				,intInventoryTransactionId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionDetailId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,ysnIsUnposted
				,intRelatedInventoryTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,strTransactionForm
				,intCostingMethod
				,dtmCreated
				,strDescription
				,intCreatedUserId
				,intCreatedEntityId
				,intConcurrencyId  
				,intForexRateTypeId
				,dblForexRate 
		FROM	#tmpUnOrderedICTransaction
		ORDER BY DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) ASC, CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC , intInventoryTransactionId ASC

		CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransaction_Periodic]
			ON dbo.#tmpICInventoryTransaction(dtmDate ASC, strBatchId ASC);

		EXEC ('CREATE CLUSTERED INDEX [IDX_tmpICInventoryTransaction_Periodic] ON dbo.#tmpICInventoryTransaction([dtmDate] ASC, [id] ASC, [id2] ASC);') 

	END
	ELSE 
	BEGIN 
		INSERT INTO #tmpICInventoryTransaction
		SELECT	CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
				,intInventoryTransactionId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionDetailId
				,strBatchId
				,intTransactionTypeId
				,intLotId
				,ysnIsUnposted
				,intRelatedInventoryTransactionId
				,intRelatedTransactionId
				,strRelatedTransactionId
				,strTransactionForm
				,intCostingMethod
				,dtmCreated
				,strDescription
				,intCreatedUserId
				,intCreatedEntityId
				,intConcurrencyId 
				,intForexRateTypeId
				,dblForexRate 
		FROM	#tmpUnOrderedICTransaction
		ORDER BY CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC

		CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransaction_Perpetual]
			ON dbo.#tmpICInventoryTransaction(strBatchId ASC);

		EXEC ('CREATE CLUSTERED INDEX [IDX_tmpICInventoryTransaction_Perpetual] ON dbo.#tmpICInventoryTransaction([id] ASC, [id2] ASC);') 
	END

END

-- Delete the inventory transaction record if it falls within the date range. 
BEGIN 
	DELETE	FROM tblICInventoryTransaction 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 

	DELETE	FROM tblICInventoryLotTransaction 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND intItemId = ISNULL(@intItemId, intItemId) 
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
			,@intEntityUserSecurityId AS INT
			,@strGLDescription AS NVARCHAR(255) = NULL 
			,@ItemsToPost AS ItemCostingTableType 
			,@ItemsForInTransitCosting AS ItemInTransitCostingTableType
			,@strTransactionForm AS NVARCHAR(50)
			,@intTransactionId AS INT 
			,@strTransactionId AS NVARCHAR(50)
			,@GLEntries AS RecapTableType 
			,@intReturnId AS INT
			,@ysnPost AS BIT 
			,@dblQty AS NUMERIC(38, 20)
			,@intTransactionTypeId AS INT

	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4
			,@ACTUALCOST AS INT = 5

	-- Get the functional currency
	BEGIN 
		DECLARE @intFunctionalCurrencyId AS INT 
		SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	END 


	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpICInventoryTransaction) 
	BEGIN 
		SELECT	TOP 1 
				@strBatchId = strBatchId
				,@intEntityUserSecurityId = intCreatedUserId
				,@strTransactionForm = strTransactionForm
				,@strTransactionId = strTransactionId
				,@intTransactionId = intTransactionId
				,@dblQty = dblQty 
				,@intTransactionTypeId = intTransactionTypeId
		FROM	#tmpICInventoryTransaction

		-- Run the post routine. 
		BEGIN 
			PRINT 'Posting ' + @strBatchId

			-- Setup the GL Description
			SET @strGLDescription = 
						CASE	WHEN @strTransactionForm = 'Inventory Adjustment' THEN 
									(SELECT strDescription FROM dbo.tblICInventoryAdjustment WHERE strAdjustmentNo = @strTransactionId)
								ELSE 
									NULL
						END

			-- Setup the contra-gl account to use. 
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

			-- Clear the data on @ItemsToPost
			DELETE FROM @ItemsToPost
			DELETE FROM @ItemsForInTransitCosting

			-- Repost the Bill cost adjustments
			IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Cost Adjustment') AND ISNULL(@strTransactionForm, 'Bill') IN ('Bill'))
			BEGIN 
				PRINT 'Reposting Bill Cost Adjustments: ' + @strTransactionId
				
				-- uspICRepostBillCostAdjustment creates and posts it own g/l entries 
				EXEC uspICRepostBillCostAdjustment
					@strTransactionId
					,@strBatchId
					,@intEntityUserSecurityId
					,@ysnRegenerateBillGLEntries
			END
			IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Cost Adjustment') AND @strTransactionForm IN ('Settle Storage'))
			BEGIN 
				PRINT 'Reposting Settle Storage Cost Adjustments: ' + @strTransactionId
				
				-- uspICRepostSettleStorageCostAdjustment creates and posts it own g/l entries 
				EXEC uspICRepostSettleStorageCostAdjustment
					@strTransactionId
					,@strBatchId
					,@intEntityUserSecurityId
			END

			-- Repost 'Consume' and 'Produce'
			ELSE IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Consume', 'Produce'))
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty)
						,dblCost  = 
							dbo.fnMultiply(
								CASE WHEN Lot.dblLastCost IS NULL THEN 
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
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate

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
					,@intEntityUserSecurityId
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty)
						,dblCost = ISNULL (
								ROUND(
									dbo.fnDivide(
										(	SELECT SUM (
														-- Round the values of each of the items. 
														- ROUND(CAST(dbo.fnMultiply(dblQty, dblCost) + dblValue AS NUMERIC(18, 6)) ,2)
													)												
											FROM	dbo.tblICInventoryTransaction 
											WHERE	strTransactionId = @strTransactionId 
													AND strBatchId = @strBatchId
													AND intTransactionId = @intTransactionId
										) 
										, ICTrans.dblQty
									) 
									, 6
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
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
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
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost

				-- Special delete on #tmpICInventoryTransaction
				-- Produce and Consume transactions typically shares a batch but hold different transaction ids. 
				DELETE	FROM #tmpICInventoryTransaction
				WHERE	strBatchId = @strBatchId
			END

			-- Repost 'Inventory Transfer'
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnMultiply(
									ISNULL(lot.dblLastCost, (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = ICTrans.intItemId and intItemLocationId = ICTrans.intItemLocationId))
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
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN dbo.tblICInventoryTransfer Header
							ON ICTrans.strTransactionId = Header.strTransferNo				
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = ICTrans.intLotId
				WHERE	strBatchId = @strBatchId
						AND ICTrans.dblQty < 0 
					
				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	Detail.intItemId  
						,dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId)
						,TransferSource.intItemUOMId  
						,TransferSource.dtmDate  
						,-TransferSource.dblQty
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
						,TransferSource.intForexRateTypeId
						,TransferSource.dblForexRate
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
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
			END	

			-- Repost the following type of Inventory Adjustment:
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
				SET		dblCost =	CASE	WHEN Lot.intLotId IS NOT NULL  THEN 
												-- If Lot, then get the Lot's last cost. Otherwise, get the item's last cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(Lot.dblLastCost, ISNULL(ItemPricing.dblLastCost, 0)))
											WHEN dbo.fnGetCostingMethod(AdjDetail.intItemId, ItemLocation.intItemLocationId) = @AVERAGECOST THEN 
												-- It item is using Average Costing, then get the Average Cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(ItemPricing.dblAverageCost, 0)) 
											ELSE
												-- Otherwise, get the item's last cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(ItemPricing.dblLastCost, 0))
									END								
				FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intLocationId = Adj.intLocationId 
							AND ItemLocation.intItemId = AdjDetail.intItemId
						LEFT JOIN dbo.tblICLot Lot
							ON AdjDetail.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM StockUnit
							ON StockUnit.intItemId = AdjDetail.intItemId
							AND ISNULL(StockUnit.ysnStockUnit, 0) = 1
						LEFT JOIN dbo.tblICItemPricing ItemPricing
							ON ItemPricing.intItemId = Lot.intItemId
							AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId

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
							,intForexRateTypeId
							,dblForexRate
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
							,RebuilInvTrans.intForexRateTypeId
							,RebuilInvTrans.dblForexRate
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
						,@intEntityUserSecurityId
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
							,intForexRateTypeId
							,dblForexRate
					)
					SELECT 	ISNULL(AdjDetail.intNewItemId, AdjDetail.intItemId)
							,ISNULL(NewLotItemLocation.intItemLocationId, SourceLotItemLocation.intItemLocationId) 
							,intItemUOMId = 
									-- Try to use the new-lot's weight UOM id. 
									-- Otherwise, use the new-lot's item uom id. 
									CASE	WHEN NewLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId IS NOT NULL THEN 
												NewLot.intWeightUOMId
											ELSE 
												NewLot.intItemUOMId												
									END 
							,Adj.dtmAdjustmentDate
							,dblQty = 
											-- Try to use the Weight UOM Qty. 
									CASE	WHEN SourceLot.intWeightUOMId IS NOT NULL AND NewLot.intWeightUOMId IS NOT NULL THEN -- There is a new weight UOM Id. 
												ISNULL(
													AdjDetail.dblNewWeight
													,CASE	-- New Lot has the same weight UOM Id. 	
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN															
																-FromStock.dblQty
														
															-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
																dbo.fnMultiply(
																	ISNULL(AdjDetail.dblNewSplitLotQuantity, -FromStock.dblQty) 
																	,NewLot.dblWeightPerQty
																)

															--New Lot has a different weight UOM Id. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, -FromStock.dblQty
																)
															--New Lot has a different weight UOM Id but source lot was reduced by bags. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																)
													END 
												)
											-- Else, use the Item UOM Qty
											ELSE 
												ISNULL(
													AdjDetail.dblNewSplitLotQuantity 
													,CASE	WHEN SourceLot.intWeightUOMId = FromStock.intItemUOMId AND ISNULL(SourceLot.dblWeightPerQty, 0) <> 0 THEN 
																-- From stock is in source-lot's weight UOM Id. 
																-- Convert it to source-lot's item UOM Id. 
																-- and then convert it to the new-lot's item UOM Id. 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, dbo.fnDivide(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																)
															ELSE 
																-- 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, -FromStock.dblQty
																)
													END 
												) 
									END

							,dblUOMQty = 
										CASE	WHEN NewLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId IS NOT NULL THEN 
													NewLotWeightUOM.dblUnitQty
												ELSE 
													NewLotItemUOM.dblUnitQty
										END 

							,dblCost = 
											-- Try to get the cost in terms of Weight UOM. 
									CASE	WHEN SourceLot.intWeightUOMId IS NOT NULL AND NewLot.intWeightUOMId IS NOT NULL THEN -- There is a new weight UOM Id. 
												CASE	-- New Lot has the same weight UOM Id. 	
														WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN															
																	-- Compute a new cost if there is a new weight. 
															CASE	WHEN ISNULL(AdjDetail.dblNewWeight, 0) <> 0 THEN 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty 
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																						StockUnit.intItemUOMId
																						, SourceLotItemUOM.intWeightUOMId
																						, dbo.fnDivide(AdjDetail.dblNewCost, SourceLotItemUOM.dblUnitQty) 
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)		
																			,AdjDetail.dblNewWeight
																		)
																	ELSE 
																		ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																				StockUnit.intItemUOMId
																				, SourceLotItemUOM.intWeightUOMId
																				, dbo.fnDivide(AdjDetail.dblNewCost, SourceLotItemUOM.dblUnitQty) 
																			)	
																			-- otherwise, use the cost coming from the cost bucket. 
																			, FromStock.dblCost
																		)
															END 
														
														-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
														WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
															-- Convert the cost in terms of weight UOM. 

																	-- Compute a new cost if there is a new weight. 
															CASE	WHEN ISNULL(AdjDetail.dblNewWeight, 0) <> 0 THEN 
																
																		dbo.fnDivide(
																			dbo.fnMultiply( 
																				-FromStock.dblQty
																				,ISNULL(AdjDetail.dblNewCost, FromStock.dblCost)	
																			)
																		
																			,AdjDetail.dblNewWeight
																		)
																	ELSE
																		-- Get the value of the stock
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(AdjDetail.dblNewCost, FromStock.dblCost)	
																			)
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLotWeightUOM.intItemUOMId
																				, NewLotWeightUOM.intItemUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																			)
																		)
															END															

														--New Lot has a different weight UOM Id. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
														-- Convert the source weight into the new lot weight. 

																	-- Compute a new cost if there is new weight. 
															CASE	WHEN ISNULL(AdjDetail.dblNewWeight, 0) <> 0 THEN 
																		
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(AdjDetail.dblNewCost, SourceLotItemUOM.dblUnitQty) 
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)
																			,AdjDetail.dblNewWeight
																		)

																	ELSE 

																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(AdjDetail.dblNewCost, SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)	
																			)
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, -FromStock.dblQty
																			)
																		)

															END
															
														--New Lot has a different weight UOM Id but source lot was reduced by bags. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 

															CASE	WHEN ISNULL(AdjDetail.dblNewWeight, 0) <> 0 THEN 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(AdjDetail.dblNewCost, FromStock.dblCost)
																			)
																			,AdjDetail.dblNewWeight
																		)

																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(AdjDetail.dblNewCost, FromStock.dblCost)
																			)
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty) 
																			)
																		)
															END
												END 
											-- Else, use the cost in termns of Item UOM. 
											ELSE 
												ISNULL(
													AdjDetail.dblNewCost
													,CASE	WHEN SourceLot.intWeightUOMId = FromStock.intItemUOMId AND ISNULL(SourceLot.dblWeightPerQty, 0) <> 0 THEN 
																-- From-stock is in source-lot's weight UOM Id. 
																-- Convert it to source-lot's item UOM Id. 
																-- and then convert it to the new-lot's item UOM Id. 
																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(dbo.fnDivide(AdjDetail.dblNewCost, NewLotItemUOM.dblUnitQty), FromStock.dblCost)
																	)
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, dbo.fnDivide(-FromStock.dblQty,SourceLot.dblWeightPerQty) 
																	)
																)

															ELSE 
																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(AdjDetail.dblNewCost, FromStock.dblCost)
																	)
																
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, -FromStock.dblQty
																	)
																)
														END
													)
									END
							,dblSalesPrice			= 0
							,intCurrencyId			= NULL 
							,dblExchangeRate		= 1
							,intTransactionId		= Adj.intInventoryAdjustmentId
							,intTransactionDetailId = AdjDetail.intInventoryAdjustmentDetailId
							,strTransactionId		= Adj.strAdjustmentNo
							,intTransactionTypeId	= @intTransactionTypeId
							,intLotId				= AdjDetail.intNewLotId
							,intSubLocationId		= ISNULL(AdjDetail.intNewSubLocationId, AdjDetail.intSubLocationId)
							,intStorageLocationId	= ISNULL(AdjDetail.intNewStorageLocationId, AdjDetail.intStorageLocationId)
							,strActualCostId		= NULL 
							,intForexRateTypeId		= NULL
							,dblForexRate			= NULL 
					FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId

							INNER JOIN dbo.tblICInventoryTransaction FromStock 
								ON FromStock.intLotId = AdjDetail.intLotId 
								AND FromStock.intTransactionId = Adj.intInventoryAdjustmentId 
								AND FromStock.strTransactionId = Adj.strAdjustmentNo
								AND FromStock.intTransactionDetailId = AdjDetail.intInventoryAdjustmentDetailId
								AND FromStock.dblQty < 0

							-- Source Lot
							INNER JOIN dbo.tblICLot SourceLot
								ON SourceLot.intLotId = FromStock.intLotId
							INNER JOIN dbo.tblICItemLocation SourceLotItemLocation 
								ON SourceLotItemLocation.intLocationId = Adj.intLocationId 
								AND SourceLotItemLocation.intItemId = SourceLot.intItemId
							LEFT JOIN dbo.tblICItemUOM SourceLotItemUOM
								ON SourceLotItemUOM.intItemUOMId = SourceLot.intItemUOMId
								AND SourceLotItemUOM.intItemId = SourceLot.intItemId
							LEFT JOIN dbo.tblICItemUOM SourceLotWeightUOM 
								ON SourceLotWeightUOM.intItemUOMId = SourceLot.intWeightUOMId
								AND SourceLotWeightUOM.intItemId = SourceLot.intItemId
							-- New Lot 
							LEFT JOIN dbo.tblICLot NewLot
								ON NewLot.intLotId = AdjDetail.intNewLotId
							LEFT JOIN dbo.tblICItemLocation NewLotItemLocation 
								ON NewLotItemLocation.intLocationId = ISNULL(AdjDetail.intNewLocationId, Adj.intLocationId) 
								AND NewLotItemLocation.intItemId = ISNULL(AdjDetail.intNewItemId, NewLot.intItemId)
							LEFT JOIN dbo.tblICItemUOM NewLotItemUOM
								ON NewLotItemUOM.intItemUOMId = NewLot.intItemUOMId
								AND NewLotItemUOM.intItemId = ISNULL(AdjDetail.intNewItemId, NewLot.intItemId)
							LEFT JOIN dbo.tblICItemUOM NewLotWeightUOM
								ON NewLotWeightUOM.intItemUOMId = NewLot.intWeightUOMId
								AND NewLotWeightUOM.intItemId = ISNULL(AdjDetail.intNewItemId, NewLot.intItemId)

							LEFT JOIN dbo.tblICItemUOM StockUnit 
								ON StockUnit.intItemId = AdjDetail.intItemId
								AND StockUnit.ysnStockUnit = 1

					WHERE	Adj.strAdjustmentNo = @strTransactionId
							AND FromStock.strBatchId = @strBatchId

					EXEC dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
				END
			END
			
			-- Repost 'Inventory Shipment'
			ELSE IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Inventory Shipment')) 
			BEGIN 
				SET @intFobPointId = NULL 

				SELECT	TOP 1   
						@intFobPointId = fp.intFobPointId
				FROM	tblICInventoryShipment s LEFT JOIN tblSMFreightTerms ft
							ON s.intFreightTermId = ft.intFreightTermId
						LEFT JOIN tblICFobPoint fp
							ON fp.strFobPoint = ft.strFobPoint
				WHERE	s.strShipmentNumber = @strTransactionId  		

				SELECT	@strAccountToCounterInventory = NULL 
				WHERE	ISNULL(@intFobPointId, @FOB_ORIGIN) = @FOB_DESTINATION 

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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnMultiply(
									ISNULL(lot.dblLastCost, (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = ICTrans.intItemId and intItemLocationId = ICTrans.intItemLocationId))
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
						,strActualCostId = NULL --shipment.strActualCostId 
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate

				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN tblICItemLocation ItemLocation 
							ON ICTrans.intItemLocationId = ItemLocation.intItemLocationId 
						INNER JOIN tblICInventoryShipment shipment
							ON ICTrans.strTransactionId = shipment.strShipmentNumber
						INNER JOIN tblICInventoryShipmentItem shipmentItem
							ON shipmentItem.intInventoryShipmentId = shipment.intInventoryShipmentId
							AND shipmentItem.intInventoryShipmentItemId = ICTrans.intTransactionDetailId
							AND shipmentItem.intItemId = ICTrans.intItemId
							AND shipmentItem.intItemId = ISNULL(@intItemId, shipmentItem.intItemId)
						LEFT JOIN tblICInventoryShipmentItemLot shipmentItemLot
							ON shipmentItemLot.intInventoryShipmentItemId = shipmentItem.intInventoryShipmentItemId 
							AND ISNULL(shipmentItemLot.intLotId, 0) = ICTrans.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN tblICLot lot
							ON lot.intLotId = shipmentItemLot.intLotId
				WHERE	strBatchId = @strBatchId
						AND ICTrans.dblQty < 0 
						AND ItemLocation.intLocationId IS NOT NULL
					
				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost

				-- Empty the gl entries variable. 
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
				)			
				EXEC dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL  
					,@intItemId -- This is only used when rebuilding the stocks. 
					
				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Error found in uspICCreateGLEntries - Inventory Shipment'
					GOTO _EXIT_WITH_ERROR
				END 			

				INSERT INTO @ItemsForInTransitCosting (
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
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId]
					,[intFobPointId]
					,[intInTransitSourceLocationId]
				)
				SELECT 	
						[intItemId] 
						,[intItemLocationId] 
						,[intItemUOMId] 
						,[dtmDate] 
						,-[dblQty] 
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
						,[intTransactionId] 
						,[strTransactionId] 
						,[intTransactionDetailId] 
						,[intFobPointId] = @intFobPointId
						,[intInTransitSourceLocationId] = t.intItemLocationId
				FROM	tblICInventoryTransaction t
				WHERE	t.strTransactionId = @strTransactionId
						AND t.ysnIsUnposted = 0 
						AND t.strBatchId = @strBatchId
						AND @intFobPointId = @FOB_DESTINATION
						AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 
						AND t.intItemId = ISNULL(@intItemId, t.intItemId)

				EXEC dbo.uspICRepostInTransitCosting
					@ItemsForInTransitCosting
					,@strBatchId
					,NULL 
					,@intEntityUserSecurityId
					,@strGLDescription

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
				EXEC @intReturnId = dbo.uspICCreateGLEntriesForInTransitCosting 
					@strBatchId
					,NULL 
					,@intEntityUserSecurityId
					,@strGLDescription
					,@intItemId

				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Inventory Shipment'
					GOTO _EXIT_WITH_ERROR
				END 	
			END
			 				
			-- Repost 'Invoice'
			ELSE IF EXISTS (SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = @intTransactionTypeId AND strName IN ('Invoice')) OR @strTransactionId LIKE 'SI%'
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	RebuilInvTrans.intItemId  
						,RebuilInvTrans.intItemLocationId 
						,RebuilInvTrans.intItemUOMId  
						,RebuilInvTrans.dtmDate  
						,RebuilInvTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, RebuilInvTrans.dblUOMQty) 
						,dblCost  = CASE
										WHEN RebuilInvTrans.dblQty < 0 THEN 
											CASE	
													WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														dbo.fnGetItemAverageCost(
															RebuilInvTrans.intItemId
															, RebuilInvTrans.intItemLocationId
															, RebuilInvTrans.intItemUOMId
														) 
													ELSE 
														dbo.fnMultiply(
															ISNULL(lot.dblLastCost, (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId))
															,dblUOMQty
														)
											END 

										-- When it is a credit memo:
										WHEN (RebuilInvTrans.dblQty > 0 AND RebuilInvTrans.strTransactionId LIKE 'SI%') THEN 
											
											CASE	WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														-- If using Average Costing, use Ave Cost.
														dbo.fnGetItemAverageCost(
															RebuilInvTrans.intItemId
															, RebuilInvTrans.intItemLocationId
															, RebuilInvTrans.intItemUOMId
														) 
													ELSE
														-- Otherwise, get the last cost. 
														ISNULL(lot.dblLastCost, (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId))
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
						,strActualCostId = Invoice.strActualCostId
						,RebuilInvTrans.intForexRateTypeId
						,RebuilInvTrans.dblForexRate

				FROM	#tmpICInventoryTransaction RebuilInvTrans INNER JOIN tblICItemLocation ItemLocation
							ON RebuilInvTrans.intItemLocationId = ItemLocation.intItemLocationId
						LEFT JOIN dbo.tblARInvoice Invoice
							ON Invoice.intInvoiceId = RebuilInvTrans.intTransactionId
							AND Invoice.strInvoiceNumber = RebuilInvTrans.strTransactionId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuilInvTrans.intItemId = ItemUOM.intItemId
							AND RebuilInvTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = RebuilInvTrans.intLotId 
				WHERE	RebuilInvTrans.strBatchId = @strBatchId
						AND RebuilInvTrans.intTransactionId = @intTransactionId
						AND ItemLocation.intLocationId IS NOT NULL -- It ensures that the item is not In-Transit. 
						AND RebuilInvTrans.intItemId = ISNULL(@intItemId, RebuilInvTrans.intItemId)

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost

				-- Empty the gl entries variable. 
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
				)			
				EXEC dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL 
					,@intItemId -- This is only used when rebuilding the stocks. 
						
				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Error found in uspICCreateGLEntries - Invoice'
					GOTO _EXIT_WITH_ERROR
				END 			

				INSERT INTO @ItemsForInTransitCosting (
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
						,[intSourceTransactionId] 
						,[strSourceTransactionId] 
						,[intSourceTransactionDetailId] 
						,[intFobPointId] 
						,[intInTransitSourceLocationId]
				)
				SELECT
						[intItemId]					= t.intItemId
						,[intItemLocationId]		= t.intItemLocationId
						,[intItemUOMId]				= t.intItemUOMId
						,[dtmDate]					= i.dtmShipDate
						,[dblQty]					= -t.dblQty
						,[dblUOMQty]				= t.dblUOMQty
						,[dblCost]					= t.dblCost
						,[dblValue]					= 0
						,[dblSalesPrice]			= id.dblPrice
						,[intCurrencyId]			= i.intCurrencyId
						,[dblExchangeRate]			= 1.00
						,[intTransactionId]			= i.intInvoiceId
						,[intTransactionDetailId]	= id.intInvoiceDetailId
						,[strTransactionId]			= i.strInvoiceNumber
						,[intTransactionTypeId]		= @intTransactionTypeId
						,[intLotId]					= t.intLotId
						,[intSourceTransactionId]	= t.intTransactionId
						,[strSourceTransactionId]		= t.strTransactionId
						,[intSourceTransactionDetailId] = t.intTransactionDetailId
						,[intFobPointId]				= t.intFobPointId
						,[intInTransitSourceLocationId]	= t.intInTransitSourceLocationId
					FROM	
						tblARInvoice i INNER JOIN tblARInvoiceDetail id 
							ON i.intInvoiceId = id.intInvoiceId
						INNER JOIN tblICInventoryShipmentItem si 
							ON si.intInventoryShipmentItemId = id.intInventoryShipmentItemId
						INNER JOIN tblICInventoryTransaction t
							ON t.intTransactionId = si.intInventoryShipmentId
							AND t.intTransactionDetailId = si.intInventoryShipmentItemId
							AND t.ysnIsUnposted = 0 
				WHERE	t.intFobPointId = @FOB_DESTINATION
						AND i.strInvoiceNumber = @strTransactionId
						AND id.intItemId = ISNULL(@intItemId, id.intItemId)

				EXEC dbo.uspICRepostInTransitCosting
					@ItemsForInTransitCosting
					,@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription

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
				EXEC @intReturnId = dbo.uspICCreateGLEntriesForInTransitCosting 
					@strBatchId
					,@strAccountToCounterInventory 
					,@intEntityUserSecurityId
					,@strGLDescription
					,@intItemId

				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Invoice'
					GOTO _EXIT_WITH_ERROR
				END 
			END							
								
			ELSE 
			BEGIN 								
				-- Update the cost used in the adjustment 
				UPDATE	AdjDetail
				SET		dblCost =	CASE	WHEN Lot.intLotId IS NOT NULL  THEN 
												-- If Lot, then get the Lot's last cost. Otherwise, get the item's last cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(Lot.dblLastCost, ISNULL(ItemPricing.dblLastCost, 0)))
											WHEN dbo.fnGetCostingMethod(AdjDetail.intItemId, ItemLocation.intItemLocationId) = @AVERAGECOST THEN 
												-- It item is using Average Costing, then get the Average Cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(ItemPricing.dblAverageCost, 0)) 
											ELSE
												-- Otherwise, get the item's last cost. 
												dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, AdjDetail.intItemUOMId, ISNULL(ItemPricing.dblLastCost, 0))
									END
				FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
							ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId 
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intLocationId = Adj.intLocationId 
							AND ItemLocation.intItemId = AdjDetail.intItemId
						LEFT JOIN dbo.tblICLot Lot
							ON AdjDetail.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM StockUnit
							ON StockUnit.intItemId = AdjDetail.intItemId
							AND ISNULL(StockUnit.ysnStockUnit, 0) = 1
						LEFT JOIN dbo.tblICItemPricing ItemPricing
							ON ItemPricing.intItemId = Lot.intItemId
							AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
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
						,intForexRateTypeId
						,dblForexRate
				)
				SELECT 	RebuilInvTrans.intItemId  
						,RebuilInvTrans.intItemLocationId 
						,RebuilInvTrans.intItemUOMId  
						,RebuilInvTrans.dtmDate  
						,RebuilInvTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, RebuilInvTrans.dblUOMQty) 
						,dblCost  = CASE 
										WHEN RebuilInvTrans.dblQty < 0 THEN 
											CASE	
												WHEN dbo.fnGetCostingMethod(RebuilInvTrans.intItemId, RebuilInvTrans.intItemLocationId) = @AVERAGECOST THEN 
													dbo.fnGetItemAverageCost(
														RebuilInvTrans.intItemId
														, RebuilInvTrans.intItemLocationId
														, RebuilInvTrans.intItemUOMId
													) 
												ELSE 
													dbo.fnMultiply(
														ISNULL(lot.dblLastCost, (SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = RebuilInvTrans.intItemId and intItemLocationId = RebuilInvTrans.intItemLocationId))
														,dblUOMQty
													)
											END 

										WHEN (RebuilInvTrans.dblQty > 0 AND Receipt.intInventoryReceiptId IS NOT NULL) THEN

											-- New Hierarchy:
											-- 1. If there is a Gross/Net UOM, convert the cost from Cost UOM to Gross/Net UOM. 
											-- 2. If Gross/Net UOM is not specified, then: 
												-- 2.1. If it is not a Lot, convert the cost from Cost UOM to Receive UOM. 
												-- 2.2. If it is a Lot, convert the cost from Cost UOM to Lot UOM. 
											-- 3. If sub-currency exists, then convert it to sub-currency. 
											-- (A + B) / C 
											(
												-- (A) Item Cost
												CASE	
														WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
															-- Convert the Cost UOM to Gross/Net UOM. 

															CASE	-- When item is NOT a Lot, use the cost line item. 
																	WHEN ISNULL(ReceiptItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ReceiptItem.intItemId) = 0 THEN 

																		dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
													
																	--------------------------------------------------------------------------------------------------------
																	-- Cleaned weight scenario. 
																	--------------------------------------------------------------------------------------------------------
																	-- When item is a LOT, recalculate the cost. 
																	-- Below is an example: 
																	-- 1. Receive a stock at $1/LB. Net weight received is 100lb. So this means line total is $100. $1 x $100 = $100. 
																	-- 2. Lot can be cleaned. So after a lot is cleaned, net weight on lot level is reduced to 80 lb. 
																	-- 3. Value of the line total will still remain at $100. 
																	-- 4. So this means, cost needs to be changed from $1/LB to $1.25/LB.
																	-- 5. Receiving 80lbs @ $1.25/lb is $100. This will match the value of the line item with the lot item. 
																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
																				, ISNULL(ReceiptItem.dblNet, 0)
																			)
																			,
																			CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN 
																						dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity)
																					-- Calculate the Net Qty
																					ELSE 
																						ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
																			END 
																		)
															END 

														-- If Gross/Net UOM is missing, 
														ELSE 
																CASE	
																		-- If non-lot, convert the cost Cost UOM to Receive UOM
																		WHEN ISNULL(ReceiptItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ReceiptItem.intItemId) = 0 THEN 
																			-- Convert the Cost UOM to Item UOM. 
																			dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intUnitMeasureId, ReceiptItem.dblUnitCost) 
													
																		-- If lot, convert the cost Cost UOM to Lot UOM
																		ELSE 														
																			dbo.fnCalculateCostBetweenUOM(ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.dblUnitCost) 
																END 

												END
												-- (B) Other Charge
												+ 
												CASE 
													WHEN ISNULL(Receipt.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(ReceiptItem.dblForexRate, 0) <> 0 THEN 
														-- Convert the other charge to the currency used by the detail item. 
														dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId) / ReceiptItem.dblForexRate
													ELSE 
														-- No conversion. Detail item is already in functional currency. 
														dbo.fnGetOtherChargesFromInventoryReceipt(ReceiptItem.intInventoryReceiptItemId)
												END 									

											)
											-- (C) then convert the cost to the sub-currency value. 
											/ 
											CASE	WHEN ReceiptItem.ysnSubCurrency = 1 THEN 
														CASE WHEN ISNULL(Receipt.intSubCurrencyCents, 1) <> 0 THEN ISNULL(Receipt.intSubCurrencyCents, 1) ELSE 1 END 
													ELSE 
														1
											END											
											
										WHEN (RebuilInvTrans.dblQty > 0 AND ISNULL(Adj.intInventoryAdjustmentId, 0) <> 0) THEN 
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
						,RebuilInvTrans.intForexRateTypeId
						,RebuilInvTrans.dblForexRate

				FROM	#tmpICInventoryTransaction RebuilInvTrans INNER JOIN tblICItemLocation ItemLocation 
							ON RebuilInvTrans.intItemLocationId = ItemLocation.intItemLocationId 
						LEFT JOIN dbo.tblICInventoryReceipt Receipt
							ON Receipt.intInventoryReceiptId = RebuilInvTrans.intTransactionId
							AND Receipt.strReceiptNumber = RebuilInvTrans.strTransactionId			
						LEFT JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = RebuilInvTrans.intTransactionDetailId 
							AND ReceiptItem.intItemId = ISNULL(@intItemId, ReceiptItem.intItemId)
						LEFT JOIN dbo.tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							AND ReceiptItemLot.intLotId = RebuilInvTrans.intLotId 
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
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = RebuilInvTrans.intLotId 
				WHERE	RebuilInvTrans.strBatchId = @strBatchId
						AND RebuilInvTrans.intTransactionId = @intTransactionId
						AND ItemLocation.intLocationId IS NOT NULL 

				EXEC dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
			END 

			-- Re-create the Post g/l entries (except for Cost Adjustments, Inventory Shipment, Invoice, and Credit Memo)
			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	tblICInventoryTransactionType 
				WHERE	intTransactionTypeId = @intTransactionTypeId 
						AND strName NOT IN ('Cost Adjustment', 'Inventory Shipment', 'Invoice')
			)
			BEGIN 
				-- Clear the GL entries 
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
				)			
				EXEC @intReturnId = dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL 
					,@intItemId-- This is only used when rebuilding the stocks. 								

				IF @intReturnId <> 0 
				BEGIN 
					PRINT 'Error found in uspICCreateGLEntries'
					GOTO _EXIT_WITH_ERROR
				END 
			END 
				
			-- Fix discrepancies when posting Consume and Produce. 
			IF ISNULL(@ysnPost, 1) = 1 AND EXISTS (SELECT TOP 1 1 FROM @GLEntries WHERE strTransactionType = 'Consume' OR strTransactionType = 'Produce')
			BEGIN 
				PRINT 'Update decimal issue for Produce'

				UPDATE	@GLEntries 
				SET		dblDebit = (SELECT SUM(dblCredit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
				WHERE	strTransactionType = 'Produce'
						AND dblDebit <> 0 

				UPDATE	@GLEntries 
				SET		dblCredit = (SELECT SUM(dblDebit) FROM @GLEntries WHERE strTransactionType = 'Consume') 
				WHERE	strTransactionType = 'Produce'
						AND dblCredit <> 0 
			END 
		END 

		-- Book the G/L Entries (except for cost adjustment)
		IF EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryTransactionType 
			WHERE	intTransactionTypeId = @intTransactionTypeId 
					AND strName <> 'Cost Adjustment'
		) AND EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
		BEGIN 
			DECLARE @intReturnCode AS INT = 0;
			EXEC @intReturnCode = dbo.uspGLBookEntries @GLEntries, 1 
			
			IF ISNULL(@intReturnCode, 0) <> 0 
			BEGIN 
				-- 'Unable to repost. Item id: {Item No}. Transaction id: {Trans Id}. Batch id: {Batch Id}. Account Category: {Account Category}.'
				RAISERROR(80139, 11, 1, @strItemNo, @strTransactionId, @strBatchId, @strAccountToCounterInventory) 
				GOTO _EXIT_WITH_ERROR
			END 
		END 
		
		DELETE	FROM #tmpICInventoryTransaction
		WHERE	strBatchId = @strBatchId
				AND intTransactionId = @intTransactionId
	END 
END 

-- Rebuild the G/L Summary 
BEGIN 
	DELETE [dbo].[tblGLSummary]

	INSERT INTO tblGLSummary(
		intAccountId
		,dtmDate
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strCode
		,intConcurrencyId
	)
	SELECT
		intAccountId
		,dtmDate
		,dblDebit = SUM(ISNULL(dblDebit,0)) 
		,dblCredit = SUM(ISNULL(dblCredit,0)) 
		,dblDebitUnit = SUM(ISNULL(dblDebitUnit,0))
		,dblCreditUnit = SUM(ISNULL(dblCreditUnit,0)) 
		,strCode
		,intConcurrencyId = 1 
	FROM
		tblGLDetail
	WHERE ysnIsUnposted = 0	
	GROUP BY intAccountId, dtmDate, strCode
END

-- Restore the created dates
BEGIN 
	IF OBJECT_ID('tblICInventoryTransaction_BackupCreatedDate') IS NOT NULL 
	BEGIN 
		UPDATE	t
		SET		t.dtmCreated = t_CreatedDate.dtmCreated
		FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransaction_BackupCreatedDate t_CreatedDate
					ON t.strBatchId = t_CreatedDate.strBatchId				
	END 
END 

---- Compare the snapshot of the gl entries 
--BEGIN
--	EXEC uspICCompareGLSnapshotOnRebuildInventoryValuation
--		@dtmRebuildDate
--END

--COMMIT TRANSACTION 
GOTO _EXIT

_EXIT_WITH_ERROR: 
RETURN -1; 
--ROLLBACK TRANSACTION 

_EXIT: 