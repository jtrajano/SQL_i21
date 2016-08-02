
/*
	This sp reverses the cost adjustment to the Lot cost bucket. 
*/
CREATE PROCEDURE [dbo].[uspICUnpostCostAdjustmentOnLot]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the cost types
DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
		,@COST_ADJ_TYPE_New_Cost AS INT = 2

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvCostAdjustmentToReverse')) 
BEGIN 
	CREATE TABLE #tmpInvCostAdjustmentToReverse (
		intInventoryTransactionId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intRelatedTransactionId INT NULL 
		,intTransactionTypeId INT NOT NULL 
		,intCostingMethod INT 
	)
END 

-------------------------------------------------
-- Update the cost buckets. Reverse the cost. 
-------------------------------------------------
BEGIN 
	DECLARE @CostBucketIntTransactionId AS INT
			,@CostBucketStrTransactionId AS NVARCHAR(50)
			,@CostAdjQty AS NUMERIC(38,20)
			,@CostAdjNewCost AS NUMERIC(38,20)
			,@CostBucketId AS INT 
			,@CostAdjLogId AS INT 

			,@CostBucketCost AS NUMERIC(38,20)
			,@OriginalCost AS NUMERIC(38,20)
			,@NewTransactionValue AS NUMERIC(38,20)
			,@OriginalTransactionValue AS NUMERIC(38,20)
			,@dblNewCalculatedCost AS NUMERIC(38,20)
			,@CostBucketStockInQty AS NUMERIC(38,20)
			,@intLotId AS INT 
			

	DECLARE loopLotCostBucket CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intTransactionId
			,strTransactionId
			,CostAdjLog.dblQty
			,CostAdjLog.dblCost
			,CostAdjLog.intInventoryLotId
			,CostAdjLog.intId
	FROM	#tmpInvCostAdjustmentToReverse InvReverse INNER JOIN dbo.tblICInventoryLotCostAdjustmentLog CostAdjLog
				ON InvReverse.intInventoryTransactionId = CostAdjLog.intInventoryTransactionId
	WHERE	CostAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost
			AND InvReverse.intCostingMethod IN (@LOTCOST)

	OPEN loopLotCostBucket;

	-- Initial fetch attempt
	FETCH NEXT FROM loopLotCostBucket INTO 
			@CostBucketIntTransactionId
			,@CostBucketStrTransactionId 
			,@CostAdjQty 
			,@CostAdjNewCost 
			,@CostBucketId 
			,@CostAdjLogId
	;
	-----------------------
	-- Start of the loop
	-----------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		-- Get the original cost
		SELECT TOP 1 
				@OriginalCost = dblCost				
		FROM	dbo.tblICInventoryLotCostAdjustmentLog
		WHERE	intInventoryLotId = @CostBucketId
				AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost

		-- Get the cost at cost bucket. 
		SELECT	@CostBucketCost = dblCost
				,@CostBucketStockInQty = dblStockIn
				,@intLotId = intLotId 
		FROM	dbo.tblICInventoryLot
		WHERE	intInventoryLotId = @CostBucketId

		-- Compute the new transaction value. 
		SELECT	@NewTransactionValue = @CostAdjQty * @CostAdjNewCost

		-- Compute the original transaction value. 
		SELECT	@OriginalTransactionValue = @CostAdjQty * @OriginalCost

		-- Compute the new cost. 
		SELECT @dblNewCalculatedCost =	@CostBucketCost 
										- ((@NewTransactionValue - @OriginalTransactionValue) / @CostBucketStockInQty)	

		-- Calculate the new cost
		UPDATE	CostBucket
		SET		dblCost = @dblNewCalculatedCost
		FROM	tblICInventoryLot CostBucket
		WHERE	CostBucket.intInventoryLotId = @CostBucketId

		-- Update the lot's last cost
		UPDATE	l
		SET		dblLastCost = @dblNewCalculatedCost
		FROM	tblICLot l
		WHERE	l.intLotId = @intLotId

		-- Mark the cost adjustment as unposted
		UPDATE dbo.tblICInventoryLotCostAdjustmentLog
		SET ysnIsUnposted = 1
		WHERE intId = @CostAdjLogId

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopLotCostBucket INTO 
			@CostBucketIntTransactionId
			,@CostBucketStrTransactionId 
			,@CostAdjQty 
			,@CostAdjNewCost 
			,@CostBucketId
			,@CostAdjLogId
		;
	END 

	CLOSE loopLotCostBucket;
	DEALLOCATE loopLotCostBucket;
END 

-----------------------
-- End of the loop
-----------------------
