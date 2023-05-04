CREATE PROCEDURE [dbo].[uspICRebuildInventoryStorage]
	@dtmStartDate AS DATETIME 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intUserId AS INT = NULL
	,@ysnForceClearTheCostBuckets AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intReturnValue AS INT = 0; 

DECLARE @intItemId AS INT
		,@intCategoryId AS INT 
		,@dtmRebuildDate AS DATETIME = GETDATE() 
		,@intFobPointId AS INT 
		,@intEntityId AS INT 
		,@intBackupId INT 
		,@dtmDate AS DATETIME 

DECLARE @ShipmentPostScenario AS TINYINT = NULL 
		,@ShipmentPostScenario_FreightBased AS TINYINT = 1
		,@ShipmentPostScenario_InTransitBased AS TINYINT = 2

SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo
SELECT @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @strCategoryCode 

IF @intItemId IS NULL AND @strItemNo IS NOT NULL 
BEGIN 
	-- 'Item id is invalid or missing.'
	EXEC uspICRaiseError 80001;
	RETURN -80001; 
END

IF @intCategoryId IS NULL AND @strCategoryCode IS NOT NULL 
BEGIN 
	-- 'Category Code is invalid or missing.'
	EXEC uspICRaiseError 80216;
	RETURN -80216; 
END

IF EXISTS (SELECT TOP 1 1 FROM tblICBackup WHERE ysnRebuilding = 1)
BEGIN 
	-- 'A stock rebuild is already in progress.'
	EXEC uspICRaiseError 80225;
	RETURN -80225; 
END 

---- 'Unable to find an open fiscal year period to match the transaction date.'
--IF (dbo.isOpenAccountingDate(@dtmStartDate) = 0) 
--BEGIN 	
--	EXEC uspICRaiseError 80177, @dtmStartDate; 
--	RETURN -1; 
--END 

---- Unable to find an open fiscal year period for %s module to match the transaction date.
--IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Inventory') = 0)
--BEGIN 
--	EXEC uspICRaiseError 80178, 'Inventory', @dtmStartDate; 
--	RETURN -1; 
--END 

---- Unable to find an open fiscal year period for %s module to match the transaction date.
--IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Accounts Receivable') = 0)
--BEGIN 
--	EXEC uspICRaiseError 80178, 'Accounts Receivable', @dtmStartDate; 
--	RETURN -1; 
--END 

DECLARE	@AdjustmentTypeQtyChange AS INT = 1
		,@AdjustmentTypeUOMChange AS INT = 2
		,@AdjustmentTypeItemChange AS INT = 3
		,@AdjustmentTypeLotStatusChange AS INT = 4
		,@AdjustmentTypeSplitLot AS INT = 5
		,@AdjustmentTypeExpiryDateChange AS INT = 6
		,@AdjustmentTypeLotMerge AS INT = 7
		,@AdjustmentTypeLotMove AS INT = 8 
		,@AdjustmentTypeLotOwnerChange AS INT = 9
		,@AdjustmentTypeOpeningInventory AS INT = 10
		,@AdjustmentTypeChangeLotWeight AS INT = 11

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		-- Receipt Types
		,@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'
		
		,@RECEIPT_SOURCE_TYPE_NONE AS INT = 0
		,@RECEIPT_SOURCE_TYPE_Scale AS INT = 1
		,@RECEIPT_SOURCE_TYPE_InboundShipment AS INT = 2
		,@RECEIPT_SOURCE_TYPE_Transport AS INT = 3
		,@RECEIPT_SOURCE_TYPE_SettleStorage AS INT = 4

		,@INVENTORY_RECEIPT_TYPE AS INT = 4

		,@strFobPoint AS NVARCHAR(50)
		,@receiptLocationId AS INT

---- Create a snapshot of the gl values
--BEGIN
--	EXEC uspICCreateGLSnapshotOnRebuildInventoryValuation	
--		@dtmRebuildDate
--END

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#tmpRebuildListStorage') IS NULL  
BEGIN 
	CREATE TABLE #tmpRebuildListStorage (
		intItemId INT NULL 
		,intCategoryId INT NULL 
	)
END 

IF @intItemId IS NOT NULL 
BEGIN 
	--INSERT INTO #tmpRebuildListStorage (
	--	intItemId
	--	,intCategoryId
	--)
	--EXEC uspICGetCollateralItems
	--	@dtmStartDate 
	--	,@intItemId 
	--	,@isPeriodic


	INSERT INTO #tmpRebuildListStorage (
		intItemId
		,intCategoryId	
	)
	SELECT 
		@intItemId
		,NULL 
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM #tmpRebuildListStorage WHERE intItemId = @intItemId)
END 

