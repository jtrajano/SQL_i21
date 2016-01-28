﻿
/*
	This sp reverses the cost adjustment for the Actual Cost bucket. 
*/
CREATE PROCEDURE [dbo].[uspICUnpostCostAdjustmentOnActualCost]
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
			,@CostAdjQty AS NUMERIC(18,6)
			,@CostAdjNewCost AS NUMERIC(38,20)
			,@CostBucketId AS INT 
			,@CostAdjLogId AS INT 

			,@CostBucketCost AS NUMERIC(38,20)
			,@OriginalCost AS NUMERIC(38,20)
			,@NewTransactionValue AS NUMERIC(38,20)
			,@OriginalTransactionValue AS NUMERIC(38,20)
			,@dblNewCalculatedCost AS NUMERIC(38,20)
			,@CostBucketStockInQty AS NUMERIC(18,6)
				

	DECLARE loopActualCostBucket CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intTransactionId
			,strTransactionId
			,CostAdjLog.dblQty
			,CostAdjLog.dblCost
			,CostAdjLog.intInventoryActualCostId
			,CostAdjLog.intId
	FROM	#tmpInvCostAdjustmentToReverse InvReverse INNER JOIN dbo.tblICInventoryActualCostAdjustmentLog CostAdjLog
				ON InvReverse.intInventoryTransactionId = CostAdjLog.intInventoryTransactionId
	WHERE	CostAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost
			AND InvReverse.intCostingMethod IN (@ACTUALCOST)

	OPEN loopActualCostBucket;

	-- Initial fetch attempt
	FETCH NEXT FROM loopActualCostBucket INTO 
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
		FROM	dbo.tblICInventoryActualCostAdjustmentLog
		WHERE	intInventoryActualCostId = @CostBucketId
				AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost

		-- Get the cost at cost bucket. 
		SELECT	@CostBucketCost = dblCost
				,@CostBucketStockInQty = dblStockIn
		FROM	dbo.tblICInventoryActualCost
		WHERE	intInventoryActualCostId = @CostBucketId

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
		FROM	tblICInventoryActualCost CostBucket
		WHERE	CostBucket.intInventoryActualCostId = @CostBucketId
		
		-- Mark the cost adjustment as unposted
		UPDATE dbo.tblICInventoryActualCostAdjustmentLog
		SET ysnIsUnposted = 1
		WHERE intId = @CostAdjLogId

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopActualCostBucket INTO 
			@CostBucketIntTransactionId
			,@CostBucketStrTransactionId 
			,@CostAdjQty 
			,@CostAdjNewCost 
			,@CostBucketId
			,@CostAdjLogId
		;
	END 

	CLOSE loopActualCostBucket;
	DEALLOCATE loopActualCostBucket;
END 

-----------------------
-- End of the loop
-----------------------
