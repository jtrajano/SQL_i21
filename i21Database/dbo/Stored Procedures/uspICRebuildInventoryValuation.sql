CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuation]
	@dtmStartDate AS DATETIME 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intUserId AS INT = NULL
	,@ysnRebuildShipmentAndInvoiceAsInTransit AS BIT = 0
	,@ysnForceClearTheCostBuckets AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

-- Create the backup header
BEGIN 
	DECLARE @strRemarks VARCHAR(200)
	DECLARE @strRebuildFilter VARCHAR(50)	

	SET @strRebuildFilter = (CASE WHEN @intItemId IS NOT NULL THEN '"' + @strItemNo + '" item' ELSE 'all items' END)
	SET @strRebuildFilter = (CASE WHEN @strCategoryCode IS NOT NULL THEN '"' + @strCategoryCode + '" category' ELSE @strRebuildFilter END)

	SET @strRemarks = 'Rebuild inventory for ' + @strRebuildFilter + ' in a '+
		(CASE @isPeriodic WHEN 1 THEN 'periodic' ELSE 'perpetual' END) + ' order' +
		' from '+ CONVERT(VARCHAR(10), @dtmStartDate, 101) + ' onwards.' 

	INSERT INTO tblICBackup(dtmDate, intUserId, strOperation, strRemarks, ysnRebuilding, dtmStart, strItemNo, strCategoryCode)
	SELECT @dtmStartDate, @intUserId, 'Rebuild Inventory', @strRemarks, 1, GETDATE(), @strItemNo, @strCategoryCode

	SET @intBackupId = SCOPE_IDENTITY()
END 

-- 'Unable to find an open fiscal year period to match the transaction date.'
IF (dbo.isOpenAccountingDate(@dtmStartDate) = 0) 
BEGIN 	
	EXEC uspICRaiseError 80177, @dtmStartDate; 
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Inventory') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Inventory', @dtmStartDate; 
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Accounts Receivable') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Accounts Receivable', @dtmStartDate; 
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

-- Create a snapshot of the gl values
BEGIN
	EXEC uspICCreateGLSnapshotOnRebuildInventoryValuation	
		@dtmRebuildDate
END

--BEGIN TRANSACTION 

-- Backup Inventory transactions 
BEGIN 
	EXEC dbo.uspICBackupInventory 
		@intUserId = @intUserId
		, @strOperation = 'Rebuild Inventory'
		, @strRemarks = @strRemarks
		, @intBackupId = @intBackupId OUTPUT 
END 

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
	FROM	dbo.tblICInventoryLot LotCostBucket INNER JOIN tblICItem i
				ON LotCostBucket.intItemId = i.intItemId
	WHERE	LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId)
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
	FROM	dbo.tblICInventoryFIFO FIFOCostBucket INNER JOIN tblICItem i
				ON FIFOCostBucket.intItemId = i.intItemId
	WHERE	FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId)
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
	FROM	dbo.tblICInventoryLIFO LIFOCostBucket INNER JOIN tblICItem i
				ON LIFOCostBucket.intItemId = i.intItemId
	WHERE	LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId)
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
	FROM	dbo.tblICInventoryActualCost ActualCostBucket INNER JOIN tblICItem i
				ON ActualCostBucket.intItemId = i.intItemId
	WHERE	ActualCostBucket.intItemId = ISNULL(@intItemId, ActualCostBucket.intItemId)
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- If stock is received within the date range, then remove also the "out" stock records. 
BEGIN 
	DELETE	LotOut
	FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryLot LotCostBucket
				ON LotOut.intInventoryLotId = LotCostBucket.intInventoryLotId
			INNER JOIN tblICItem i
				ON LotCostBucket.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(				
				CASE WHEN @isPeriodic = 0 THEN LotCostBucket.dtmCreated ELSE LotCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	FIFOOut
	FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN dbo.tblICInventoryFIFO FIFOCostBucket
				ON FIFOOut.intInventoryFIFOId = FIFOCostBucket.intInventoryFIFOId
			INNER JOIN tblICItem i
				ON FIFOCostBucket.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN FIFOCostBucket.dtmCreated ELSE FIFOCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	LIFOOut
	FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN dbo.tblICInventoryLIFO LIFOCostBucket
				ON LIFOOut.intInventoryLIFOId = LIFOCostBucket.intInventoryLIFOId
			INNER JOIN tblICItem i
				ON LIFOCostBucket.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN LIFOCostBucket.dtmCreated ELSE LIFOCostBucket.dtmDate END
				, @dtmStartDate
				) = 1
			AND LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	ActualCostOut
	FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN dbo.tblICInventoryActualCost ActualCostCostBucket
				ON ActualCostOut.intInventoryActualCostId = ActualCostCostBucket.intInventoryActualCostId
			INNER JOIN tblICItem i
				ON ActualCostCostBucket.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN ActualCostCostBucket.dtmCreated ELSE ActualCostCostBucket.dtmDate END
				, @dtmStartDate
			) = 1
			AND ActualCostCostBucket.intItemId = ISNULL(@intItemId, ActualCostCostBucket.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Restore the original costs
BEGIN 
	-- Lotted
	UPDATE	CostBucket
	SET		dblCost = CostAdjustment.dblCost
	FROM	dbo.tblICInventoryLotCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction t
				ON CostAdjustment.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN dbo.tblICInventoryLot CostBucket
				ON CostBucket.intInventoryLotId = CostAdjustment.intInventoryLotId
			INNER JOIN tblICItem i
				ON CostBucket.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
				, @dtmStartDate
			) = 1
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND CostAdjustment.intInventoryCostAdjustmentTypeId = 1 -- Original cost. 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	-- FIFO 
	UPDATE	cb
	SET		dblCost = costAdjLog.dblCost
	FROM	dbo.tblICInventoryFIFOCostAdjustmentLog costAdjLog INNER JOIN tblICInventoryTransaction t
				ON costAdjLog.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN dbo.tblICInventoryFIFO cb
				ON cb.intInventoryFIFOId = costAdjLog.intInventoryFIFOId
			INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
				, @dtmStartDate
			) = 1
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND costAdjLog.intInventoryCostAdjustmentTypeId = 1 -- Original cost. 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	-- LIFO 
	UPDATE	cb
	SET		dblCost = costAdjLog.dblCost
	FROM	dbo.tblICInventoryLIFOCostAdjustmentLog costAdjLog INNER JOIN tblICInventoryTransaction t
				ON costAdjLog.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN dbo.tblICInventoryLIFO cb
				ON cb.intInventoryLIFOId = costAdjLog.intInventoryLIFOId
			INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
				, @dtmStartDate
			) = 1
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND costAdjLog.intInventoryCostAdjustmentTypeId = 1 -- Original cost. 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	-- Actual  
	UPDATE	cb
	SET		dblCost = costAdjLog.dblCost
	FROM	dbo.tblICInventoryActualCostAdjustmentLog costAdjLog INNER JOIN tblICInventoryTransaction t
				ON costAdjLog.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN dbo.tblICInventoryActualCost cb
				ON cb.intInventoryActualCostId = costAdjLog.intInventoryActualCostId
			INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
				, @dtmStartDate
			) = 1
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND costAdjLog.intInventoryCostAdjustmentTypeId = 1 -- Original cost. 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Clear the cost adjustments
BEGIN 
	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryLotCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			INNER JOIN tblICItem i
				ON InvTrans.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryFIFOCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			INNER JOIN tblICItem i
				ON InvTrans.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryLIFOCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			INNER JOIN tblICItem i
				ON InvTrans.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	CostAdjustment
	FROM	dbo.tblICInventoryActualCostAdjustmentLog CostAdjustment INNER JOIN tblICInventoryTransaction InvTrans
				ON CostAdjustment.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			INNER JOIN tblICItem i
				ON InvTrans.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Remove the cost adjustment logs if it is posted within the date range. 
BEGIN 
	DELETE	cbLog
	FROM	tblICInventoryLot cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryLotId = cb.intInventoryLotId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN cb.dtmCreated ELSE cb.dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	cbLog
	FROM	tblICInventoryFIFO cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryFIFOId = cb.intInventoryFIFOId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN cb.dtmCreated ELSE cb.dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	cbLog
	FROM	tblICInventoryLIFO cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryLIFOId = cb.intInventoryLIFOId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN cb.dtmCreated ELSE cb.dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	cbLog
	FROM	tblICInventoryActualCost cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
			INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryActualCostId = cb.intInventoryActualCostId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN cb.dtmCreated ELSE cb.dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Remove the cost buckets if it is posted within the date range. 
BEGIN 
	DELETE	cb
	FROM	tblICInventoryLot cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
	
	DELETE	cb
	FROM	tblICInventoryFIFO cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	cb
	FROM	tblICInventoryLIFO cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	cb
	FROM	tblICInventoryActualCost cb INNER JOIN tblICItem i
				ON cb.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Clear the G/L entries 