IF @intCategoryId IS NOT NULL AND @intItemId IS NULL 
BEGIN 
	--INSERT INTO #tmpRebuildListStorage (
	--	intItemId
	--	,intCategoryId
	--)
	--EXEC uspICGetCollateralCategories
	--	@dtmStartDate 
	--	,@intCategoryId 
	--	,@isPeriodic

	INSERT INTO #tmpRebuildListStorage (
		intItemId
		,intCategoryId	
	)
	SELECT 
		NULL
		,@intCategoryId
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM #tmpRebuildListStorage WHERE intCategoryId = @intCategoryId)
END 

IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpRebuildListStorage)
BEGIN 
	INSERT INTO #tmpRebuildListStorage (
		intItemId
		,intCategoryId
	)
	SELECT intItemId = NULL, intCategoryId = NULL 
END 

-- Create the backup header
BEGIN 
	DECLARE @strRemarks VARCHAR(200)
	DECLARE @strRebuildFilter VARCHAR(50)	

	IF EXISTS (SELECT c = count(1) FROM #tmpRebuildListStorage HAVING count(1) > 1) 
	BEGIN 
		SET @strRebuildFilter = 'multiple items'
	END 
	ELSE 
	BEGIN
		SET @strRebuildFilter = (CASE WHEN @intItemId IS NOT NULL THEN '"' + @strItemNo + '" item' ELSE 'all items' END)
		SET @strRebuildFilter = (CASE WHEN @strCategoryCode IS NOT NULL THEN '"' + @strCategoryCode + '" category' ELSE @strRebuildFilter END)
	END

	SET @strRemarks = 'Rebuild inventory for ' + @strRebuildFilter + ' in a '+
		(CASE @isPeriodic WHEN 1 THEN 'periodic' ELSE 'perpetual' END) + ' order' +
		' from '+ CONVERT(VARCHAR(10), @dtmStartDate, 101) + ' onwards.' 

	INSERT INTO tblICBackup(dtmDate, intUserId, strOperation, strRemarks, ysnRebuilding, dtmStart, strItemNo, strCategoryCode)
	SELECT @dtmStartDate, @intUserId, 'Rebuild Storage', @strRemarks, 1, GETDATE(), @strItemNo, @strCategoryCode

	SET @intBackupId = SCOPE_IDENTITY()

	IF @strRebuildFilter = 'multiple items' AND @intBackupId IS NOT NULL 
	BEGIN 
		INSERT INTO tblICBackupDetail (
			[intBackupId]
			,[intItemId]
			,[intCategoryId]
			,[strItemNo]
			,[strCategoryCode]
		)
		SELECT 
			[intBackupId] = @intBackupId
			,[intItemId] = i.intItemId
			,[intCategoryId] = c.intCategoryId
			,[strItemNo] = i.strItemNo
			,[strCategoryCode] = c.strCategoryCode 
		FROM 
			#tmpRebuildListStorage list LEFT JOIN tblICItem i
				ON list.intItemId = i.intItemId
			LEFT JOIN tblICCategory c
				ON list.intCategoryId = c.intCategoryId
	END 
END 

-- Backup Inventory transactions 
BEGIN 
	EXEC dbo.uspICBackupInventory 
		@intUserId = @intUserId
		, @strOperation = 'Rebuild Storage'
		, @strRemarks = @strRemarks
		, @intBackupId = @intBackupId OUTPUT 
END 

-- Return all the "Out" stock qty back to the cost buckets. 
BEGIN 
	UPDATE	LotCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(LotOut.dblQty), 0) 
				FROM	dbo.tblICInventoryLotStorageOut LotOut INNER JOIN dbo.tblICInventoryTransactionStorage InvTrans
							ON LotOut.intInventoryTransactionStorageId = InvTrans.intInventoryTransactionStorageId
						CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate						
						) d
						INNER JOIN #tmpRebuildListStorage list
							ON InvTrans.intItemId = COALESCE(list.intItemId, InvTrans.intItemId) 
				WHERE	
						LotCostBucket.intInventoryLotStorageId = LotOut.intInventoryLotStorageId
			)
	FROM	dbo.tblICInventoryLotStorage LotCostBucket INNER JOIN tblICItem i
				ON LotCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list2
				ON LotCostBucket.intItemId  = COALESCE(list2.intItemId, LotCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list2.intCategoryId, i.intCategoryId) 

	
	UPDATE	FIFOCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(FIFOOut.dblQty), 0) 
				FROM	dbo.tblICInventoryFIFOStorageOut FIFOOut INNER JOIN dbo.tblICInventoryTransactionStorage InvTrans
							ON FIFOOut.intInventoryTransactionStorageId = InvTrans.intInventoryTransactionStorageId
						CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate						
						) d
						INNER JOIN #tmpRebuildListStorage list
							ON InvTrans.intItemId = COALESCE(list.intItemId, InvTrans.intItemId) 
				WHERE	
						FIFOCostBucket.intInventoryFIFOStorageId = FIFOOut.intInventoryFIFOStorageId
			)
	FROM	dbo.tblICInventoryFIFOStorage FIFOCostBucket INNER JOIN tblICItem i
				ON FIFOCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list2
				ON FIFOCostBucket.intItemId  = COALESCE(list2.intItemId, FIFOCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list2.intCategoryId, i.intCategoryId) 

	UPDATE	LIFOCostBucket
	SET		dblStockOut = dblStockOut - (
				SELECT	ISNULL(SUM(LIFOOut.dblQty), 0) 
				FROM	dbo.tblICInventoryLIFOStorageOut LIFOOut INNER JOIN dbo.tblICInventoryTransactionStorage InvTrans
							ON LIFOOut.intInventoryTransactionStorageId = InvTrans.intInventoryTransactionStorageId
						CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
							CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
							, @dtmStartDate					
						) d
						INNER JOIN #tmpRebuildListStorage list
							ON InvTrans.intItemId = COALESCE(list.intItemId, InvTrans.intItemId) 
				WHERE	
						LIFOCostBucket.intInventoryLIFOStorageId = LIFOOut.intInventoryLIFOStorageId
			)
	FROM	dbo.tblICInventoryLIFOStorage LIFOCostBucket INNER JOIN tblICItem i
				ON LIFOCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list2
				ON LIFOCostBucket.intItemId  = COALESCE(list2.intItemId, LIFOCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list2.intCategoryId, i.intCategoryId) 