BEGIN 
	DELETE	GLDetail
	FROM	dbo.tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InvTrans
				ON  GLDetail.strTransactionId = InvTrans.strTransactionId
				AND GLDetail.intJournalLineNo = InvTrans.intInventoryTransactionId
			INNER JOIN tblICItem i
				ON InvTrans.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN InvTrans.dtmCreated ELSE InvTrans.dtmDate END
				, @dtmStartDate
			) = 1
			AND InvTrans.intItemId = ISNULL(@intItemId, InvTrans.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

-- Force the clearing of the cost bucket if the flagged
IF @ysnForceClearTheCostBuckets = 1
BEGIN 
	-- Clear the cost buckets if running qty before Nov 2018 is already zero. 
	UPDATE cb
	SET	
		cb.dblStockOut = cb.dblStockIn 
	FROM 
		tblICItem i inner join tblICInventoryFIFO cb 
			on i.intItemId = cb.intItemId
		OUTER APPLY (
			SELECT 
				dblQty = SUM(t.dblQty)
			FROM	
				tblICInventoryTransaction t 
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

-- Create the temp table to instruct the cost adjustment sp to escalate the cost.
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAllowCostAdjustmentToEscalate')) 
	BEGIN 
		CREATE TABLE #tmpAllowCostAdjustmentToEscalate (
			[ysnAllowEscalate] BIT NULL
		)

		INSERT INTO #tmpAllowCostAdjustmentToEscalate (ysnAllowEscalate) VALUES (1)
	END 
END 

-- Create a temp table that holds all the items for reposting. 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransaction') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransaction

	IF OBJECT_ID('tempdb..#tmpUnOrderedICTransaction') IS NOT NULL  
		DROP TABLE #tmpUnOrderedICTransaction

	SELECT	t.* 
	INTO	#tmpUnOrderedICTransaction
	FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
				ON t.intItemId = i.intItemId
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
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
		FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
					ON t.intItemId = i.intItemId
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
				AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
	END 

	-- Intialize #tmpICInventoryTransaction
	CREATE TABLE #tmpICInventoryTransaction (
		[sortId] INT NOT NULL IDENTITY, 
		id INT, 
		id2 INT, 
		intSortByQty INT,
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intInTransitSourceLocationId] INT NULL, 
		[intItemUOMId] INT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(38, 20) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL, -- OBSOLETE, use dblForexRate instead. 
		[intTransactionId] INT NOT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionDetailId] INT NULL, 
		[strBatchId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 
		[intLotId] INT NULL, 
		[ysnIsUnposted] BIT NULL,
		[intRelatedInventoryTransactionId] INT NULL,
		[intRelatedTransactionId] INT NULL,
		[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[intCostingMethod] INT NULL, 		
		[dtmCreated] DATETIME NULL, 
		[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 			
		[intForexRateTypeId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NOT NULL DEFAULT 1, 
		[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intCategoryId] INT NULL,
		[dblUnitRetail] NUMERIC(38, 20) NULL,
		[dblCategoryCostValue] NUMERIC(38, 20) NULL, 
		[dblCategoryRetailValue] NUMERIC(38, 20) NULL, 
	)

	CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransaction_delete]
		ON #tmpICInventoryTransaction([strBatchId] ASC, [strTransactionId] ASC);

	CREATE NONCLUSTERED INDEX [IX_tmpICInventoryTransaction_lookup]
		ON #tmpICInventoryTransaction([strBatchId] ASC, [intTransactionId] ASC, [intItemId] ASC)
		INCLUDE (dblQty, intItemLocationId, strTransactionId, intLotId, intTransactionDetailId);

	CREATE TABLE #tmpAutoVarianceBatchesForAVGCosting (
		intItemId INT
		,intItemLocationId INT
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	)

	CREATE NONCLUSTERED INDEX [IX_tmpAutoVarianceBatchesForAVGCosting]
		ON #tmpAutoVarianceBatchesForAVGCosting(intItemId ASC, intItemLocationId ASC, strTransactionId ASC, strBatchId ASC);

	IF ISNULL(@isPeriodic, 0) = 1
	BEGIN 	
		--PRINT 'Rebuilding stock as periodic.'
		CREATE CLUSTERED INDEX [IX_tmpICInventoryTransaction_Periodic]
			--ON #tmpICInventoryTransaction(dtmDate ASC, id ASC, intSortByQty ASC);
			ON #tmpICInventoryTransaction(sortId ASC);

		INSERT INTO #tmpICInventoryTransaction
		SELECT	id = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 
							-CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
						ELSE
							CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
					END 
				,id2 = intInventoryTransactionId
				,intSortByQty = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1 
						WHEN dblQty > 0 AND strTransactionForm NOT IN ('Invoice', 'Inventory Shipment') THEN 2 
						WHEN dblQty < 0 AND strTransactionForm = 'Inventory Shipment' THEN 3
						WHEN dblQty > 0 AND strTransactionForm = 'Inventory Shipment' THEN 4
						WHEN dblQty < 0 AND strTransactionForm = 'Invoice' THEN 5
						WHEN dblValue <> 0 THEN 6
						ELSE 7
					END    
				,intItemId
				,intItemLocationId
				,intInTransitSourceLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dbo.fnRemoveTimeOnDate(dtmDate) 
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,t.strTransactionId
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
				,strActualCostId
				,intCategoryId
				,dblUnitRetail
				,dblCategoryCostValue
				,dblCategoryRetailValue
		FROM	#tmpUnOrderedICTransaction t LEFT JOIN #tmpPriorityTransactions priorityTransaction
					ON t.strTransactionId = priorityTransaction.strTransactionId
		ORDER BY 
			DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) ASC			
			,CASE 
				WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 
					-CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
				ELSE
					CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
			END ASC 
			,CASE 
				WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1 
				WHEN dblQty > 0 AND strTransactionForm NOT IN ('Invoice', 'Inventory Shipment') THEN 2 
				WHEN dblQty < 0 AND strTransactionForm = 'Inventory Shipment' THEN 3
				WHEN dblQty > 0 AND strTransactionForm = 'Inventory Shipment' THEN 4
				WHEN dblQty < 0 AND strTransactionForm = 'Invoice' THEN 5
				WHEN dblValue <> 0 THEN 6
				ELSE 7
			END   
			ASC 	
			
		INSERT INTO #tmpAutoVarianceBatchesForAVGCosting (
			intItemId
			,intItemLocationId
			,strTransactionId
			,strBatchId
		)
		SELECT 
			t.intItemId
			,t.intItemLocationId
			,t2.strTransactionId
			,t2.strBatchId
		FROM 
			tblICItem i 
			CROSS APPLY (
				SELECT DISTINCT 
					t.intItemId
					,t.intItemLocationId
					,[dtmEndOfMonth] = DATEADD(d, -1, DATEADD(m, 1,dbo.[fnDateFromParts](YEAR(t.dtmDate), MONTH(t.dtmDate), 1))) 
				FROM 
					#tmpICInventoryTransaction t 
				WHERE 
					t.dblQty > 0 
					AND t.intCostingMethod = 1
					AND t.intItemId = i.intItemId
			) t
			CROSS APPLY (
				SELECT TOP 1 
					t2.strBatchId
					,t2.strTransactionId					
				FROM 
					#tmpICInventoryTransaction t2
				WHERE 
					t2.intItemId = t.intItemId
					AND t2.intItemLocationId = t.intItemLocationId					
					AND t2.intCostingMethod = 1	
					AND 1 = 
						CASE 
							WHEN t2.dblQty > 0 THEN 1
							WHEN t2.dblValue <> 0 AND t2.intTransactionTypeId = 26 THEN 1
							ELSE 0 
						END 
					AND dbo.fnDateEquals(t2.dtmDate, t.[dtmEndOfMonth]) = 1
				ORDER BY
					t2.dtmDate DESC, t2.id DESC, t2.intSortByQty DESC
			) t2
	END
	ELSE 
	BEGIN 
		--PRINT 'Rebuilding stock as perpetual.'
		CREATE CLUSTERED INDEX [IX_tmpICInventoryTransaction_Perpetual]
			--ON #tmpICInventoryTransaction(id2 ASC, id ASC);
			ON #tmpICInventoryTransaction(sortId ASC);

		INSERT INTO #tmpICInventoryTransaction
		SELECT	id = CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT)
				,id2 = intInventoryTransactionId
				,intSortByQty = 
					CASE 
						WHEN priorityTransaction.strTransactionId IS NOT NULL THEN 1
						WHEN dblQty > 0 THEN 2
						WHEN dblValue <> 0 THEN 3
						ELSE 4
					END
				,intItemId
				,intItemLocationId
				,intInTransitSourceLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dbo.fnRemoveTimeOnDate(dtmDate) 
				,dblQty
				,dblUOMQty
				,dblCost
				,dblValue
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,t.strTransactionId
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
				,strActualCostId
				,intCategoryId
				,dblUnitRetail
				,dblCategoryCostValue
				,dblCategoryRetailValue
		FROM	#tmpUnOrderedICTransaction t LEFT JOIN #tmpPriorityTransactions priorityTransaction
					ON t.strTransactionId = priorityTransaction.strTransactionId
		ORDER BY 
			intInventoryTransactionId ASC,  CAST(REPLACE(strBatchId, 'BATCH-', '') AS INT) ASC 

		INSERT INTO #tmpAutoVarianceBatchesForAVGCosting (
			intItemId
			,intItemLocationId
			,strTransactionId
			,strBatchId
		)
		SELECT 
			t.intItemId
			,t.intItemLocationId
			,t2.strTransactionId
			,t2.strBatchId
		FROM 
			tblICItem i 
			CROSS APPLY (
				SELECT DISTINCT 
					t.intItemId
					,t.intItemLocationId
				FROM 
					#tmpICInventoryTransaction t 
				WHERE 
					t.dblQty > 0 
					AND t.intCostingMethod = 1
					AND t.intItemId = i.intItemId
			) t
			CROSS APPLY (
				SELECT TOP 1 
					t2.strBatchId
					,t2.strTransactionId					
				FROM 
					#tmpICInventoryTransaction t2
				WHERE 
					t2.intItemId = t.intItemId
					AND t2.intItemLocationId = t.intItemLocationId					
					AND t2.intCostingMethod = 1	
					AND 1 = 
						CASE 
							WHEN t2.dblQty > 0 THEN 1
							WHEN t2.dblValue <> 0 AND t2.intTransactionTypeId = 26 THEN 1
							ELSE 0 
						END 
				ORDER BY
					t2.id2 DESC, t2.id DESC
			) t2
	END
END