END 

-- If stock is received within the date range, then remove also the "out" stock records. 
BEGIN 
	DELETE	LotOut
	FROM	dbo.tblICInventoryLotStorageOut LotOut INNER JOIN dbo.tblICInventoryLotStorage LotCostBucket
				ON LotOut.intInventoryLotStorageId = LotCostBucket.intInventoryLotStorageId
			INNER JOIN tblICItem i
				ON LotCostBucket.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN LotCostBucket.dtmCreated ELSE LotCostBucket.dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON LotCostBucket.intItemId  = COALESCE(list.intItemId, LotCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 

	DELETE	FIFOOut
	FROM	dbo.tblICInventoryFIFOStorageOut FIFOOut INNER JOIN dbo.tblICInventoryFIFOStorage FIFOCostBucket
				ON FIFOOut.intInventoryFIFOStorageId = FIFOCostBucket.intInventoryFIFOStorageId
			INNER JOIN tblICItem i
				ON FIFOCostBucket.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN FIFOCostBucket.dtmCreated ELSE FIFOCostBucket.dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON FIFOCostBucket.intItemId  = COALESCE(list.intItemId, FIFOCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 

	DELETE	LIFOOut
	FROM	dbo.tblICInventoryLIFOStorageOut LIFOOut INNER JOIN dbo.tblICInventoryLIFOStorage LIFOCostBucket
				ON LIFOOut.intInventoryLIFOStorageId = LIFOCostBucket.intInventoryLIFOStorageId
			INNER JOIN tblICItem i
				ON LIFOCostBucket.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN LIFOCostBucket.dtmCreated ELSE LIFOCostBucket.dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON LIFOCostBucket.intItemId  = COALESCE(list.intItemId, LIFOCostBucket.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
END 

-- Remove the cost buckets if it is posted within the date range. 
BEGIN 
	DELETE	cb
	FROM	tblICInventoryLotStorage cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	
	DELETE	cb
	FROM	tblICInventoryFIFOStorage cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 

	DELETE	cb
	FROM	tblICInventoryLIFOStorage cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate			
			) d
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
END 

-- Force the clearing of the cost bucket if the flagged
IF @ysnForceClearTheCostBuckets = 1
BEGIN 
	-- Clear the cost buckets if running qty before Nov 2018 is already zero. 
	UPDATE cb
	SET	
		cb.dblStockOut = cb.dblStockIn 
	FROM 
		tblICItem i inner join tblICInventoryFIFOStorage cb 
			on i.intItemId = cb.intItemId
		OUTER APPLY (
			SELECT 
				dblQty = SUM(t.dblQty)
			FROM	
				tblICInventoryTransactionStorage t 
			WHERE	
				t.intItemId = i.intItemId
				AND t.intItemLocationId = cb.intItemLocationId
				AND t.intItemUOMId = cb.intItemUOMId 
				AND dbo.fnDateLessThan(t.dtmDate, @dtmStartDate) = 1
			HAVING 
				SUM(t.dblQty) <> 0 	
		) t
	WHERE 
		(cb.dblStockIn - cb.dblStockOut) <> 0 
		AND (ROUND(t.dblQty, 6) = 0 OR t.dblQty IS NULL) 
		AND dbo.fnDateLessThan(cb.dtmDate, @dtmStartDate) = 1
END 

-- Create the temp table. 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpStockDiscrepancies') IS NOT NULL  
		DROP TABLE #tmpStockDiscrepancies

	CREATE TABLE #tmpStockDiscrepancies (
		id INT IDENTITY(1, 1) PRIMARY KEY 
		,strType NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,intItemId INT
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS  
		,intItemUOMId INT 
		,dblOnHand NUMERIC(38, 20)
		,dblTransaction NUMERIC(38, 20)
	)
END 

-- Create the priority rebuild table
IF OBJECT_ID('tempdb..#tmpPriorityTransactions') IS NULL  
BEGIN 
	CREATE TABLE #tmpPriorityTransactions (
		strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	)