-- Delete the inventory transaction record if it falls within the date range. 
BEGIN 
	DELETE	t
	FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	t
	FROM	tblICInventoryLotTransaction t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
				, @dtmStartDate
			) = 1 
			AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	DELETE	m
	FROM	tblICInventoryStockMovement m INNER JOIN tblICItem i
				ON m.intItemId = i.intItemId 
	WHERE	dbo.fnDateGreaterThanEquals(
				CASE WHEN @isPeriodic = 0 THEN m.dtmCreated ELSE m.dtmDate END
				, @dtmStartDate
			) = 1 
			AND m.intItemId = ISNULL(@intItemId, m.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
			AND m.intInventoryTransactionId IS NOT NULL
END 

-- Re-update the "Out" quantities one more time to be sure. 
BEGIN 
	UPDATE	LotCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryLot LotCostBucket		
			OUTER APPLY (
				SELECT	dblQty = SUM(LotOut.dblQty) 
				FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN tblICInventoryTransaction t
							ON LotOut.intInventoryTransactionId = t.intInventoryTransactionId
							
				WHERE	LotOut.intInventoryLotId = LotCostBucket.intInventoryLotId 
			) cbOut 
	WHERE	LotCostBucket.intItemId = ISNULL(@intItemId, LotCostBucket.intItemId)
			AND LotCostBucket.dblStockIn <> LotCostBucket.dblStockOut

	UPDATE	FIFOCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryFIFO FIFOCostBucket
			OUTER APPLY (
				SELECT	dblQty = SUM(FIFOOut.dblQty)
				FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN tblICInventoryTransaction t
							ON FIFOOut.intInventoryTransactionId = t.intInventoryTransactionId
				WHERE	FIFOOut.intInventoryFIFOId = FIFOCostBucket.intInventoryFIFOId 
			) cbOut
	WHERE	FIFOCostBucket.intItemId = ISNULL(@intItemId, FIFOCostBucket.intItemId)
			AND FIFOCostBucket.dblStockIn <> FIFOCostBucket.dblStockOut

	UPDATE	LIFOCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryLIFO LIFOCostBucket
			OUTER APPLY (
				SELECT	dblQty = SUM(LIFOOut.dblQty) 
				FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN tblICInventoryTransaction t
							ON LIFOOut.intInventoryTransactionId = t.intInventoryTransactionId
				WHERE	LIFOOut.intInventoryLIFOId = LIFOCostBucket.intInventoryLIFOId						
			) cbOut
	WHERE	LIFOCostBucket.intItemId = ISNULL(@intItemId, LIFOCostBucket.intItemId)
			AND LIFOCostBucket.dblStockIn <> LIFOCostBucket.dblStockOut

	UPDATE	ActualCostBucket
	SET		dblStockOut = ISNULL(cbOut.dblQty, 0) 
	FROM	dbo.tblICInventoryActualCost ActualCostBucket
			OUTER APPLY (
				SELECT	dblQty = SUM(ActualCostOut.dblQty)
				FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN tblICInventoryTransaction t
							ON ActualCostOut.intInventoryTransactionId = t.intInventoryTransactionId
				WHERE	ActualCostOut.intInventoryActualCostId = ActualCostBucket.intInventoryActualCostId 						
			) cbOut
	WHERE	ActualCostBucket.intItemId = ISNULL(@intItemId, ActualCostBucket.intItemId)
			AND ActualCostBucket.dblStockIn <> ActualCostBucket.dblStockOut
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
	WHERE	l.intItemId = ISNULL(@intItemId, l.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	UPDATE	UpdateLot
	SET		UpdateLot.dblQty = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									InvTrans.intItemUOMId
									, Lot.intItemUOMId
									, InvTrans.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN tblICItemLocation il
								ON InvTrans.intItemLocationId = il.intItemLocationId 
						INNER JOIN dbo.tblICLot Lot
							ON InvTrans.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
						AND il.intLocationId IS NOT NULL 
			)
			,dblQtyInTransit = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									InvTrans.intItemUOMId
									, Lot.intItemUOMId
									, InvTrans.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN tblICItemLocation il
								ON InvTrans.intItemLocationId = il.intItemLocationId 
						INNER JOIN dbo.tblICLot Lot
							ON InvTrans.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
						AND il.intLocationId IS NULL 
			)
	FROM	tblICLot UpdateLot INNER JOIN tblICItem i
				ON UpdateLot.intItemId = i.intItemId
	WHERE	UpdateLot.intItemId = ISNULL(@intItemId, UpdateLot.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	UPDATE	l
	SET		l.dblWeight = dbo.fnMultiply(ISNULL(l.dblQty, 0), ISNULL(l.dblWeightPerQty, 0)) 	
			,l.dblWeightInTransit = dbo.fnMultiply(ISNULL(l.dblQtyInTransit, 0), ISNULL(l.dblWeightPerQty, 0)) 	
	FROM	tblICLot l INNER JOIN tblICItem i
				ON l.intItemId = i.intItemId
	WHERE	l.intItemId = ISNULL(@intItemId, l.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

--------------------------------------------------------------------
-- Retroactively compute the stocks on Stock-UOM and Stock tables. 
--------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICFixStockQuantities
END 

------------------------------------------------------------------------------
-- Retroactively determine the last cost of the item/lot and also the ave cost.
------------------------------------------------------------------------------
BEGIN 
	UPDATE	ItemPricing 
	SET		dblLastCost = COALESCE(q.dblFindLastCost, NULLIF(ItemPricing.dblLastCost, 0), negativeStock.dblFindLastCost) 
	FROM	tblICItemPricing ItemPricing INNER JOIN tblICItem i
				ON ItemPricing.intItemId = i.intItemId
			INNER JOIN tblICItemUOM StockUOM
				ON StockUOM.intItemId = ItemPricing.intItemId
				AND StockUOM.ysnStockUnit = 1
			OUTER APPLY (
				SELECT	TOP 1 
						dblFindLastCost = dbo.fnCalculateCostBetweenUOM (
								InvTrans.intItemUOMId
								,StockUOM.intItemUOMId
								,InvTrans.dblCost
							)	
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = ItemPricing.intItemId
						AND InvTrans.intItemLocationId = ItemPricing.intItemLocationId
						AND InvTrans.dblQty > 0 
						AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
				ORDER BY InvTrans.intInventoryTransactionId DESC 						
			) q
			OUTER APPLY (
				SELECT	TOP 1 
						dblFindLastCost = dbo.fnCalculateCostBetweenUOM (
								InvTrans.intItemUOMId
								,StockUOM.intItemUOMId
								,InvTrans.dblCost
							)	
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = ItemPricing.intItemId
						AND InvTrans.intItemLocationId = ItemPricing.intItemLocationId
						AND InvTrans.dblQty < 0 
						AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
				ORDER BY InvTrans.intInventoryTransactionId DESC 						
			) negativeStock
	WHERE	ItemPricing.intItemId = ISNULL(@intItemId, ItemPricing.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	UPDATE	tblICItemPricing 
	SET		dblLastCost = ISNULL(dblLastCost, 0.00) 

	UPDATE	Lot
	SET		dblLastCost = COALESCE(q.dblFindLastCost, NULLIF(Lot.dblLastCost, 0), negativeStock.dblFindLastCost) 
	FROM	tblICLot Lot INNER JOIN tblICItem i
				ON Lot.intItemId = i.intItemId
			INNER JOIN tblICItemUOM StockUOM
				ON StockUOM.intItemId = Lot.intItemId
				AND StockUOM.ysnStockUnit = 1
			OUTER APPLY (
				SELECT	TOP 1 
						dblFindLastCost = dbo.fnCalculateCostBetweenUOM (
								InvTrans.intItemUOMId
								,StockUOM.intItemUOMId
								,InvTrans.dblCost
							)	
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = Lot.intItemId
						AND InvTrans.intItemLocationId = Lot.intItemLocationId
						AND InvTrans.intLotId = Lot.intLotId
						AND InvTrans.dblQty > 0 
						AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
				ORDER BY InvTrans.intInventoryTransactionId DESC 
			) q
			OUTER APPLY (
				SELECT	TOP 1 
						dblFindLastCost = dbo.fnCalculateCostBetweenUOM (
								InvTrans.intItemUOMId
								,StockUOM.intItemUOMId
								,InvTrans.dblCost
							)	
				FROM	dbo.tblICInventoryTransaction InvTrans 
				WHERE	InvTrans.intItemId = Lot.intItemId
						AND InvTrans.intItemLocationId = Lot.intItemLocationId
						AND InvTrans.intLotId = Lot.intLotId
						AND InvTrans.dblQty < 0 
						AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
				ORDER BY InvTrans.intInventoryTransactionId DESC 
			) negativeStock
	WHERE	Lot.intItemId = ISNULL(@intItemId, Lot.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

	UPDATE	tblICLot 
	SET		dblLastCost = ISNULL(dblLastCost, 0.00) 

	UPDATE	ItemPricing
	SET		ItemPricing.dblAverageCost = ISNULL(
				dbo.fnRecalculateAverageCost(ItemPricing.intItemId, ItemPricing.intItemLocationId)
				, ItemPricing.dblLastCost
			) 
			, ItemPricing.ysnIsPendingUpdate = 1 
	FROM	dbo.tblICItemPricing ItemPricing INNER JOIN tblICItem i
				ON ItemPricing.intItemId = i.intItemId
	WHERE	ItemPricing.intItemId = ISNULL(@intItemId, ItemPricing.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
END 

------------------------------------------------------------------------------
-- Retroactively compute the total category cost, retail, and average GM.
------------------------------------------------------------------------------
BEGIN 
	UPDATE	CategoryPricing 
	SET		dblTotalCostValue = ISNULL(T.costTotal, 0) 
			,dblTotalRetailValue = ISNULL(T.retailTotal, 0) 
			,dblAverageMargin = 
					CASE 
						WHEN ISNULL(T.retailTotal, 0) <> 0 THEN 
							dbo.fnDivide(
								(
									ISNULL(T.retailTotal, 0)
									- ISNULL(T.costTotal, 0) 
								)
								, ISNULL(T.retailTotal, 0)
							)						
						ELSE 
							0.00
					END
	FROM	tblICCategory Category INNER JOIN tblICCategoryPricing CategoryPricing 
				ON Category.intCategoryId = CategoryPricing.intCategoryId			
			OUTER APPLY (
				SELECT	costTotal = SUM(ISNULL(t.dblCategoryCostValue, 0)) 
						,retailTotal = SUM(ISNULL(t.dblCategoryRetailValue, 0)) 
				FROM	dbo.tblICInventoryTransaction t
				WHERE	t.intCategoryId = CategoryPricing.intCategoryId
						AND t.intItemLocationId = CategoryPricing.intItemLocationId
			) T
	WHERE	Category.ysnRetailValuation = 1
			AND ISNULL(CategoryPricing.intCategoryId, 0) = COALESCE(@intCategoryId, CategoryPricing.intCategoryId, 0) 
END 

-- Execute the repost stored procedure
BEGIN 
	DECLARE @strBatchId AS NVARCHAR(40)
			,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
			,@intEntityUserSecurityId AS INT
			,@strGLDescription AS NVARCHAR(255) = NULL 
			,@ItemsToPost AS ItemCostingTableType 
			,@ItemsForInTransitCosting AS ItemInTransitCostingTableType
			,@strTransactionForm AS NVARCHAR(50)
			,@intTransactionId AS INT 
			,@strTransactionId AS NVARCHAR(50)
			,@GLEntries AS RecapTableType 
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


	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpICInventoryTransaction) 
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
					,@dblUnitRetail = dblUnitRetail
					,@dblCategoryCostValue = dblCategoryCostValue
					,@dblCategoryRetailValue = dblCategoryRetailValue
					,@dtmDate = dtmDate
			FROM	#tmpICInventoryTransaction
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
					,@dblUnitRetail = dblUnitRetail
					,@dblCategoryCostValue = dblCategoryCostValue
					,@dblCategoryRetailValue = dblCategoryRetailValue
					,@dtmDate = dtmDate
			FROM	#tmpICInventoryTransaction
			--ORDER BY id2 ASC, id ASC
			ORDER BY sortId ASC
		END 

		-- Run the post routine. 
		BEGIN 
			--PRINT 'Posting ' + @strBatchId + ' ' + @strTransactionId 
			
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
								WHEN @strTransactionForm IN ('Inventory Count') THEN 
									'Inventory Adjustment'
								WHEN @strTransactionForm = 'Inventory Receipt' THEN 
									'AP Clearing'
								WHEN @strTransactionForm = 'Inventory Shipment' THEN 
									'Cost of Goods'
								WHEN @strTransactionForm IN ('Invoice', 'Credit Memo') THEN 
									'Cost of Goods'
								WHEN @strTransactionForm = 'Inventory Transfer' THEN 
									CASE	WHEN EXISTS (SELECT TOP 1 1 FROM dbo.tblICInventoryTransfer WHERE strTransferNo = @strTransactionId AND intFromLocationId <> intToLocationId AND ISNULL(ysnShipmentRequired,0) = 1) THEN 
												'Inventory In-Transit'
											ELSE 
												NULL 
									END 
								WHEN @strTransactionForm IN ('Consume', 'Produce') THEN 
									'Work in Progress'			
								WHEN @strTransactionForm IN ('Settle Storage', 'Storage Settlement') THEN 
									'AP Clearing'
								WHEN @strTransactionForm = 'Storage Measurement Reading' THEN
									'Inventory Adjustment'
								ELSE 
									NULL 
						END

			SET @intEntityId = NULL 

			SELECT	@strTransactionType = strName  
			FROM	tblICInventoryTransactionType 
			WHERE	intTransactionTypeId = @intTransactionTypeId

			-- Set the contra-gl account to use based on transaction type. 
			SET	@strAccountToCounterInventory = 
					CASE 
						WHEN @strTransactionType =  'Inventory Adjustment - Opening Inventory' THEN 
							NULL 
						ELSE 
							@strAccountToCounterInventory
					END

			-- Clear the data on @ItemsToPost
			DELETE FROM @ItemsToPost
			DELETE FROM @ItemsForInTransitCosting

			-- Repost the Bill cost adjustments
			IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Cost Adjustment') AND ISNULL(@strTransactionForm, 'Bill') IN ('Bill'))
			BEGIN 
				--PRINT 'Reposting Bill Cost Adjustments: ' + @strTransactionId
				
				-- uspICRepostBillCostAdjustment creates and posts it own g/l entries 
				EXEC uspICRepostBillCostAdjustment
					@strTransactionId
					,@strBatchId
					,@intEntityUserSecurityId
					,@ysnRegenerateBillGLEntries
			END

			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Cost Adjustment') AND @strTransactionForm IN ('Settle Storage'))
			BEGIN 
				--PRINT 'Reposting Settle Storage Cost Adjustments: ' + @strTransactionId
				
				-- uspICRepostSettleStorageCostAdjustment creates and posts it own g/l entries 
				EXEC uspICRepostSettleStorageCostAdjustment
					@strTransactionId
					,@strBatchId
					,@intEntityUserSecurityId
			END

			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Cost Adjustment') AND @strTransactionForm IN ('Produce', 'Consume'))
			BEGIN 
				--PRINT 'Reposting MFG Cost Adjustments: ' + @strTransactionId
				
				-- uspICRepostSettleStorageCostAdjustment creates and posts it own g/l entries 
				EXEC uspMFRepostCostAdjustment
					@strBatchId
					,@intEntityUserSecurityId
			END

			-- Repost 'Consume' and 'Produce'
			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Consume', 'Produce'))
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
						,intCostingMethod
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty)
						,dblCost  = 
							dbo.fnCalculateCostBetweenUOM (
								StockUOM.intItemUOMId
								,ICTrans.intItemUOMId
								,ISNULL(Lot.dblLastCost, itemPricing.dblLastCost) 
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
						,ICTrans.strActualCostId 
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
						,ICTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN tblICItemUOM StockUOM
							ON StockUOM.intItemId = ICTrans.intItemId
							AND StockUOM.ysnStockUnit = 1						
						LEFT JOIN dbo.tblICLot Lot
							ON ICTrans.intLotId = Lot.intLotId
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						OUTER APPLY  (
							SELECT TOP 1 
								dblLastCost 
							FROM 
								tblICItemPricing 
							WHERE 
								intItemId = ICTrans.intItemId 
								AND intItemLocationId = ICTrans.intItemLocationId
						) itemPricing
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

				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

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
						,intCostingMethod
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
													AND intTransactionTypeId = 8 -- Consume													
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
						,ICTrans.strActualCostId 
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
						,ICTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction ICTrans LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
				WHERE	strBatchId = @strBatchId
						AND (
							strTransactionForm = 'Produce'
							OR intTransactionTypeId = 9
						)

				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

				-- Special delete on #tmpICInventoryTransaction
				-- Produce and Consume transactions typically shares a batch but hold different transaction ids. 
				DELETE	FROM #tmpICInventoryTransaction
				WHERE	strBatchId = @strBatchId
			END

			-- Repost 'Inventory Transfer'
			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Inventory Transfer', 'Inventory Transfer with Shipment'))
			BEGIN 
				DECLARE @ysnTransferOnSameLocation AS BIT
				DECLARE @ysnShipmentRequired AS BIT 
				SET @ysnTransferOnSameLocation = 0 
				SET @ysnShipmentRequired = 0 
				
				SELECT	@ysnTransferOnSameLocation = CASE WHEN intFromLocationId <> intToLocationId THEN 0 ELSE 1 END 
						,@ysnShipmentRequired = ysnShipmentRequired
				FROM	tblICInventoryTransfer 
				WHERE	intInventoryTransferId = @intTransactionId 
						AND strTransferNo = @strTransactionId 

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
						,intCostingMethod
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnCalculateCostBetweenUOM (
									StockUOM.intItemUOMId
									,ICTrans.intItemUOMId
									,ISNULL(lot.dblLastCost, itemPricing.dblLastCost)
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
						,COALESCE(Detail.strFromLocationActualCostId, Header.strActualCostId, ICTrans.strActualCostId)
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
						,ICTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN dbo.tblICInventoryTransfer Header
							ON ICTrans.strTransactionId = Header.strTransferNo				
						INNER JOIN dbo.tblICInventoryTransferDetail Detail
							ON Detail.intInventoryTransferId = Header.intInventoryTransferId
							AND Detail.intInventoryTransferDetailId = ICTrans.intTransactionDetailId 
						INNER JOIN tblICItemUOM StockUOM
							ON StockUOM.intItemId = ICTrans.intItemId 
							AND StockUOM.ysnStockUnit = 1
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = ICTrans.intLotId
						OUTER APPLY (
							SELECT TOP 1 dblLastCost 
							FROM 
								tblICItemPricing 
							WHERE 
								intItemId = ICTrans.intItemId 
								AND intItemLocationId = ICTrans.intItemLocationId
						) itemPricing
				WHERE	strBatchId = @strBatchId
						AND ICTrans.dblQty < 0 

				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,NULL --@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId
					,@ysnTransferOnSameLocation

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

				IF @ysnShipmentRequired = 1 
				BEGIN 
					DELETE FROM @ItemsForInTransitCosting
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
							[intItemId] = t.intItemId
							,[intItemLocationId] = dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
							,[intItemUOMId] = t.intItemUOMId
							,[dtmDate] = t.dtmDate
							,[dblQty] = -t.dblQty
							,[dblUOMQty] = t.dblUOMQty
							,[dblCost] = t.dblCost
							,[dblValue] = t.dblValue
							,[dblSalesPrice] = t.dblSalesPrice
							,[intCurrencyId] = t.intCurrencyId
							,[dblExchangeRate] = t.dblExchangeRate
							,[intTransactionId] = t.intTransactionId
							,[intTransactionDetailId] = t.intTransactionDetailId
							,[strTransactionId] = t.strTransactionId
							,[intTransactionTypeId] = t.intTransactionTypeId
							,[intLotId] = t.intLotId
							,[intTransactionId] = t.intTransactionId
							,[strTransactionId] = t.strTransactionId
							,[intTransactionDetailId] = t.intTransactionDetailId
							,[intFobPointId] = t.intFobPointId
							,[intInTransitSourceLocationId] = dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
					FROM	tblICInventoryTransferDetail Detail INNER JOIN tblICInventoryTransfer Header 
								ON Header.intInventoryTransferId = Detail.intInventoryTransferId
							INNER JOIN tblICItem i 
								ON i.intItemId = Detail.intItemId 
							INNER JOIN dbo.tblICInventoryTransaction t
								ON t.intItemId = Detail.intItemId
								AND t.intTransactionDetailId = Detail.intInventoryTransferDetailId
								AND t.intTransactionId = Header.intInventoryTransferId
								AND t.strTransactionId = Header.strTransferNo
								AND t.strBatchId = @strBatchId
								AND t.dblQty < 0
							LEFT JOIN dbo.tblICItemUOM ItemUOM
								ON t.intItemId = ItemUOM.intItemId
								AND t.intItemUOMId = ItemUOM.intItemUOMId
					WHERE	Header.strTransferNo = @strTransactionId
							AND t.strBatchId = @strBatchId
							AND Detail.intItemId = ISNULL(@intItemId, Detail.intItemId)
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

					EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
						@ItemsForInTransitCosting
						,@strBatchId
						,NULL -- @strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
				END
				ELSE 
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
							,intCostingMethod
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
							,ISNULL(Detail.strToLocationActualCostId, Header.strActualCostId)
							,TransferSource.intForexRateTypeId
							,TransferSource.dblForexRate
							,intCostingMethod = 
								CASE 
									WHEN ISNULL(Detail.strToLocationActualCostId, Header.strActualCostId) IS NOT NULL THEN @ACTUALCOST 
									ELSE NULL 
								END
					FROM	tblICInventoryTransferDetail Detail INNER JOIN tblICInventoryTransfer Header 
								ON Header.intInventoryTransferId = Detail.intInventoryTransferId
							INNER JOIN tblICItem i
								ON i.intItemId = Detail.intItemId
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
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId
						,@ysnTransferOnSameLocation

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
				END 

				-- Create the GL entries if transfer is between company locations. 
				-- Do not create the GL entries if transfer if within the same company location. 
				IF @ysnTransferOnSameLocation = 0 AND @ysnShipmentRequired = 0
				BEGIN 
					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntries
						@strBatchId 
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks.
						,@strTransactionId -- This is only used when rebuilding the stocks.
						,@intCategoryId -- This is only used when rebuilding the stocks.

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntries'
						GOTO _EXIT_WITH_ERROR
					END 
				END
				ELSE IF @ysnTransferOnSameLocation = 0 AND @ysnShipmentRequired = 1
				BEGIN 
					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting
						@strBatchId 
						,NULL -- @strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@intItemId -- This is only used when rebuilding the stocks.
						,@strTransactionId -- This is only used when rebuilding the stocks.
						,@intCategoryId -- This is only used when rebuilding the stocks.

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting'
						GOTO _EXIT_WITH_ERROR
					END 

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntries
						@strBatchId 
						,NULL 
						,@intEntityUserSecurityId
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks.
						,NULL --,@strTransactionId -- This is only used when rebuilding the stocks.
						,@intCategoryId -- This is only used when rebuilding the stocks.

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntries'
						GOTO _EXIT_WITH_ERROR
					END 
				END 				
			END	

			-- Repost the following type of Inventory Adjustment:
			ELSE IF EXISTS (
				SELECT	1 
				WHERE	@strTransactionType IN (
							'Inventory Adjustment - Split Lot'
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
						INNER JOIN tblICItem i
							ON i.intItemId = AdjDetail.intItemId 
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
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
							,intCostingMethod
					)
					SELECT 	RebuildInvTrans.intItemId  
							,RebuildInvTrans.intItemLocationId 
							,RebuildInvTrans.intItemUOMId  
							,RebuildInvTrans.dtmDate  
							,RebuildInvTrans.dblQty  
							,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
							,dblCost = AdjDetail.dblCost
							,RebuildInvTrans.dblSalesPrice  
							,RebuildInvTrans.intCurrencyId  
							,RebuildInvTrans.dblExchangeRate  
							,RebuildInvTrans.intTransactionId  
							,RebuildInvTrans.intTransactionDetailId  
							,RebuildInvTrans.strTransactionId  
							,RebuildInvTrans.intTransactionTypeId  
							,RebuildInvTrans.intLotId 
							,RebuildInvTrans.intSubLocationId
							,RebuildInvTrans.intStorageLocationId
							,RebuildInvTrans.strActualCostId 
							,RebuildInvTrans.intForexRateTypeId
							,RebuildInvTrans.dblForexRate
							,RebuildInvTrans.intCostingMethod
					FROM	#tmpICInventoryTransaction RebuildInvTrans LEFT JOIN dbo.tblICInventoryAdjustment Adj
								ON Adj.strAdjustmentNo = RebuildInvTrans.strTransactionId
								AND Adj.intInventoryAdjustmentId = RebuildInvTrans.intTransactionId
							LEFT JOIN (
								dbo.tblICInventoryAdjustmentDetail AdjDetail INNER JOIN tblICItem i
									ON AdjDetail.intItemId = i.intItemId
							)
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
								AND AdjDetail.intInventoryAdjustmentDetailId = RebuildInvTrans.intTransactionDetailId 
							LEFT JOIN dbo.tblICItemUOM AdjItemUOM
								ON AdjDetail.intItemId = AdjItemUOM.intItemId
								AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
							LEFT JOIN dbo.tblICItemUOM ItemUOM
								ON RebuildInvTrans.intItemId = ItemUOM.intItemId
								AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
					WHERE	RebuildInvTrans.strBatchId = @strBatchId
							AND RebuildInvTrans.dblQty < 0
							AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
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
							,intCostingMethod
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
							,strActualCostId		= FromStock.strActualCostId 
							,intForexRateTypeId		= NULL
							,dblForexRate			= 1 
							,intCostingMethod		= FromStock.intCostingMethod
					FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId

							INNER JOIN dbo.tblICInventoryTransaction FromStock 
								ON FromStock.intLotId = AdjDetail.intLotId 
								AND FromStock.intTransactionId = Adj.intInventoryAdjustmentId 
								AND FromStock.strTransactionId = Adj.strAdjustmentNo
								AND FromStock.intTransactionDetailId = AdjDetail.intInventoryAdjustmentDetailId
								AND FromStock.dblQty < 0

							-- Source Lot
							LEFT JOIN (
								dbo.tblICLot SourceLot INNER JOIN dbo.tblICItemLocation SourceLotItemLocation 
									ON SourceLotItemLocation.intItemLocationId = SourceLot.intItemLocationId 
									AND SourceLotItemLocation.intItemId = SourceLot.intItemId								
							)
								ON SourceLot.intLotId = FromStock.intLotId							
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

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId
				END
			END

			-- Repost the Inventory Adjustment - Item Change. 
			/*
				Important Note: 
				Item Change rebuild does not work well if you are rebuilding one item. 
				This particular adjustment changes a stock from one item to another item. 
				Rebuild one item and you will leave the other item outdated. 

				Suggestion: 
					1. If both items are the same commodity, then rebuild it by commodity. 
					2. If possible, rebuild it all items per period. 
			*/
			ELSE IF EXISTS (
				SELECT	1 
				WHERE	@strTransactionType IN (
							'Inventory Adjustment - Item Change'
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
						INNER JOIN tblICItem i
							ON i.intItemId = AdjDetail.intItemId 
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
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

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
							,intCostingMethod
					)
					SELECT 	RebuildInvTrans.intItemId  
							,RebuildInvTrans.intItemLocationId 
							,RebuildInvTrans.intItemUOMId  
							,RebuildInvTrans.dtmDate  
							,RebuildInvTrans.dblQty  
							,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
							,dblCost = AdjDetail.dblCost
							,RebuildInvTrans.dblSalesPrice  
							,RebuildInvTrans.intCurrencyId  
							,RebuildInvTrans.dblExchangeRate  
							,RebuildInvTrans.intTransactionId  
							,RebuildInvTrans.intTransactionDetailId  
							,RebuildInvTrans.strTransactionId  
							,RebuildInvTrans.intTransactionTypeId  
							,RebuildInvTrans.intLotId 
							,RebuildInvTrans.intSubLocationId
							,RebuildInvTrans.intStorageLocationId
							,RebuildInvTrans.strActualCostId 
							,RebuildInvTrans.intForexRateTypeId
							,RebuildInvTrans.dblForexRate
							,RebuildInvTrans.intCostingMethod
					FROM	#tmpICInventoryTransaction RebuildInvTrans LEFT JOIN dbo.tblICInventoryAdjustment Adj
								ON Adj.strAdjustmentNo = RebuildInvTrans.strTransactionId
								AND Adj.intInventoryAdjustmentId = RebuildInvTrans.intTransactionId
							LEFT JOIN (
								dbo.tblICInventoryAdjustmentDetail AdjDetail INNER JOIN tblICItem i
									ON AdjDetail.intItemId = i.intItemId
							)
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
								AND AdjDetail.intInventoryAdjustmentDetailId = RebuildInvTrans.intTransactionDetailId 
							LEFT JOIN dbo.tblICItemUOM AdjItemUOM
								ON AdjDetail.intItemId = AdjItemUOM.intItemId
								AND AdjDetail.intItemUOMId = AdjItemUOM.intItemUOMId
							LEFT JOIN dbo.tblICItemUOM ItemUOM
								ON RebuildInvTrans.intItemId = ItemUOM.intItemId
								AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
					WHERE	RebuildInvTrans.strBatchId = @strBatchId
							AND RebuildInvTrans.dblQty < 0
							AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
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
							,intCostingMethod
					)
					SELECT 	AdjDetail.intNewItemId
							,NewItemLocation.intItemLocationId
							,intItemUOMId = 
									NewItemUOM.intItemUOMId									
							,Adj.dtmAdjustmentDate
							,dblQty = 
									-FromStock.dblQty
							,dblUOMQty = 
									NewItemUOM.dblUnitQty
							,dblCost = 
									CASE 
										WHEN AdjDetail.dblNewCost IS NULL THEN 
											FromStock.dblCost
										ELSE
											dbo.fnCalculateCostBetweenUOM( 
												dbo.fnGetItemStockUOM(AdjDetail.intNewItemId)
												,dbo.fnGetMatchingItemUOMId(AdjDetail.intNewItemId, AdjDetail.intItemUOMId)
												,AdjDetail.dblNewCost
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
							,intSubLocationId		= ISNULL(NewLot.intSubLocationId, AdjDetail.intNewSubLocationId)
							,intStorageLocationId	= ISNULL(NewLot.intStorageLocationId, AdjDetail.intNewStorageLocationId)
							,strActualCostId		= FromStock.strActualCostId 
							,intForexRateTypeId		= NULL
							,dblForexRate			= 1 
							,intCostingMethod		= FromStock.intCostingMethod
					FROM	dbo.tblICInventoryAdjustment Adj INNER JOIN dbo.tblICInventoryAdjustmentDetail AdjDetail 
								ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId

							INNER JOIN tblICItem i 
								ON i.intItemId = AdjDetail.intItemId 

							INNER JOIN dbo.tblICItemLocation NewItemLocation 
								ON NewItemLocation.intLocationId = Adj.intLocationId 
								AND NewItemLocation.intItemId = AdjDetail.intNewItemId

							INNER JOIN dbo.tblICInventoryTransaction FromStock 
								ON 
								ISNULL(FromStock.intLotId,0) = ISNULL(AdjDetail.intLotId,0) 
								AND FromStock.intTransactionId = Adj.intInventoryAdjustmentId 
								AND FromStock.strTransactionId = Adj.strAdjustmentNo
								AND FromStock.intTransactionDetailId = AdjDetail.intInventoryAdjustmentDetailId
								AND FromStock.dblQty < 0
							
							LEFT JOIN dbo.tblICItemUOM NewItemUOM
								ON NewItemUOM.intItemId = AdjDetail.intNewItemId
								AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId (
									AdjDetail.intNewItemId
									, FromStock.intItemUOMId
								)
								
							LEFT JOIN tblICLot NewLot
								ON NewLot.intLotId = AdjDetail.intNewLotId

					WHERE	Adj.strAdjustmentNo = @strTransactionId
							AND FromStock.strBatchId = @strBatchId
							AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId
				END
			END
			
			-- Repost 'Inventory Shipment'
			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Inventory Shipment')) 
			BEGIN 
				-- Check how the shipment was originally posted
				BEGIN 
					SET @ShipmentPostScenario = @ShipmentPostScenario_FreightBased

					IF EXISTS (
						SELECT	TOP 1 1
						FROM	tblICBackupDetailInventoryTransaction b INNER JOIN tblICItem i
									ON b.intItemId = i.intItemId 
						WHERE	b.intBackupId = @intBackupId 
								AND b.intItemId = ISNULL(@intItemId, b.intItemId) 
								AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
								AND b.strTransactionId = @strTransactionId
								AND b.intInTransitSourceLocationId IS NOT NULL 
								AND b.ysnIsUnposted = 0 
					)
					BEGIN 
						SET @ShipmentPostScenario = @ShipmentPostScenario_InTransitBased
					END 
				END 

				-- Force rebuild as in-transit if @ysnRebuildShipmentAndInvoiceAsInTransit set to true. 
				IF @ysnRebuildShipmentAndInvoiceAsInTransit = 1
				BEGIN 
					SET @ShipmentPostScenario = @ShipmentPostScenario_InTransitBased
				END

				-- Check the freight terms if posting scenario is freight-based
				IF @ShipmentPostScenario = @ShipmentPostScenario_FreightBased
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
				END 

				-- Check the freight terms if posting scenario is in-transit-based
				IF @ShipmentPostScenario = @ShipmentPostScenario_InTransitBased
				BEGIN 
					SET @strAccountToCounterInventory = NULL 
				END 

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
						,intCostingMethod
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnCalculateCostBetweenUOM (
									StockUOM.intItemUOMId
									,ICTrans.intItemUOMId
									,ISNULL(lot.dblLastCost, itemPricing.dblLastCost) 
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
						,ICTrans.strActualCostId 
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
						,ICTrans.intCostingMethod

				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN tblICItemLocation ItemLocation 
							ON ICTrans.intItemLocationId = ItemLocation.intItemLocationId 
						INNER JOIN tblICItemUOM StockUOM
							ON StockUOM.intItemId = ICTrans.intItemId
							AND StockUOM.ysnStockUnit = 1

						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN tblICLot lot
							ON lot.intLotId = ICTrans.intLotId
						OUTER APPLY (
							SELECT TOP 1 
								dblLastCost 
							FROM 
								tblICItemPricing 
							WHERE 
								intItemId = ICTrans.intItemId 
								AND intItemLocationId = ICTrans.intItemLocationId
						) itemPricing
	
				WHERE	strBatchId = @strBatchId
						AND ICTrans.dblQty < 0 
						AND ItemLocation.intLocationId IS NOT NULL

				-- Get the Customer Entity Id 
				SELECT	@intEntityId = intEntityCustomerId 
				FROM	tblICInventoryShipment s
				WHERE	s.intInventoryShipmentId = @intTransactionId
						AND s.strShipmentNumber = @strTransactionId
					
				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

				SET @intReturnValue = NULL 
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
				EXEC @intReturnValue = dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL  
					,@intItemId -- This is only used when rebuilding the stocks. 
					,@strTransactionId 
					,@intCategoryId
					
				IF @intReturnValue <> 0 
				BEGIN 
					--PRINT 'Error found in uspICCreateGLEntries - Inventory Shipment'
					GOTO _EXIT_WITH_ERROR
				END 			

				IF 	@strAccountToCounterInventory IS NULL -- If NULL, the shipment was originally posted as in-transit. 
				BEGIN 
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
							t.[intItemId] 
							,t.[intItemLocationId] 
							,t.[intItemUOMId] 
							,t.[dtmDate] 
							,-t.[dblQty] 
							,t.[dblUOMQty] 
							,t.[dblCost] 
							,t.[dblValue] 
							,t.[dblSalesPrice] 
							,t.[intCurrencyId] 
							,t.[dblExchangeRate] 
							,t.[intTransactionId] 
							,t.[intTransactionDetailId] 
							,t.[strTransactionId] 
							,t.[intTransactionTypeId] 
							,t.[intLotId] 
							,t.[intTransactionId] 
							,t.[strTransactionId] 
							,t.[intTransactionDetailId] 
							,[intFobPointId] = @intFobPointId
							,[intInTransitSourceLocationId] = t.intItemLocationId
					FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
								ON t.intItemId = i.intItemId 
					WHERE	t.strTransactionId = @strTransactionId
							AND t.ysnIsUnposted = 0 
							AND t.strBatchId = @strBatchId
							AND t.dblQty < 0 -- Ensure the Qty is negative. 
							AND t.intItemId = ISNULL(@intItemId, t.intItemId)
							AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)

					EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
						@ItemsForInTransitCosting
						,@strBatchId
						,NULL 
						,@intEntityUserSecurityId
						,@strGLDescription

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
						@strBatchId
						,NULL 
						,@intEntityUserSecurityId
						,@strGLDescription
						,@intItemId
						,@strTransactionId
						,@intCategoryId

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Inventory Shipment'
						GOTO _EXIT_WITH_ERROR
					END 	
				END 
			END
			 				
			-- Repost 'Credit Memo'
			--ELSE IF EXISTS (
			--	SELECT	1 
			--	FROM	tblICInventoryTransactionType 
			--	WHERE	intTransactionTypeId = @intTransactionTypeId 
			--			AND strName IN ('Credit Memo')
			--	) 
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
			--			,intForexRateTypeId
			--			,dblForexRate
			--			,intCostingMethod
			--	)
			--	SELECT 	RebuildInvTrans.intItemId  
			--			,RebuildInvTrans.intItemLocationId 
			--			,RebuildInvTrans.intItemUOMId  
			--			,RebuildInvTrans.dtmDate  
			--			,RebuildInvTrans.dblQty  
			--			,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
			--			,dblCost  = CASE
			--							WHEN RebuildInvTrans.dblQty < 0 THEN 
			--								CASE	
			--										WHEN dbo.fnGetCostingMethod(RebuildInvTrans.intItemId, RebuildInvTrans.intItemLocationId) = @AVERAGECOST THEN 
			--											dbo.fnGetItemAverageCost(
			--												RebuildInvTrans.intItemId
			--												, RebuildInvTrans.intItemLocationId
			--												, RebuildInvTrans.intItemUOMId
			--											) 
			--										ELSE 
			--											ISNULL(lot.dblLastCost, itemPricing.dblLastCost)
			--								END 

			--							-- When it is a credit memo:
			--							--WHEN (RebuildInvTrans.dblQty > 0 AND RebuildInvTrans.strTransactionId LIKE 'SI%') THEN 
			--							WHEN RebuildInvTrans.dblQty > 0 THEN 											
			--								CASE	WHEN dbo.fnGetCostingMethod(RebuildInvTrans.intItemId, RebuildInvTrans.intItemLocationId) = @AVERAGECOST THEN 
			--											-- If using Average Costing, use Ave Cost.
			--											dbo.fnGetItemAverageCost(
			--												RebuildInvTrans.intItemId
			--												, RebuildInvTrans.intItemLocationId
			--												, RebuildInvTrans.intItemUOMId
			--											) 
			--										ELSE
			--											-- Otherwise, get the last cost. 
			--											ISNULL(lot.dblLastCost, itemPricing.dblLastCost)
			--								END 

			--							ELSE 
			--								RebuildInvTrans.dblCost
			--						END 
			--			,RebuildInvTrans.dblSalesPrice  
			--			,RebuildInvTrans.intCurrencyId  
			--			,RebuildInvTrans.dblExchangeRate  
			--			,RebuildInvTrans.intTransactionId  
			--			,RebuildInvTrans.intTransactionDetailId  
			--			,RebuildInvTrans.strTransactionId  
			--			,RebuildInvTrans.intTransactionTypeId  
			--			,RebuildInvTrans.intLotId 
			--			,RebuildInvTrans.intSubLocationId
			--			,RebuildInvTrans.intStorageLocationId
			--			,RebuildInvTrans.strActualCostId
			--			,RebuildInvTrans.intForexRateTypeId
			--			,RebuildInvTrans.dblForexRate
			--			,RebuildInvTrans.intCostingMethod

			--	FROM	#tmpICInventoryTransaction RebuildInvTrans INNER JOIN tblICItem i
			--				ON i.intItemId = RebuildInvTrans.intItemId 
			--			INNER JOIN tblICItemLocation ItemLocation
			--				ON RebuildInvTrans.intItemLocationId = ItemLocation.intItemLocationId
			--			LEFT JOIN dbo.tblARInvoice Invoice
			--				ON Invoice.intInvoiceId = RebuildInvTrans.intTransactionId
			--				AND Invoice.strInvoiceNumber = RebuildInvTrans.strTransactionId
			--			LEFT JOIN dbo.tblICItemUOM ItemUOM
			--				ON RebuildInvTrans.intItemId = ItemUOM.intItemId
			--				AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
			--			LEFT JOIN dbo.tblICItemUOM StockUOM
			--				ON StockUOM.intItemId = RebuildInvTrans.intItemId
			--				AND StockUOM.ysnStockUnit = 1
			--			OUTER APPLY (
			--				SELECT
			--					lot.intLotId
			--					,dblLastCost = dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, ItemUOM.intItemUOMId, lot.dblLastCost)
			--				FROM	
			--					dbo.tblICLot lot 
			--				WHERE	
			--					lot.intLotId = RebuildInvTrans.intLotId 
			--					AND lot.intItemId = RebuildInvTrans.intItemId
			--			) lot
			--			OUTER APPLY (
			--				SELECT	TOP 1 
			--						dblLastCost = dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, ItemUOM.intItemUOMId, p.dblLastCost)
			--				FROM	tblICItemPricing p 
			--				WHERE	p.intItemId = RebuildInvTrans.intItemId 
			--						AND p.intItemLocationId = RebuildInvTrans.intItemLocationId
			--			) itemPricing
			--	WHERE	RebuildInvTrans.strBatchId = @strBatchId
			--			AND RebuildInvTrans.intTransactionId = @intTransactionId
			--			AND RebuildInvTrans.strTransactionId = @strTransactionId
			--			AND ItemLocation.intLocationId IS NOT NULL -- It ensures that the item is not In-Transit. 
			--			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			--			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)

			--	IF EXISTS (SELECT TOP 1 1 FROM @ItemsToPost)
			--	BEGIN 
			--		EXEC @intReturnValue = dbo.uspICRepostCosting
			--			@strBatchId
			--			,@strAccountToCounterInventory
			--			,@intEntityUserSecurityId
			--			,@strGLDescription
			--			,@ItemsToPost
			--			,@strTransactionId

			--		IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

			--		SET @intReturnValue = NULL 
			--		INSERT INTO @GLEntries (
			--				[dtmDate] 
			--				,[strBatchId]
			--				,[intAccountId]
			--				,[dblDebit]
			--				,[dblCredit]
			--				,[dblDebitUnit]
			--				,[dblCreditUnit]
			--				,[strDescription]
			--				,[strCode]
			--				,[strReference]
			--				,[intCurrencyId]
			--				,[dblExchangeRate]
			--				,[dtmDateEntered]
			--				,[dtmTransactionDate]
			--				,[strJournalLineDescription]
			--				,[intJournalLineNo]
			--				,[ysnIsUnposted]
			--				,[intUserId]
			--				,[intEntityId]
			--				,[strTransactionId]
			--				,[intTransactionId]
			--				,[strTransactionType]
			--				,[strTransactionForm] 
			--				,[strModuleName]
			--				,[intConcurrencyId]
			--				,[dblDebitForeign]
			--				,[dblDebitReport]
			--				,[dblCreditForeign]
			--				,[dblCreditReport]
			--				,[dblReportingRate]
			--				,[dblForeignRate]
			--				,[strRateType]
			--		)			
			--		EXEC @intReturnValue = dbo.uspICCreateGLEntries
			--			@strBatchId 
			--			,@strAccountToCounterInventory
			--			,@intEntityUserSecurityId
			--			,@strGLDescription
			--			,NULL 
			--			,@intItemId -- This is only used when rebuilding the stocks. 
			--			,@strTransactionId -- This is only used when rebuilding the stocks. 
			--			,@intCategoryId

			--		IF @intReturnValue <> 0 
			--		BEGIN 
			--			--PRINT 'Error found in uspICCreateGLEntries - Credit Memo'
			--			GOTO _EXIT_WITH_ERROR
			--		END
			--	END						
			--END	

			-- Repost 'Invoice' and 'Credit Memo'
			ELSE IF EXISTS (
				SELECT	1 
				FROM	tblICInventoryTransactionType 
				WHERE	intTransactionTypeId = @intTransactionTypeId 
						AND strName IN ('Invoice', 'Credit Memo')
				) 
			BEGIN 
				-- Process the invoice as one batch. 
				SET @strTransactionId = NULL 

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
						,intCostingMethod
				)
				SELECT 	RebuildInvTrans.intItemId  
						,RebuildInvTrans.intItemLocationId 
						,RebuildInvTrans.intItemUOMId  
						,RebuildInvTrans.dtmDate  
						,RebuildInvTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
						,dblCost  = CASE
										WHEN RebuildInvTrans.dblQty < 0 THEN 
											CASE	
													WHEN dbo.fnGetCostingMethod(RebuildInvTrans.intItemId, RebuildInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														dbo.fnGetItemAverageCost(
															RebuildInvTrans.intItemId
															, RebuildInvTrans.intItemLocationId
															, RebuildInvTrans.intItemUOMId
														) 
													ELSE 
														dbo.fnCalculateCostBetweenUOM (
															StockUOM.intItemUOMId
															,RebuildInvTrans.intItemUOMId
															,ISNULL(lot.dblLastCost, itemPricing.dblLastCost) 
														)
											END 

										-- When it is a credit memo:
										WHEN RebuildInvTrans.dblQty > 0 THEN 
											
											CASE	WHEN dbo.fnGetCostingMethod(RebuildInvTrans.intItemId, RebuildInvTrans.intItemLocationId) = @AVERAGECOST THEN 
														-- If using Average Costing, use Ave Cost.
														dbo.fnGetItemAverageCost(
															RebuildInvTrans.intItemId
															, RebuildInvTrans.intItemLocationId
															, RebuildInvTrans.intItemUOMId
														) 
													ELSE
														-- Otherwise, get the last cost. 
														ISNULL(lot.dblLastCost, itemPricing.dblLastCost)
											END 
										ELSE 
											RebuildInvTrans.dblCost
									END 
						,RebuildInvTrans.dblSalesPrice  
						,RebuildInvTrans.intCurrencyId  
						,RebuildInvTrans.dblExchangeRate  
						,RebuildInvTrans.intTransactionId  
						,RebuildInvTrans.intTransactionDetailId  
						,RebuildInvTrans.strTransactionId  
						,RebuildInvTrans.intTransactionTypeId  
						,RebuildInvTrans.intLotId 
						,RebuildInvTrans.intSubLocationId
						,RebuildInvTrans.intStorageLocationId
						,RebuildInvTrans.strActualCostId
						,RebuildInvTrans.intForexRateTypeId
						,RebuildInvTrans.dblForexRate
						,RebuildInvTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction RebuildInvTrans INNER JOIN tblICItem i
							ON RebuildInvTrans.intItemId = i.intItemId 
						INNER JOIN tblICItemLocation ItemLocation
							ON RebuildInvTrans.intItemLocationId = ItemLocation.intItemLocationId
						LEFT JOIN (
							dbo.tblARInvoice Invoice INNER JOIN tblARInvoiceDetail InvoiceItems
								ON Invoice.intInvoiceId = InvoiceItems.intInvoiceId
						)
							ON Invoice.strInvoiceNumber = RebuildInvTrans.strTransactionId
							AND Invoice.intInvoiceId = RebuildInvTrans.intTransactionId
							AND InvoiceItems.intInvoiceDetailId = RebuildInvTrans.intTransactionDetailId 
							AND InvoiceItems.intItemId = i.intItemId 
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuildInvTrans.intItemId = ItemUOM.intItemId
							AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = RebuildInvTrans.intLotId
							
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = RebuildInvTrans.intItemId
							AND StockUOM.ysnStockUnit = 1

						OUTER APPLY (
							SELECT TOP 1 
								dblLastCost 
							FROM 
								tblICItemPricing p
							WHERE 
								p.intItemId = RebuildInvTrans.intItemId 
								AND p.intItemLocationId = RebuildInvTrans.intItemLocationId
						) itemPricing

				WHERE	RebuildInvTrans.strBatchId = @strBatchId
						--AND RebuildInvTrans.intTransactionId = @intTransactionId
						--AND RebuildInvTrans.strTransactionId = @strTransactionId
						AND ItemLocation.intLocationId IS NOT NULL -- It ensures that the item is not In-Transit. 
						AND i.intItemId = ISNULL(@intItemId, i.intItemId)
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)
						AND (
							1 = 
								CASE 
									WHEN 
										@ysnRebuildShipmentAndInvoiceAsInTransit = 1 
										AND ISNULL(InvoiceItems.intInventoryShipmentItemId, InvoiceItems.intLoadDetailId) IS NOT NULL 
									THEN 
										0
									ELSE 
										1
								END 
						)
						AND dbo.fnDateEquals(RebuildInvTrans.dtmDate, @dtmDate) = 1

				IF EXISTS (SELECT TOP 1 1 FROM @ItemsToPost)
				BEGIN 
					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost
						,@strTransactionId

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
				

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntries
						@strBatchId 
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks. 
						,@strTransactionId -- This is only used when rebuilding the stocks. 
						,@intCategoryId -- This is only used when rebuilding the stocks. 
						,@dtmDate
				END
						
				IF @intReturnValue <> 0 
				BEGIN 
					--PRINT 'Error found in uspICCreateGLEntries - Invoice/Credit Memo'
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
						--,[intFobPointId] 
						,[intInTransitSourceLocationId]				
				)
				SELECT
						[intItemId]					= t.intItemId
						,[intItemLocationId]		= t.intItemLocationId
						,[intItemUOMId]				= t.intItemUOMId
						,[dtmDate]					= t.dtmDate--i.dtmDate
						,[dblQty]					= t.dblQty
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
						,[intSourceTransactionId]	= ISNULL(s.intInventoryShipmentId, l.intLoadId) 
						,[strSourceTransactionId]		= ISNULL(s.strShipmentNumber, l.strLoadNumber)
						,[intSourceTransactionDetailId] = ISNULL(si.intInventoryShipmentItemId, ld.intLoadDetailId) 
						--,[intFobPointId]				= t.intFobPointId
						,[intInTransitSourceLocationId]	= 
							CASE 
								WHEN @ysnRebuildShipmentAndInvoiceAsInTransit = 1 AND t.intInTransitSourceLocationId IS NULL THEN 
									t.intItemLocationId
								ELSE 
									t.intInTransitSourceLocationId
							END 
				FROM	
						tblARInvoice i INNER JOIN tblARInvoiceDetail id 
							ON i.intInvoiceId = id.intInvoiceId
						INNER JOIN tblICItem item
							ON item.intItemId = id.intItemId
						INNER JOIN #tmpICInventoryTransaction t
							ON t.intTransactionId = i.intInvoiceId
							AND t.intTransactionDetailId = id.intInvoiceDetailId 
							AND t.strTransactionId = i.strInvoiceNumber 
							AND t.ysnIsUnposted = 0 
						-- Invoice item came from Inventory Shipment. 
						LEFT JOIN (
							tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
								ON s.intInventoryShipmentId = si.intInventoryShipmentId
						)
							ON si.intInventoryShipmentItemId = id.intInventoryShipmentItemId
							AND s.ysnPosted = 1
						-- Invoice item came from Load Shipment (or Load Schedule) 
						LEFT JOIN (
							tblLGLoad l INNER JOIN tblLGLoadDetail ld
								ON l.intLoadId = ld.intLoadId
						)
							ON ld.intLoadDetailId = id.intLoadDetailId
							AND l.ysnPosted = 1

				WHERE	--i.strInvoiceNumber = @strTransactionId
						--AND i.intInvoiceId = @intTransactionId
						t.strBatchId = @strBatchId
						AND item.intItemId = ISNULL(@intItemId, item.intItemId)
						AND ISNULL(item.intCategoryId, 0) = COALESCE(@intCategoryId, item.intCategoryId, 0)
						AND (
							1 = 
							CASE 
								WHEN t.intInTransitSourceLocationId IS NOT NULL THEN 1
								WHEN @ysnRebuildShipmentAndInvoiceAsInTransit  = 1 AND t.intInTransitSourceLocationId IS NULL THEN 1
								ELSE 0
							END
						)
						AND dbo.fnDateEquals(t.dtmDate, @dtmDate) = 1

				IF EXISTS (SELECT TOP 1 1 FROM @ItemsForInTransitCosting)
				BEGIN 
					EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
						@ItemsForInTransitCosting
						,@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription

					IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
						@strBatchId
						,@strAccountToCounterInventory 
						,@intEntityUserSecurityId
						,@strGLDescription
						,@intItemId -- This is only used when rebuilding the stocks. 
						,@strTransactionId -- This is only used when rebuilding the stocks. 
						,@intCategoryId
						,@dtmDate

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Invoice'
						GOTO _EXIT_WITH_ERROR
					END 
				END 
								
				DELETE	FROM #tmpICInventoryTransaction
				WHERE	strBatchId = @strBatchId						
						AND dbo.fnDateEquals(dtmDate, @dtmDate) = 1
			END	
			
			-- Repost 'Inventory Receipt/Return'
			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Inventory Receipt', 'Inventory Return')) 
			BEGIN 
				INSERT INTO @ItemsToPost (
						intItemId  
						,intItemLocationId 
						,intInTransitSourceLocationId
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
						,intCategoryId
						,dblUnitRetail
						,intCostingMethod
				)
				SELECT 	RebuildInvTrans.intItemId  
						,RebuildInvTrans.intItemLocationId 
						,RebuildInvTrans.intInTransitSourceLocationId 
						,RebuildInvTrans.intItemUOMId  
						,RebuildInvTrans.dtmDate  
						,RebuildInvTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
						,dblCost  = CASE 
										WHEN (RebuildInvTrans.dblQty > 0 AND Receipt.intInventoryReceiptId IS NOT NULL) THEN

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
																			,ISNULL(AggregrateItemLots.dblTotalNet, 1) 
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
											

										 ELSE 
											RebuildInvTrans.dblCost
									END 
						,RebuildInvTrans.dblSalesPrice  
						,RebuildInvTrans.intCurrencyId  
						,RebuildInvTrans.dblExchangeRate  
						,RebuildInvTrans.intTransactionId  
						,RebuildInvTrans.intTransactionDetailId  
						,RebuildInvTrans.strTransactionId  
						,RebuildInvTrans.intTransactionTypeId  
						,RebuildInvTrans.intLotId 
						,RebuildInvTrans.intSubLocationId
						,RebuildInvTrans.intStorageLocationId
						,RebuildInvTrans.strActualCostId
						,RebuildInvTrans.intForexRateTypeId
						,RebuildInvTrans.dblForexRate
						,intCategoryId = RebuildInvTrans.intCategoryId
						,dblUnitRetail = 
							dbo.fnCalculateReceiptUnitCost(
								ReceiptItem.intItemId
								,ReceiptItem.intUnitMeasureId		
								,ReceiptItem.intCostUOMId
								,ReceiptItem.intWeightUOMId
								,ReceiptItem.dblUnitRetail
								,ReceiptItem.dblNet
								,ReceiptItemLot.intLotId
								,ReceiptItemLot.intItemUnitMeasureId
								,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
								,NULL--DetailItem.ysnSubCurrency
								,NULL--Header.intSubCurrencyCents
							)
						,RebuildInvTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction RebuildInvTrans INNER JOIN tblICItemLocation ItemLocation 
							ON RebuildInvTrans.intItemLocationId = ItemLocation.intItemLocationId 
						LEFT JOIN dbo.tblICInventoryReceipt Receipt
							ON Receipt.intInventoryReceiptId = RebuildInvTrans.intTransactionId
							AND Receipt.strReceiptNumber = RebuildInvTrans.strTransactionId			
						LEFT JOIN (
							dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICItem i
								ON ReceiptItem.intItemId = i.intItemId
						)
							ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = RebuildInvTrans.intTransactionDetailId 
							
						LEFT JOIN dbo.tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							AND ReceiptItemLot.intLotId = RebuildInvTrans.intLotId 
						OUTER APPLY (
							SELECT  dblTotalNet = SUM(
										CASE	WHEN  ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
													ISNULL(dbo.fnCalculateQtyBetweenUOM(ril.intItemUnitMeasureId, ri.intWeightUOMId, ril.dblQuantity), 0) 
												ELSE 
													ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0)
										END 
									)
							FROM	tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceiptItemLot ril
										ON ri.intInventoryReceiptItemId = ril.intInventoryReceiptItemId
							WHERE	ri.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
						) AggregrateItemLots						
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuildInvTrans.intItemId = ItemUOM.intItemId
							AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = RebuildInvTrans.intLotId 
				WHERE	RebuildInvTrans.strBatchId = @strBatchId
						AND RebuildInvTrans.intTransactionId = @intTransactionId
						AND RebuildInvTrans.strTransactionId = @strTransactionId
						AND ItemLocation.intLocationId IS NOT NULL 
						AND ReceiptItem.intItemId = ISNULL(@intItemId, ReceiptItem.intItemId)
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)
				ORDER BY
					ReceiptItem.intInventoryReceiptItemId ASC 

				-- Get the Vendor Entity Id 
				SELECT	@intEntityId = intEntityVendorId
				FROM	tblICInventoryReceipt r
				WHERE	r.intInventoryReceiptId = @intTransactionId
						AND r.strReceiptNumber = @strTransactionId

				--IF @strTransactionType = 'Inventory Receipt'
				--BEGIN 
				--	EXEC @intReturnValue = dbo.uspICRepostCosting
				--		@strBatchId
				--		,@strAccountToCounterInventory
				--		,@intEntityUserSecurityId
				--		,@strGLDescription
				--		,@ItemsToPost
				--END 
				--ELSE IF @strTransactionType = 'Inventory Return'
				--BEGIN 
				--	DELETE	tblICInventoryReturned
				--	FROM	tblICInventoryReturned
				--	WHERE	strBatchId = @strBatchId

				--	UPDATE @ItemsToPost
				--	SET dblQty = -dblQty 

				--	EXEC @intReturnValue = dbo.uspICRepostReturnCosting
				--		@strBatchId
				--		,@strAccountToCounterInventory
				--		,@intEntityUserSecurityId
				--		,@strGLDescription
				--		,@ItemsToPost
				--END

				-- Get the receipt type 
				SET @strReceiptType = NULL 
				SET @intReceiptSourceType = NULL
				SET @strFobPoint = NULL 
				SELECT	TOP 1 
						@strReceiptType = strReceiptType
						,@intReceiptSourceType = intSourceType
						,@strFobPoint = ft.strFobPoint
				FROM	tblICInventoryReceipt r LEFT JOIN tblSMFreightTerms ft
							ON r.intFreightTermId = ft.intFreightTermId
				WHERE	strReceiptNumber = @strTransactionId 

				IF @strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
				BEGIN 
					-- Change the contra-account to In-Transit. 
					--SET @strAccountToCounterInventory = 'Inventory In-Transit'
					
					---- Re-Assign the Source Location Id. 
					--UPDATE	t
					--SET		t.intInTransitSourceLocationId = UDT.intInTransitSourceLocationId
					--FROM	tblICInventoryTransaction t INNER JOIN @ItemsToPost UDT
					--			ON t.intItemId = UDT.intItemId
					--			AND t.intItemLocationId = UDT.intItemLocationId
					--			AND t.intItemUOMId = UDT.intItemUOMId
					--			AND t.dblQty = UDT.dblQty
					--			AND t.intTransactionId = UDT.intTransactionId
					--			AND t.intTransactionDetailId = UDT.intTransactionDetailId
					--			AND t.strTransactionId = UDT.strTransactionId
					--WHERE	t.dblQty > 0 
					--		AND UDT.intInTransitSourceLocationId IS NOT NULL 

					SET @strAccountToCounterInventory = NULL 

					--INSERT INTO @ItemsForInTransitCosting (
					--		[intItemId] 
					--		,[intItemLocationId] 
					--		,[intItemUOMId] 
					--		,[dtmDate] 
					--		,[dblQty] 
					--		,[dblUOMQty] 
					--		,[dblCost] 
					--		,[dblValue] 
					--		,[dblSalesPrice] 
					--		,[intCurrencyId] 
					--		,[dblExchangeRate] 
					--		,[intTransactionId] 
					--		,[intTransactionDetailId] 
					--		,[strTransactionId] 
					--		,[intTransactionTypeId] 
					--		,[intLotId] 
					--		,[intSourceTransactionId] 
					--		,[strSourceTransactionId] 
					--		,[intSourceTransactionDetailId]
					--		,[intFobPointId]
					--		,[intInTransitSourceLocationId]
					--		,[intForexRateTypeId]
					--		,[dblForexRate]
					--)
					--SELECT
					--		t.[intItemId] 
					--		,t.[intItemLocationId] 
					--		,iu.intItemUOMId 
					--		,r.[dtmReceiptDate] 
					--		,dblQty = -ri.dblOpenReceive  
					--		,t.[dblUOMQty] 
					--		,t.[dblCost] 
					--		,t.[dblValue] 
					--		,t.[dblSalesPrice] 
					--		,t.[intCurrencyId] 
					--		,t.[dblExchangeRate] 
					--		,[intTransactionId] = r.intInventoryReceiptId 
					--		,[intTransactionDetailId] = ri.intInventoryReceiptItemId
					--		,[strTransactionId] = r.strReceiptNumber
					--		,[intTransactionTypeId] = @INVENTORY_RECEIPT_TYPE
					--		,t.[intLotId]
					--		,t.[intTransactionId] 
					--		,t.[strTransactionId] 
					--		,t.[intTransactionDetailId] 
					--		,t.[intFobPointId] 
					--		,[intInTransitSourceLocationId] = t.intInTransitSourceLocationId
					--		,[intForexRateTypeId] = t.intForexRateTypeId
					--		,[dblForexRate] = t.dblForexRate
					--FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					--			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					--		INNER JOIN (
					--			tblICInventoryTransferDetail td INNER JOIN tblICInventoryTransfer th
					--				ON td.intInventoryTransferId = th.intInventoryTransferId
					--		)
					--			ON 
					--				(
					--					td.intInventoryTransferDetailId = ri.intSourceId
					--					AND td.intInventoryTransferId = ri.intOrderId
					--					AND ri.intInventoryTransferDetailId IS NULL 
					--					AND ri.intInventoryTransferId IS NULL 
					--				)
					--				OR (
					--					td.intInventoryTransferDetailId = ri.intInventoryTransferDetailId
					--					AND td.intInventoryTransferId = ri.intInventoryTransferId
					--				)
					--		INNER JOIN tblICInventoryTransaction t 
					--			ON t.strTransactionId = th.strTransferNo
					--			AND t.intTransactionDetailId = td.intInventoryTransferDetailId
					--		LEFT JOIN tblICItemUOM iu 
					--			ON iu.intItemUOMId = ri.intUnitMeasureId
					--		LEFT JOIN tblICItem i 
					--			ON ri.intItemId = i.intItemId 
					--WHERE	r.strReceiptNumber = @strTransactionId
					--		AND t.ysnIsUnposted = 0 
					--		AND t.dblQty > 0
					--		AND i.strType <> 'Bundle'

					INSERT INTO @ItemsForInTransitCosting (
							[intItemId] 
							,[intItemLocationId] 
							,[intItemUOMId] 
							,[dtmDate] 
							,[dblQty] 
							,[dblUOMQty] 
							,[dblCost] 
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
							,[intInTransitSourceLocationId]
							,[intForexRateTypeId]
							,[dblForexRate]
					)
					SELECT 
							[intItemId]				= t.intItemId  
							,[intItemLocationId]	= t.intItemLocationId
							,[intItemUOMId]			= t.intItemUOMId
							,[dtmDate]				= tp.dtmDate 
							,[dblQty]				= dbo.fnCalculateQtyBetweenUOM(tp.intItemUOMId, t.intItemUOMId, -tp.dblQty)
							,[dblUOMQty]			= t.dblUOMQty
							,[dblCost]				= t.dblCost
							,[dblSalesPrice]		= tp.dblSalesPrice
							,[intCurrencyId]		= tp.intCurrencyId
							,[dblExchangeRate]		= tp.dblExchangeRate
							,[intTransactionId]		= tp.intTransactionId
							,[intTransactionDetailId]	= tp.intTransactionDetailId
							,[strTransactionId]			= tp.strTransactionId
							,[intTransactionTypeId]		= @INVENTORY_RECEIPT_TYPE
							,[intLotId]					= t.intLotId
							,[intSourceTransactionId]	= t.intInventoryTransferId
							,[strSourceTransactionId]	= t.strTransferNo
							,[intSourceTransactionDetailId] = ri.intInventoryTransferDetailId
							,[intInTransitSourceLocationId] = dbo.fnICGetItemLocation(t.intItemId, r.intTransferorId) -- t.intInTransitSourceLocationId
							,[intForexRateTypeId]			= tp.intForexRateTypeId
							,[dblForexRate]					= tp.dblForexRate
					FROM	@ItemsToPost tp INNER JOIN tblICItem i 
								ON tp.intItemId = i.intItemId
							INNER JOIN (
								tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
									ON r.intInventoryReceiptId = ri.intInventoryReceiptId
							)
								ON 
								r.intInventoryReceiptId = tp.intTransactionId
								AND r.strReceiptNumber = tp.strTransactionId			
								AND ri.intInventoryReceiptItemId = tp.intTransactionDetailId

							CROSS APPLY (
								SELECT TOP 1
									th.strTransferNo
									,th.intInventoryTransferId
									,td.intInventoryTransferDetailId
									,t.intLotId 
									,t.intItemId
									,t.intItemLocationId
									,t.intItemUOMId
									,t.dblUOMQty
									,t.dblCost 
								FROM 				
									tblICInventoryTransfer th INNER JOIN tblICInventoryTransferDetail td 
										ON th.intInventoryTransferId = td.intInventoryTransferId						
									INNER JOIN tblICInventoryTransaction t 
										ON t.strTransactionId = th.strTransferNo
										AND t.intTransactionDetailId = td.intInventoryTransferDetailId						
										AND t.intItemId = tp.intItemId 
										AND t.dblQty > 0 
								WHERE
									(
										td.intInventoryTransferDetailId = ri.intSourceId
										AND td.intInventoryTransferId = ri.intOrderId
										AND ri.intInventoryTransferDetailId IS NULL 
										AND ri.intInventoryTransferId IS NULL 
									)
									OR (
										td.intInventoryTransferDetailId = ri.intInventoryTransferDetailId
										AND td.intInventoryTransferId = ri.intInventoryTransferId
									)						
							) t																
					WHERE	i.strType <> 'Bundle' -- Do not include Bundle items in the in-transit costing. Bundle components are the ones included in the in-transit costing. 
					ORDER BY 
						ri.intInventoryReceiptItemId ASC

					IF EXISTS (SELECT TOP 1 1 FROM @ItemsForInTransitCosting)
					BEGIN 
						EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
							@ItemsForInTransitCosting
							,@strBatchId
							,NULL -- @strAccountToCounterInventory
							,@intEntityUserSecurityId
							,@strGLDescription

						IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

						SET @intReturnValue = NULL 
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
						EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
							@strBatchId
							,NULL 
							,@intEntityUserSecurityId
							,@strGLDescription
							,@intItemId
							,@strTransactionId
							,@intCategoryId

						IF @intReturnValue <> 0 
						BEGIN 
							--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Inventory Receipt - Transfer Order'
							GOTO _EXIT_WITH_ERROR
						END 
					END
				END											

				ELSE IF (
					@intReceiptSourceType = @RECEIPT_SOURCE_TYPE_InboundShipment
					AND @strFobPoint = 'Origin'
					AND EXISTS (SELECT TOP 1 1 FROM @ItemsToPost)
				)
				BEGIN 

					SET @strAccountToCounterInventory = 'Inventory In-Transit'

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
							,[intForexRateTypeId]
							,[dblForexRate]
					)
					SELECT
							t.[intItemId] 
							,t.[intItemLocationId] 
							,iu.intItemUOMId 
							,r.[dtmReceiptDate] 
							,dblQty = -ri.dblOpenReceive  
							,t.[dblUOMQty] 
							,t.[dblCost] 
							,t.[dblValue] 
							,t.[dblSalesPrice] 
							,t.[intCurrencyId] 
							,t.[dblExchangeRate] 
							,[intTransactionId] = r.intInventoryReceiptId 
							,[intTransactionDetailId] = ri.intInventoryReceiptItemId
							,[strTransactionId] = r.strReceiptNumber
							,[intTransactionTypeId] = @INVENTORY_RECEIPT_TYPE  
							,t.[intLotId]
							,t.[intTransactionId] 
							,t.[strTransactionId] 
							,t.[intTransactionDetailId] 
							,t.[intFobPointId] 
							,[intInTransitSourceLocationId] = t.intInTransitSourceLocationId
							,[intForexRateTypeId] = t.intForexRateTypeId
							,[dblForexRate] = t.dblForexRate
					FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
								ON r.intInventoryReceiptId = ri.intInventoryReceiptId
							INNER JOIN vyuLGLoadContainerLookup loadShipmentLookup
								ON loadShipmentLookup.intLoadDetailId = ri.intSourceId
								AND loadShipmentLookup.intLoadContainerId = ri.intContainerId 
							INNER JOIN tblICInventoryTransaction t 
								ON t.strTransactionId = loadShipmentLookup.strLoadNumber
								AND t.intTransactionDetailId = loadShipmentLookup.intLoadDetailId
							LEFT JOIN tblICItemLocation il 
								ON il.intLocationId = r.intLocationId
								AND il.intItemId = ri.intItemId 
							LEFT JOIN tblICItemUOM iu 
								ON iu.intItemUOMId = ri.intUnitMeasureId
							LEFT JOIN tblICItem i 
								ON ri.intItemId = i.intItemId 

					WHERE	r.strReceiptNumber = @strTransactionId
							AND t.ysnIsUnposted = 0 
							AND t.intFobPointId = @FOB_ORIGIN
							AND t.dblQty > 0
							AND i.strType <> 'Bundle'

					IF EXISTS (SELECT TOP 1 1 FROM @ItemsForInTransitCosting)
					BEGIN 
						EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
							@ItemsForInTransitCosting
							,@strBatchId
							,NULL -- @strAccountToCounterInventory
							,@intEntityUserSecurityId
							,@strGLDescription

						IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

						SET @intReturnValue = NULL 
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
						EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
							@strBatchId
							,'Inventory'  
							,@intEntityUserSecurityId
							,@strGLDescription
							,@intItemId
							,@strTransactionId
							,@intCategoryId

						IF @intReturnValue <> 0 
						BEGIN 
							--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Inventory Receipt - Inbound Shipment'
							GOTO _EXIT_WITH_ERROR
						END 
					END
				END

				IF @strTransactionType = 'Inventory Receipt' AND @strReceiptType <> @RECEIPT_TYPE_TRANSFER_ORDER
				BEGIN 
					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICRepostCosting - Inventory Receipt'
						GOTO _EXIT_WITH_ERROR
					END 	

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateReceiptGLEntries
						@strBatchId 
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId	
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks.
						,NULL -- This is only used when rebuilding the stocks.
						,@intCategoryId -- This is only used when rebuilding the stocks.

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateReceiptGLEntries'
						GOTO _EXIT_WITH_ERROR
					END

					---- Create the auto-variance when item was returned via IR. 
					--BEGIN 
					--	SET @intReturnValue = NULL 
					--	EXEC @intReturnValue = [uspICCreateReceiptGLEntriesForReturnVariance]
					--		@intTransactionId 
					--		,@strTransactionId
					--		,@strBatchId
					--		,@intEntityUserSecurityId

					--	IF @intReturnValue <> 0 
					--	BEGIN 
					--		--PRINT 'Error found in uspICRepostCosting - Inventory Receipt'
					--		GOTO _EXIT_WITH_ERROR
					--	END 	
					--END 
				END

				ELSE IF @strTransactionType = 'Inventory Receipt' AND @strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
				BEGIN 
					-- Get the cost from the in-transit
					UPDATE	owned
					SET		owned.dblCost = 
								CASE 
									WHEN owned_total.dblQty = 0 THEN owned.dblCost
									ELSE 
										dbo.fnDivide(t.dblValue, owned_total.dblQty)
								END 
					FROM	@ItemsToPost owned CROSS APPLY (
								SELECT 
									dblValue = SUM(-t.dblQty * t.dblCost + t.dblValue) 
								FROM 
									tblICInventoryTransaction t
								WHERE
									t.strTransactionId = owned.strTransactionId
									AND t.strBatchId = @strBatchId
									AND t.intTransactionId = owned.intTransactionId									
									AND t.intTransactionDetailId = owned.intTransactionDetailId
									AND t.intItemId = owned.intItemId								
									AND t.dblQty < 0 
							) t
							CROSS APPLY (
								SELECT 
									dblQty = SUM(owned_total.dblQty) 
								FROM
									@ItemsToPost owned_total
								WHERE
									owned_total.strTransactionId = owned.strTransactionId 
									AND owned_total.intItemId = owned.intItemId
									AND owned_total.intTransactionId = owned.intTransactionId
									AND owned_total.intTransactionDetailId = owned.intTransactionDetailId
							) owned_total
					WHERE 
						owned_total.dblQty <> 0 

					EXEC @intReturnValue = dbo.uspICRepostCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICRepostCosting - Transfer Order'
						GOTO _EXIT_WITH_ERROR
					END 	

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateGLEntries
						@strBatchId 
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks.
						,@strTransactionId -- This is only used when rebuilding the stocks.
						,@intCategoryId

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateGLEntries for Transfer Orders'
						GOTO _EXIT_WITH_ERROR
					END 
				END

				ELSE IF @strTransactionType = 'Inventory Return'
				BEGIN 
					DELETE	tblICInventoryReturned
					FROM	tblICInventoryReturned
					WHERE	strBatchId = @strBatchId

					UPDATE @ItemsToPost
					SET dblQty = -dblQty 

					EXEC @intReturnValue = dbo.uspICRepostReturnCosting
						@strBatchId
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,@ItemsToPost

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICRepostReturnCosting'
						GOTO _EXIT_WITH_ERROR
					END 

					SET @intReturnValue = NULL 
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
					EXEC @intReturnValue = dbo.uspICCreateReturnGLEntries
						@strBatchId 
						,@strAccountToCounterInventory
						,@intEntityUserSecurityId
						,@strGLDescription
						,NULL 
						,@intItemId -- This is only used when rebuilding the stocks.
						,@strTransactionId -- This is only used when rebuilding the stocks.
						--,@intCategoryId -- This is only used when rebuilding the stocks.

					IF @intReturnValue <> 0 
					BEGIN 
						--PRINT 'Error found in uspICCreateReturnGLEntries'
						GOTO _EXIT_WITH_ERROR
					END 				
				END
			END

			-- Repost 'Outbound Shipment'
			ELSE IF EXISTS (SELECT 1 WHERE @strTransactionType IN ('Outbound Shipment')) 
			BEGIN 
				SELECT	@strAccountToCounterInventory = NULL 

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
						,intCostingMethod
				)
				SELECT 	ICTrans.intItemId  
						,ICTrans.intItemLocationId 
						,ICTrans.intItemUOMId  
						,ICTrans.dtmDate  
						,ICTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, ICTrans.dblUOMQty) 
						,dblCost  = 
								dbo.fnCalculateCostBetweenUOM (
									StockUOM.intItemUOMId
									,ICTrans.intItemUOMId
									,ISNULL(lot.dblLastCost, itemPricing.dblLastCost) 
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
						,ICTrans.strActualCostId 
						,ICTrans.intForexRateTypeId
						,ICTrans.dblForexRate
						,ICTrans.intCostingMethod

				FROM	#tmpICInventoryTransaction ICTrans INNER JOIN tblICItemLocation ItemLocation 
							ON ICTrans.intItemLocationId = ItemLocation.intItemLocationId 
						INNER JOIN tblICItemUOM StockUOM
							ON StockUOM.intItemId = ICTrans.intItemId
							AND StockUOM.ysnStockUnit = 1
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON ICTrans.intItemId = ItemUOM.intItemId
							AND ICTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN tblICLot lot
							ON lot.intLotId = ICTrans.intLotId
						OUTER APPLY (
							SELECT TOP 1 dblLastCost 
							FROM 
								tblICItemPricing 
							WHERE 
								intItemId = ICTrans.intItemId 
								AND intItemLocationId = ICTrans.intItemLocationId
						) itemPricing
				WHERE	strBatchId = @strBatchId
						AND ICTrans.dblQty < 0 
						AND ItemLocation.intLocationId IS NOT NULL

				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

				SET @intReturnValue = NULL 
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
				EXEC @intReturnValue = dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL  
					,@intItemId -- This is only used when rebuilding the stocks. 
					,@strTransactionId 
					,@intCategoryId
					
				IF @intReturnValue <> 0 
				BEGIN 
					--PRINT 'Error found in uspICCreateGLEntries - Outbound Shipment'
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
						t.[intItemId] 
						,t.[intItemLocationId] 
						,t.[intItemUOMId] 
						,t.[dtmDate] 
						,-t.[dblQty] 
						,t.[dblUOMQty] 
						,t.[dblCost] 
						,t.[dblValue] 
						,t.[dblSalesPrice] 
						,t.[intCurrencyId] 
						,t.[dblExchangeRate] 
						,t.[intTransactionId] 
						,t.[intTransactionDetailId] 
						,t.[strTransactionId] 
						,t.[intTransactionTypeId] 
						,t.[intLotId] 
						,t.[intTransactionId] 
						,t.[strTransactionId] 
						,t.[intTransactionDetailId] 
						,[intFobPointId] = @intFobPointId
						,[intInTransitSourceLocationId] = t.intItemLocationId
				FROM	tblICInventoryTransaction t INNER JOIN tblICItem  i
							ON t.intItemId = i.intItemId 					
				WHERE	t.strTransactionId = @strTransactionId
						AND t.ysnIsUnposted = 0 
						AND t.strBatchId = @strBatchId
						AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 
						AND t.intItemId = ISNULL(@intItemId, t.intItemId)
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)

				EXEC @intReturnValue = dbo.uspICRepostInTransitCosting
					@ItemsForInTransitCosting
					,@strBatchId
					,NULL 
					,@intEntityUserSecurityId
					,@strGLDescription

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR

				SET @intReturnValue = NULL 
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
				EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
					@strBatchId
					,NULL 
					,@intEntityUserSecurityId
					,@strGLDescription
					,@intItemId
					,@strTransactionId
					,@intCategoryId

				IF @intReturnValue <> 0 
				BEGIN 
					--PRINT 'Error found in uspICCreateGLEntriesForInTransitCosting - Outbound Shipment'
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
						INNER JOIN tblICItem i
							ON i.intItemId = AdjDetail.intItemId 
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
							ON ItemPricing.intItemId = AdjDetail.intItemId
							AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
				WHERE	Adj.strAdjustmentNo = @strTransactionId
						AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0)

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
						,intCategoryId
						,dblUnitRetail
						,dblAdjustCostValue
						,dblAdjustRetailValue
						,intCostingMethod
				)
				SELECT 	RebuildInvTrans.intItemId  
						,RebuildInvTrans.intItemLocationId 
						,RebuildInvTrans.intItemUOMId  
						,RebuildInvTrans.dtmDate  
						,RebuildInvTrans.dblQty  
						,ISNULL(ItemUOM.dblUnitQty, RebuildInvTrans.dblUOMQty) 
						,dblCost  = CASE 
										WHEN RebuildInvTrans.dblQty < 0 THEN 
											CASE	
												WHEN Adj.intAdjustmentType = @AdjustmentTypeOpeningInventory THEN 
													ISNULL(AdjDetail.dblNewCost, RebuildInvTrans.dblCost) 
												WHEN dbo.fnGetCostingMethod(RebuildInvTrans.intItemId, RebuildInvTrans.intItemLocationId) = @AVERAGECOST THEN 
													dbo.fnGetItemAverageCost(
														RebuildInvTrans.intItemId
														, RebuildInvTrans.intItemLocationId
														, RebuildInvTrans.intItemUOMId
													) 
												ELSE
													COALESCE(
														dbo.fnCalculateCostBetweenUOM ( 
															COALESCE(StockUnit.intItemUOMId, ItemUOM.intItemUOMId)
															,ItemUOM.intItemUOMId
															,COALESCE(lot.dblLastCost, itemPricing.dblLastCost) 
														)
														,RebuildInvTrans.dblCost
													)
											END 
											
										WHEN (RebuildInvTrans.dblQty > 0 AND ISNULL(Adj.intInventoryAdjustmentId, 0) <> 0) THEN 
											CASE	WHEN Adj.intAdjustmentType = @AdjustmentTypeLotMerge THEN 
														RebuildInvTrans.dblCost
													ELSE 
														dbo.fnCalculateCostBetweenUOM( 
															COALESCE(AdjNewCostUOM.intItemUOMId, ItemUOM.intItemUOMId)
															,ItemUOM.intItemUOMId
															,COALESCE(AdjDetail.dblNewCost, AdjDetail.dblCost, RebuildInvTrans.dblCost) 
														)
											END
										 ELSE 
											RebuildInvTrans.dblCost
									END 
						,RebuildInvTrans.dblSalesPrice  
						,RebuildInvTrans.intCurrencyId  
						,RebuildInvTrans.dblExchangeRate  
						,RebuildInvTrans.intTransactionId  
						,RebuildInvTrans.intTransactionDetailId  
						,RebuildInvTrans.strTransactionId  
						,RebuildInvTrans.intTransactionTypeId  
						,RebuildInvTrans.intLotId 
						,RebuildInvTrans.intSubLocationId
						,RebuildInvTrans.intStorageLocationId
						,RebuildInvTrans.strActualCostId
						,RebuildInvTrans.intForexRateTypeId
						,RebuildInvTrans.dblForexRate
						,intCategoryId = RebuildInvTrans.intCategoryId 
						,dblUnitRetail = RebuildInvTrans.dblUnitRetail
						,dblAdjustCostValue = RebuildInvTrans.dblCategoryCostValue
						,dblAdjustRetailValue = RebuildInvTrans.dblCategoryRetailValue
						,RebuildInvTrans.intCostingMethod
				FROM	#tmpICInventoryTransaction RebuildInvTrans INNER JOIN tblICItemLocation ItemLocation 
							ON RebuildInvTrans.intItemLocationId = ItemLocation.intItemLocationId 
						LEFT JOIN dbo.tblICInventoryReceipt Receipt
							ON Receipt.intInventoryReceiptId = RebuildInvTrans.intTransactionId
							AND Receipt.strReceiptNumber = RebuildInvTrans.strTransactionId			
						LEFT JOIN (
							dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICItem i1
								ON i1.intItemId = ReceiptItem.intItemId
						)
							ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = RebuildInvTrans.intTransactionDetailId 
							AND ReceiptItem.intItemId = ISNULL(@intItemId, ReceiptItem.intItemId)
							AND ISNULL(i1.intCategoryId, 0) = COALESCE(@intCategoryId, i1.intCategoryId, 0)
						LEFT JOIN dbo.tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							AND ReceiptItemLot.intLotId = RebuildInvTrans.intLotId 
						LEFT JOIN dbo.tblICInventoryAdjustment Adj
							ON Adj.strAdjustmentNo = RebuildInvTrans.strTransactionId
							AND Adj.intInventoryAdjustmentId = RebuildInvTrans.intTransactionId
						LEFT JOIN (
							dbo.tblICInventoryAdjustmentDetail AdjDetail INNER JOIN tblICItem i2
								ON i2.intItemId = AdjDetail.intItemId 
						)
							ON AdjDetail.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
							AND AdjDetail.intInventoryAdjustmentDetailId = RebuildInvTrans.intTransactionDetailId 
							AND AdjDetail.intItemId = ISNULL(@intItemId, AdjDetail.intItemId)
							AND ISNULL(i2.intCategoryId, 0) = COALESCE(@intCategoryId, i2.intCategoryId, 0)
						LEFT JOIN dbo.tblICItemUOM AdjItemUOM
							ON AdjItemUOM.intItemId = AdjDetail.intItemId
							AND AdjItemUOM.intItemUOMId = ISNULL(AdjDetail.intItemUOMId, AdjDetail.intNewItemUOMId) 
						LEFT JOIN dbo.tblICItemUOM ItemUOM
							ON RebuildInvTrans.intItemId = ItemUOM.intItemId
							AND RebuildInvTrans.intItemUOMId = ItemUOM.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM AdjNewCostUOM
							ON AdjNewCostUOM.intItemId = AdjDetail.intItemId
							AND AdjNewCostUOM.intItemUOMId = ISNULL(AdjDetail.intNewItemUOMId, AdjDetail.intItemUOMId) 
						LEFT JOIN dbo.tblICItemUOM StockUnit
							ON StockUnit.intItemId = AdjDetail.intItemId
							AND ISNULL(StockUnit.ysnStockUnit, 0) = 1
						LEFT JOIN dbo.tblICLot lot
							ON lot.intLotId = RebuildInvTrans.intLotId 
						OUTER APPLY (
							SELECT TOP 1 
									dblLastCost 
							FROM	tblICItemPricing 
							WHERE	intItemId = RebuildInvTrans.intItemId 
									AND intItemLocationId = RebuildInvTrans.intItemLocationId
						) itemPricing
				WHERE	RebuildInvTrans.strBatchId = @strBatchId
						AND RebuildInvTrans.intTransactionId = @intTransactionId
						AND ItemLocation.intLocationId IS NOT NULL 

				EXEC @intReturnValue = dbo.uspICRepostCosting
					@strBatchId
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,@ItemsToPost
					,@strTransactionId

				IF @intReturnValue <> 0 GOTO _EXIT_WITH_ERROR
			END 

			-- Re-create the Post g/l entries (except for Cost Adjustments, Inventory Shipment, Invoice, Credit Memo, 'Inventory Transfer') AND Contra-Account is NOT NULL 
			IF EXISTS (
				SELECT	TOP 1 1 
				WHERE	@strTransactionType NOT IN (
							'Cost Adjustment'
							, 'Inventory Shipment'
							, 'Invoice'
							, 'Credit Memo'
							, 'Inventory Receipt'
							, 'Inventory Return'
							, 'Inventory Transfer'
							, 'Inventory Transfer with Shipment'
							, 'Outbound Shipment'
							, 'Inventory Adjustment - Opening Inventory'
						)
			) AND @strAccountToCounterInventory IS NOT NULL 
			BEGIN 
				SET @intReturnValue = NULL 
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
				EXEC @intReturnValue = dbo.uspICCreateGLEntries
					@strBatchId 
					,@strAccountToCounterInventory
					,@intEntityUserSecurityId
					,@strGLDescription
					,NULL 
					,@intItemId -- This is only used when rebuilding the stocks.
					,@strTransactionId -- This is only used when rebuilding the stocks.
					,@intCategoryId -- This is only used when rebuilding the stocks.

				IF @intReturnValue <> 0 
				BEGIN 
					--PRINT 'Error found in uspICCreateGLEntries'
					GOTO _EXIT_WITH_ERROR
				END 
			END 
				
			---- Fix discrepancies when posting Consume and Produce. 
			--IF ISNULL(@ysnPost, 1) = 1 
			--AND EXISTS (SELECT TOP 1 1 FROM @GLEntries WHERE strTransactionType = 'Consume' OR strTransactionType = 'Produce')
			--BEGIN 
			--	--PRINT 'Update decimal issue for Produce'

			--	UPDATE	@GLEntries 
			--	SET		dblDebit = (
			--				SELECT	SUM(ISNULL(dblCredit, 0)) 
			--				FROM	@GLEntries 
			--				WHERE	strTransactionType IN ('Consume', 'Inventory Auto Variance')
			--			) 
			--	WHERE	strTransactionType = 'Produce'
			--			AND dblDebit <> 0 
						
			--	UPDATE	@GLEntries 
			--	SET		dblCredit = (
			--				SELECT	SUM(ISNULL(dblDebit, 0)) 
			--				FROM	@GLEntries 
			--				WHERE	strTransactionType IN ('Consume', 'Inventory Auto Variance')
			--			) 
			--	WHERE	strTransactionType = 'Produce'
			--			AND dblCredit <> 0 
			--END 
		END 

		-- Book the G/L Entries (except for cost adjustment)
		IF EXISTS (
			SELECT	TOP 1 1 
			WHERE	@strTransactionType <> 'Cost Adjustment'
		) AND EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
		BEGIN 
			DECLARE @intReturnCode AS INT = 0;

			-- Set ysnRebuild = 1 to tell GL that the GL entries are from stock rebuild. 
			UPDATE	@GLEntries
			SET		ysnRebuild = 1

			-- Update the entity id
			UPDATE	@GLEntries
			SET		intEntityId = @intEntityId
			WHERE	intEntityId IS NULL 
					AND @intEntityId IS NOT NULL 

			EXEC @intReturnCode = dbo.uspGLBookEntries 
				@GLEntries
				, 1 
			
			IF ISNULL(@intReturnCode, 0) <> 0 
			BEGIN 
				-- 'Unable to repost. Item id: {Item No}. Transaction id: {Trans Id}. Batch id: {Batch Id}. Account Category: {Account Category}.'
				EXEC uspICRaiseError 80139, @strItemNo, @strTransactionId, @strBatchId, @strAccountToCounterInventory; 
				GOTO _EXIT_WITH_ERROR
			END 

			-- Clear the GL entries for next transaction to repost
			DELETE FROM @GLEntries
		END 
		
		DELETE	FROM #tmpICInventoryTransaction
		WHERE	strBatchId = @strBatchId
				AND strTransactionId = @strTransactionId 
	END 