END 

-- Create a temp table that holds all the items for reposting. 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransactionStorage') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransactionStorage

	IF OBJECT_ID('tempdb..#tmpUnOrderedICTransactionStorage') IS NOT NULL  
		DROP TABLE #tmpUnOrderedICTransactionStorage

	SELECT	t.* 
	INTO	#tmpUnOrderedICTransactionStorage
	FROM	tblICInventoryTransactionStorage t INNER JOIN tblICItem i
				ON t.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON t.intItemId  = COALESCE(list.intItemId, t.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
			LEFT JOIN tblICInventoryTransactionType ty
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

	-- Backup the created dates. 
	BEGIN 
		IF OBJECT_ID('tblICInventoryTransactionStorage_BackupCreatedDate') IS NOT NULL 
		BEGIN 
			DROP TABLE tblICInventoryTransactionStorage_BackupCreatedDate
		END 	

		SELECT	DISTINCT 
				t.strBatchId 
				,t.dtmCreated
		INTO	tblICInventoryTransactionStorage_BackupCreatedDate
		FROM	tblICInventoryTransactionStorage t INNER JOIN tblICItem i
					ON t.intItemId = i.intItemId
				CROSS APPLY (
					SELECT	TOP 1 *
					FROM	tblICInventoryTransactionStorage 
					WHERE	strBatchId = t.strBatchId
				) result
				CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
					CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
					, @dtmStartDate
				) d
				INNER JOIN #tmpRebuildListStorage list
					ON t.intItemId  = COALESCE(list.intItemId, t.intItemId) 
					AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	END 

	-- Intialize #tmpICInventoryTransactionStorage
	CREATE TABLE #tmpICInventoryTransactionStorage (
		[sortId] INT NOT NULL IDENTITY, 
		id INT, 
		id2 INT, 
		intSortByQty INT,
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[intLotId] INT NULL, 
		[dtmDate] DATETIME NOT NULL,	
		[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(38, 20) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
		[intTransactionId] INT NOT NULL, 
		[intTransactionDetailId] INT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intInventoryCostBucketStorageId] INT NULL, 
		[strBatchId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 		
		[ysnIsUnposted] BIT NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[intRelatedInventoryTransactionId] INT NULL, 
		[intRelatedTransactionId] INT NULL, 
		[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
		[intCostingMethod] INT NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL,
		[intCreatedEntityId] INT NULL,		
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		[intForexRateTypeId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1,
		[intCompanyId] INT NULL, 
		[intSourceEntityId] INT NULL,
		[intTransactionItemUOMId] INT NULL,
		[strSourceType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[strSourceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[strBOLNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[intTicketId] INT NULL,
	)

	CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransactionStorage_delete]
		ON #tmpICInventoryTransactionStorage([strBatchId] ASC, [strTransactionId] ASC);

	CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransactionStorage_lookup]
		ON #tmpICInventoryTransactionStorage([strBatchId] ASC, [intTransactionId] ASC, [intItemId] ASC)
		INCLUDE (dblQty, intItemLocationId, strTransactionId, intLotId, intTransactionDetailId);

	IF ISNULL(@isPeriodic, 0) = 1
	BEGIN 	
		--PRINT 'Rebuilding stock as periodic.'
		CREATE CLUSTERED INDEX [IX_tmpICInventoryTransactionStorage_Periodic]
			ON #tmpICInventoryTransactionStorage(sortId ASC);

		INSERT INTO #tmpICInventoryTransactionStorage
		SELECT	id = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 
							-CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT)
						ELSE
							CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT)
					END 
				,id2 = t.intInventoryTransactionStorageId
				,intSortByQty = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1 
						WHEN t.intTransactionTypeId = 47 THEN 2 -- 'Inventory Adjustment - Opening Inventory'
						WHEN t.intTransactionTypeId = 58 THEN 99 -- 'Inventory Adjustment - Closing Balance' is last in the sorting.		
						/*
							8	Consume
							9	Produce
							12	Inventory Transfer	Inventory Transfer
							13	Inventory Transfer with Shipment	Inventory Transfer
							14	Inventory Adjustment - UOM Change	Inventory Adjustment
							15	Inventory Adjustment - Item Change	Inventory Adjustment
							17	Inventory Adjustment - Split Lot	Inventory Adjustment
							19	Inventory Adjustment - Lot Merge	Inventory Adjustment
							20	Inventory Adjustment - Lot Move	Inventory Adjustment
						*/
						WHEN t.intTransactionTypeId IN (
							8
							,9
							,12
							,13
							,14
							,15
							,17
							,19
							,20
						) THEN 4 
						WHEN t.intTransactionTypeId = 10 AND t2.intInventoryTransactionStorageId IS NOT NULL THEN 4 
						WHEN ty.strName = 'Cost Adjustment' and t.strTransactionForm = 'Produce' THEN 4
						WHEN t.strTransactionForm = 'Inventory Receipt' and r.strReceiptType = 'Transfer Order' THEN 4
						WHEN 
							t.dblQty > 0 
							AND t.strTransactionForm NOT IN (
								'Invoice
								','Inventory Shipment'
								,'Inventory Count'
								,'Credit Memo'
								,'Outbound Shipment') 
							THEN 3 
						WHEN t.dblQty < 0 AND t.strTransactionForm IN ('Inventory Shipment', 'Outbound Shipment') THEN 5
						WHEN t.dblQty > 0 AND t.strTransactionForm IN ('Inventory Shipment', 'Outbound Shipment') THEN 6
						WHEN t.dblQty < 0 AND t.strTransactionForm = 'Invoice' THEN 7
						WHEN t.dblQty > 0 AND t.strTransactionForm = 'Credit Memo' THEN 8
						WHEN t.strTransactionForm IN ('Inventory Count') THEN 11
						WHEN t.dblValue <> 0 AND t.strTransactionForm NOT IN ('Produce') THEN 9
						ELSE 10
					END
				,t.[intItemId]
				,t.[intItemLocationId]
				,t.[intItemUOMId]
				,t.[intSubLocationId]
				,t.[intStorageLocationId]
				,t.[intLotId]
				,t.[dtmDate]
				,t.[dblQty]
				,t.[dblUOMQty]
				,t.[dblCost]
				,t.[dblValue]
				,t.[dblSalesPrice]
				,t.[intCurrencyId]
				,t.[dblExchangeRate]
				,t.[intTransactionId]
				,t.[intTransactionDetailId]
				,t.[strTransactionId]
				,t.[intInventoryCostBucketStorageId]
				,t.[strBatchId]
				,t.[intTransactionTypeId]
				,t.[ysnIsUnposted]
				,t.[strTransactionForm]
				,t.[intRelatedInventoryTransactionId]
				,t.[intRelatedTransactionId]
				,t.[strRelatedTransactionId]
				,t.[intCostingMethod]
				,t.[dtmCreated]
				,t.[intCreatedUserId]
				,t.[intCreatedEntityId]
				,t.[intConcurrencyId]
				,t.[intForexRateTypeId]
				,t.[dblForexRate]
				,t.[intCompanyId]
				,t.[intSourceEntityId]
				,t.[intTransactionItemUOMId]
				,t.[strSourceType] 
				,t.[strSourceNumber] 
				,t.[strBOLNumber] 
				,t.[intTicketId] 
		FROM	#tmpUnOrderedICTransactionStorage t LEFT JOIN #tmpPriorityTransactions priorityTransaction
					ON t.strTransactionId = priorityTransaction.strTransactionId
				LEFT JOIN tblICInventoryTransactionType  ty
					ON t.intTransactionTypeId = ty.intTransactionTypeId
				LEFT JOIN tblICInventoryReceipt r 
					ON r.strReceiptNumber = t.strTransactionId
					AND t.strTransactionForm = 'Inventory Receipt'
				OUTER APPLY (
					SELECT TOP 1 
						t2.intInventoryTransactionStorageId
					FROM 
						#tmpUnOrderedICTransactionStorage t2
					WHERE
						t2.strTransactionId = t.strTransactionId
						AND t2.strBatchId = t.strBatchId
						AND t2.strTransactionForm = t.strTransactionForm
						AND t.strTransactionForm = 'Inventory Adjustment'					
						AND t2.intItemId <> t.intItemId
						AND SIGN(t2.dblQty) <> SIGN(t.dblQty)
						AND t2.dblQty <> 0 
						AND t.dblQty <> 0 
				) t2 

		ORDER BY 
			DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) ASC			
			,CASE 
				WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 
					-CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT)
				ELSE
					NULL
			END DESC 
			,CASE 
				WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1 
				WHEN t.intTransactionTypeId = 47 THEN 2 -- 'Inventory Adjustment - Opening Inventory'
				WHEN t.intTransactionTypeId = 58 THEN 99 -- 'Inventory Adjustment - Closing Balance' is last in the sorting.				
				WHEN t.intTransactionTypeId = 58 THEN 99 -- 'Inventory Adjustment - Closing Balance' is last in the sorting.		
				/*
					8	Consume
					9	Produce
					12	Inventory Transfer	Inventory Transfer
					13	Inventory Transfer with Shipment	Inventory Transfer
					14	Inventory Adjustment - UOM Change	Inventory Adjustment
					15	Inventory Adjustment - Item Change	Inventory Adjustment
					17	Inventory Adjustment - Split Lot	Inventory Adjustment
					19	Inventory Adjustment - Lot Merge	Inventory Adjustment
					20	Inventory Adjustment - Lot Move	Inventory Adjustment
				*/
				WHEN t.intTransactionTypeId IN (
					8
					,9
					,12
					,13
					,14
					,15
					,17
					,19
					,20
				) THEN 4 
				WHEN t.intTransactionTypeId = 10 AND t2.intInventoryTransactionStorageId IS NOT NULL THEN 4 
				WHEN ty.strName = 'Cost Adjustment' and t.strTransactionForm = 'Produce' THEN 4
				WHEN t.strTransactionForm = 'Inventory Receipt' and r.strReceiptType = 'Transfer Order' THEN 4
				WHEN dblQty > 0 AND t.strTransactionForm NOT IN ('Invoice','Inventory Shipment','Inventory Count','Credit Memo', 'Outbound Shipment') THEN 3 
				--WHEN dblQty < 0 AND t.strTransactionForm IN ('Inventory Shipment', 'Outbound Shipment') THEN 5
				--WHEN dblQty > 0 AND t.strTransactionForm IN ('Inventory Shipment', 'Outbound Shipment') THEN 6
				--WHEN dblQty < 0 AND t.strTransactionForm = 'Invoice' THEN 7
				--WHEN dblQty > 0 AND t.strTransactionForm = 'Credit Memo' THEN 8
				WHEN t.strTransactionForm IN ('Inventory Count') THEN 11
				WHEN dblValue <> 0 AND t.strTransactionForm NOT IN ('Produce') THEN 9
				ELSE 10
			END    
			ASC 
			,CASE 
				WHEN priorityTransaction.strTransactionId IS NULL THEN 
					CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT)
				ELSE
					1
			END ASC
	END
	ELSE 
	BEGIN 
		--PRINT 'Rebuilding stock as perpetual.'
		CREATE CLUSTERED INDEX [IX_tmpICInventoryTransactionStorage_Perpetual]
			ON #tmpICInventoryTransactionStorage(sortId ASC);

		INSERT INTO #tmpICInventoryTransactionStorage
		SELECT	id = CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT)
				,id2 = intInventoryTransactionStorageId
				,intSortByQty = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1
						WHEN dblQty > 0 THEN 2
						WHEN dblValue <> 0 THEN 3
						ELSE 4
					END
				,t.[intItemId]
				,t.[intItemLocationId]
				,t.[intItemUOMId]
				,t.[intSubLocationId]
				,t.[intStorageLocationId]
				,t.[intLotId]
				,t.[dtmDate]
				,t.[dblQty]
				,t.[dblUOMQty]
				,t.[dblCost]
				,t.[dblValue]
				,t.[dblSalesPrice]
				,t.[intCurrencyId]
				,t.[dblExchangeRate]
				,t.[intTransactionId]
				,t.[intTransactionDetailId]
				,t.[strTransactionId]
				,t.[intInventoryCostBucketStorageId]
				,t.[strBatchId]
				,t.[intTransactionTypeId]
				,t.[ysnIsUnposted]
				,t.[strTransactionForm]
				,t.[intRelatedInventoryTransactionId]
				,t.[intRelatedTransactionId]
				,t.[strRelatedTransactionId]
				,t.[intCostingMethod]
				,t.[dtmCreated]
				,t.[intCreatedUserId]
				,t.[intCreatedEntityId]
				,t.[intConcurrencyId]
				,t.[intForexRateTypeId]
				,t.[dblForexRate]
				,t.[intCompanyId]
				,t.[intSourceEntityId]
				,t.[intTransactionItemUOMId]
				,t.[strSourceType] 
				,t.[strSourceNumber] 
				,t.[strBOLNumber] 
				,t.[intTicketId] 
		FROM	#tmpUnOrderedICTransactionStorage t LEFT JOIN #tmpPriorityTransactions priorityTransaction
					ON t.strTransactionId = priorityTransaction.strTransactionId
		ORDER BY 
			intInventoryTransactionStorageId ASC,  CAST(REPLACE(strBatchId, 'BATCH-', '') AS FLOAT) ASC 
	END
END

-- Delete the inventory transaction record if it falls within the date range. 
BEGIN 
	DELETE	t
	FROM	tblICInventoryTransactionStorage t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) d_gte
			INNER JOIN #tmpRebuildListStorage list
				ON t.intItemId  = COALESCE(list.intItemId, t.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 

	DELETE	t
	FROM	tblICInventoryLotTransactionStorage t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) d_gte
			INNER JOIN #tmpRebuildListStorage list
				ON t.intItemId  = COALESCE(list.intItemId, t.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 

	DELETE	m
	FROM	tblICInventoryStockMovement m INNER JOIN tblICItem i
				ON m.intItemId = i.intItemId 
			CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
				CASE WHEN @isPeriodic = 0 THEN m.dtmCreated ELSE m.dtmDate END
				, @dtmStartDate
			) d_gte
			INNER JOIN #tmpRebuildListStorage list
				ON m.intItemId  = COALESCE(list.intItemId, m.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	WHERE	
			m.intInventoryTransactionStorageId IS NOT NULL
END 

-- Re-update the "Out" quantities one more time to be sure. 
BEGIN 
	UPDATE	LotCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryLotStorage LotCostBucket	INNER JOIN tblICItem i
				ON LotCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
			OUTER APPLY (
				SELECT	dblQty = SUM(LotOut.dblQty) 
				FROM	dbo.tblICInventoryLotStorageOut LotOut INNER JOIN tblICInventoryTransactionStorage t
							ON LotOut.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
							
				WHERE	LotOut.intInventoryLotStorageId = LotCostBucket.intInventoryLotStorageId 
			) cbOut 
	WHERE	LotCostBucket.dblStockIn <> LotCostBucket.dblStockOut

	UPDATE	FIFOCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryFIFOStorage FIFOCostBucket INNER JOIN tblICItem i
				ON FIFOCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
			OUTER APPLY (
				SELECT	dblQty = SUM(FIFOOut.dblQty)
				FROM	dbo.tblICInventoryFIFOStorageOut FIFOOut INNER JOIN tblICInventoryTransactionStorage t
							ON FIFOOut.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
				WHERE	FIFOOut.intInventoryFIFOStorageId = FIFOCostBucket.intInventoryFIFOStorageId 
			) cbOut
	WHERE	FIFOCostBucket.dblStockIn <> FIFOCostBucket.dblStockOut

	UPDATE	LIFOCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryLIFOStorage LIFOCostBucket INNER JOIN tblICItem i
				ON LIFOCostBucket.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
			OUTER APPLY (
				SELECT	dblQty = SUM(LIFOOut.dblQty) 
				FROM	dbo.tblICInventoryLIFOStorageOut LIFOOut INNER JOIN tblICInventoryTransactionStorage t
							ON LIFOOut.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
				WHERE	LIFOOut.intInventoryLIFOStorageId = LIFOCostBucket.intInventoryLIFOStorageId						
			) cbOut
	WHERE	LIFOCostBucket.dblStockIn <> LIFOCostBucket.dblStockOut
END 

--------------------------------------------------------------------
-- Retroactively compute the lot Qty and Weight. 
--------------------------------------------------------------------
BEGIN 
	UPDATE	l
	SET		l.dblQty = 0
			,l.dblWeight = 0 
			,l.dblQtyInTransit = 0 
			,l.dblWeightInTransit = 0 
	FROM	tblICLot l INNER JOIN tblICItem i
				ON l.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	WHERE
			l.intOwnershipType = 2 -- Storage

	UPDATE	UpdateLot
	SET		UpdateLot.dblQty = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									t.intItemUOMId
									, Lot.intItemUOMId
									, t.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransactionStorage t INNER JOIN tblICItemLocation il
								ON t.intItemLocationId = il.intItemLocationId 
						INNER JOIN dbo.tblICLot Lot
							ON t.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
						AND il.intLocationId IS NOT NULL 
			)
			,dblQtyInTransit = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									t.intItemUOMId
									, Lot.intItemUOMId
									, t.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransactionStorage t INNER JOIN tblICItemLocation il
								ON t.intItemLocationId = il.intItemLocationId 
						INNER JOIN dbo.tblICLot Lot
							ON t.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
						AND il.intLocationId IS NULL 
			)
	FROM	tblICLot UpdateLot INNER JOIN tblICItem i
				ON UpdateLot.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	WHERE
			UpdateLot.intOwnershipType = 2 -- Storage

	UPDATE	l
	SET		l.dblWeight = dbo.fnMultiply(ISNULL(l.dblQty, 0), ISNULL(l.dblWeightPerQty, 0)) 	
			,l.dblWeightInTransit = dbo.fnMultiply(ISNULL(l.dblQtyInTransit, 0), ISNULL(l.dblWeightPerQty, 0)) 	
	FROM	tblICLot l INNER JOIN tblICItem i
				ON l.intItemId = i.intItemId
			INNER JOIN #tmpRebuildListStorage list
				ON i.intItemId  = COALESCE(list.intItemId, i.intItemId) 
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId) 
	WHERE
			l.intOwnershipType = 2 -- Storage