END 

-- Rebuild the G/L Summary 
	EXEC uspGLRebuildSummary

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

GOTO _CLEAN_UP

_EXIT_WITH_ERROR: 
BEGIN 
	SET @intReturnValue = ISNULL(@intReturnValue, -1); 
	--IF @strTransactionId IS NOT NULL 
	--BEGIN 
	--	PRINT 'Failed in ' + @strTransactionId + '.'
	--END 

	GOTO _CLEAN_UP
END

_CLEAN_UP: 
-- Flag the rebuild as done. 
BEGIN 
	UPDATE	tblICBackup 
	SET		ysnRebuilding = 0
			,dtmEnd = GETDATE()
	WHERE intBackupId = @intBackupId
END

BEGIN 
	IF OBJECT_ID('tempdb..#tmpICInventoryTransaction') IS NOT NULL  
		DROP TABLE #tmpICInventoryTransaction

	IF OBJECT_ID('tempdb..#tmpUnOrderedICTransaction') IS NOT NULL  
		DROP TABLE #tmpUnOrderedICTransaction

	IF OBJECT_ID('tempdb..#tmpPriorityTransactions') IS NOT NULL  
		DROP TABLE #tmpPriorityTransactions

	IF OBJECT_ID('tempdb..#tmpAutoVarianceBatchesForAVGCosting') IS NOT NULL  
		DROP TABLE #tmpAutoVarianceBatchesForAVGCosting
END 

RETURN @intReturnValue; 