END 

--------------------------------------------------------------------
-- Retroactively compute the stocks on Stock-UOM and Stock tables. 
--------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICFixStockQuantities 
		@intItemId 
		,@intCategoryId
END 

-- Execute the repost stored procedure
BEGIN 
	DECLARE @strBatchId AS NVARCHAR(40)
			,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
			,@intEntityUserSecurityId AS INT
			,@strGLDescription AS NVARCHAR(255) = NULL 
			,@StorageToPost AS ItemCostingTableType 
			,@ItemsForInTransitCosting AS ItemInTransitCostingTableType
			,@strTransactionForm AS NVARCHAR(50)
			,@intTransactionId AS INT 
			,@strTransactionId AS NVARCHAR(50)
			,@GLEntries AS RecapTableType 
			,@DummyGLEntries AS RecapTableType 
			,@ysnPost AS BIT 
			,@dblQty AS NUMERIC(38, 20)
			,@intTransactionTypeId AS INT
			,@strTransactionType AS NVARCHAR(50) 
			,@dblUnitRetail NUMERIC(38, 20)
			,@dblCategoryCostValue NUMERIC(38, 20)
			,@dblCategoryRetailValue NUMERIC(38, 20)
			,@strReceiptType AS NVARCHAR(50)
			,@intReceiptSourceType AS INT

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

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpICInventoryTransactionStorage) 
	BEGIN 
		IF ISNULL(@isPeriodic, 0) = 1
		BEGIN 
			SELECT	TOP 1 
					@strBatchId = strBatchId
					,@intEntityUserSecurityId = intCreatedUserId
					,@strTransactionForm = strTransactionForm
					,@strTransactionId = strTransactionId
					,@intTransactionId = intTransactionId
					,@dblQty = dblQty 
					,@intTransactionTypeId = intTransactionTypeId
					,@dtmDate = dtmDate
			FROM	#tmpICInventoryTransactionStorage
			--ORDER BY dtmDate ASC, id ASC, intSortByQty ASC
			ORDER BY sortId ASC
		END 
		ELSE 
		BEGIN 
			SELECT	TOP 1 
					@strBatchId = strBatchId
					,@intEntityUserSecurityId = intCreatedUserId
					,@strTransactionForm = strTransactionForm
					,@strTransactionId = strTransactionId
					,@intTransactionId = intTransactionId
					,@dblQty = dblQty 
					,@intTransactionTypeId = intTransactionTypeId
					,@dtmDate = dtmDate
			FROM	#tmpICInventoryTransactionStorage
			--ORDER BY id2 ASC, id ASC
			ORDER BY sortId ASC
		END 

		-- Run the post routine. 
		BEGIN 
			--PRINT 'Posting ' + @strBatchId + ' ' + @strTransactionId 

			-- Clear the data on @ItemsToPost
			DELETE FROM @StorageToPost
			
			INSERT INTO @StorageToPost (  
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate 
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,intForexRateTypeId
				,dblForexRate
				,intSourceEntityId
				,strSourceType
				,strSourceNumber
				,strBOLNumber
				,intTicketId
			) 
			SELECT 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate 
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,intForexRateTypeId
				,dblForexRate
				,intSourceEntityId
				,strSourceType
				,strSourceNumber
				,strBOLNumber
				,intTicketId
			FROM 
				#tmpICInventoryTransactionStorage
			WHERE
				strBatchId = @strBatchId
				AND strTransactionId = @strTransactionId 

			EXEC uspICPostStorage
				@StorageToPost
				,@strBatchId
				,@intUserId
		END 
		
		DELETE	FROM #tmpICInventoryTransactionStorage
		WHERE	strBatchId = @strBatchId
				AND strTransactionId = @strTransactionId 
	END 
END 

-- Restore the created dates
BEGIN 
	IF OBJECT_ID('tblICInventoryTransactionStorage_BackupCreatedDate') IS NOT NULL 
	BEGIN 
		UPDATE	t
		SET		t.dtmCreated = t_CreatedDate.dtmCreated
		FROM	tblICInventoryTransactionStorage t INNER JOIN tblICInventoryTransactionStorage_BackupCreatedDate t_CreatedDate
					ON t.strBatchId = t_CreatedDate.strBatchId
	END 
END 

GOTO _CLEAN_UP

_EXIT_WITH_ERROR: 
BEGIN 
	SET @intReturnValue = ISNULL(@intReturnValue, -1); 
	GOTO _CLEAN_UP
END

_CLEAN_UP: 
-- Flag the rebuild as done. 
BEGIN 
	UPDATE	tblICBackup 
	SET		ysnRebuilding = 0
			,dtmEnd = GETDATE()
	WHERE	intBackupId = @intBackupId
END

BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransactionStorage') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransactionStorage

	IF OBJECT_ID('tempdb..#tmpUnOrderedICTransactionStorage') IS NOT NULL  
		DROP TABLE #tmpUnOrderedICTransactionStorage

	IF OBJECT_ID('tempdb..#tmpPriorityTransactions') IS NOT NULL  
		DROP TABLE #tmpPriorityTransactions
END 

RETURN @intReturnValue;