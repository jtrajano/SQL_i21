
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

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

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
		,intFobPointId TINYINT 
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
			,@CostAdjLogInventoryTransactionId AS INT 
			,@CostAdjInventoryCostAdjustmentTypeId AS INT 
			,@FobPointId AS TINYINT 

			,@CostBucketCost AS NUMERIC(38,20)
			,@OriginalCost AS NUMERIC(38,20)
			,@NewTransactionValue AS NUMERIC(38,20)
			,@OriginalTransactionValue AS NUMERIC(38,20)
			,@dblNewCalculatedCost AS NUMERIC(38,20)
			,@CostBucketStockInQty AS NUMERIC(38,20)
			,@intLotId AS INT 
			,@CostAdjValue AS NUMERIC(38,20)
			,@intCostBucketLotOutId AS INT

			,@CostAdjQtyProxy AS NUMERIC(38, 20)			

	DECLARE loopLotCostBucket CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intTransactionId
			,strTransactionId
			,intFobPointId
			,CostAdjLog.dblQty
			,CostAdjLog.dblCost
			,CostAdjLog.intInventoryLotId
			,CostAdjLog.intId
			,CostAdjLog.intInventoryTransactionId
			,CostAdjLog.intInventoryCostAdjustmentTypeId
	FROM	#tmpInvCostAdjustmentToReverse InvReverse INNER JOIN dbo.tblICInventoryLotCostAdjustmentLog CostAdjLog
				ON InvReverse.intInventoryTransactionId = CostAdjLog.intInventoryTransactionId
	WHERE	CostAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost
			AND InvReverse.intCostingMethod IN (@LOTCOST)
			AND ysnIsUnposted = 0 

	OPEN loopLotCostBucket;

	-- Initial fetch attempt
	FETCH NEXT FROM loopLotCostBucket INTO 
			@CostBucketIntTransactionId
			,@CostBucketStrTransactionId 
			,@FobPointId
			,@CostAdjQty 
			,@CostAdjNewCost 
			,@CostBucketId 
			,@CostAdjLogId
			,@CostAdjLogInventoryTransactionId
			,@CostAdjInventoryCostAdjustmentTypeId
	;
	-----------------------
	-- Start of the loop
	-----------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @CostAdjQty = NULL		
		SET	@dblNewCalculatedCost = NULL 

		-- Get the total Adjust Qty to be unposted. 
		SELECT	@CostAdjQty = SUM(costAdjLog.dblQty) 
		FROM	tblICInventoryLotCostAdjustmentLog costAdjLog INNER JOIN tblICInventoryLot costBucket
					ON costAdjLog.intInventoryLotId = costBucket.intInventoryLotId
		WHERE	costAdjLog.ysnIsUnposted = 0 
				AND costAdjLog.intInventoryLotId = @CostBucketId
				AND costAdjLog.intInventoryTransactionId = @CostAdjLogInventoryTransactionId
				AND costAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost

		-- Update log(s) as unposted 
		UPDATE	tblICInventoryLotCostAdjustmentLog
		SET		ysnIsUnposted = 1
		FROM	tblICInventoryLotCostAdjustmentLog
		WHERE	intInventoryTransactionId = @CostAdjLogInventoryTransactionId
				--AND costAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost

		-- Recalculate the cost after the unpost. 
		SELECT	@dblNewCalculatedCost = dbo.fnDivide(totalCostAdjLog.value, costBucket.dblStockIn) 
		FROM	tblICInventoryLot costBucket
				CROSS APPLY (
					SELECT	value = SUM (
								dbo.fnMultiply(
									CASE	WHEN ISNULL(costAdjLog.dblQty, 0) = 0 THEN 
												x.dblStockIn 
											ELSE 
												costAdjLog.dblQty 
									END 
								
									,CASE	WHEN costAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost THEN 
												costAdjLog.dblCost										
											ELSE
												originalCost.dblCost - costAdjLog.dblCost
									END
								) 
							)
					FROM	tblICInventoryLotCostAdjustmentLog costAdjLog INNER JOIN tblICInventoryLot x
								ON costAdjLog.intInventoryLotId = x.intInventoryLotId
							OUTER APPLY (
								SELECT	TOP 1 
										dblCost
								FROM	tblICInventoryLotCostAdjustmentLog x
								WHERE	x.intInventoryLotId = costBucket.intInventoryLotId
										AND x.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
								ORDER	BY x.intId DESC 
							) originalCost 
					WHERE	costAdjLog.intInventoryLotId = costBucket.intInventoryLotId
							AND costAdjLog.ysnIsUnposted = 0 
				) totalCostAdjLog 
		WHERE	costBucket.intInventoryLotId = @CostBucketId

		-- If all cost adj logs are unposted, get the original cost. 
		SELECT	TOP 1 
				@dblNewCalculatedCost = dblCost
		FROM	tblICInventoryLotCostAdjustmentLog x
		WHERE	x.intInventoryLotId = @CostBucketId
				AND x.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
				AND @dblNewCalculatedCost IS NULL
		ORDER	BY x.intId DESC 
				
		-- Assign the recomputed cost to the cost bucket. 
		UPDATE	CostBucket
		SET		dblCost = @dblNewCalculatedCost
		FROM	tblICInventoryLot CostBucket
		WHERE	CostBucket.intInventoryLotId = @CostBucketId
				AND @dblNewCalculatedCost IS NOT NULL 

		-- Update the lot's last cost
		UPDATE	l
		SET		dblLastCost = @dblNewCalculatedCost
		FROM	tblICLot l
		WHERE	l.intLotId = @intLotId
				AND @dblNewCalculatedCost IS NOT NULL 
				AND ISNULL(@FobPointId, @FOB_ORIGIN) = @FOB_ORIGIN

		-- Update the Adjust Qty
		WHILE (ISNULL(@CostAdjQty, 0) > 0) 
		BEGIN 
			SET @intCostBucketLotOutId = NULL 

			UPDATE	costBucketOut
			SET		dblCostAdjustQty = CASE WHEN dblCostAdjustQty < @CostAdjQty THEN 0 ELSE dblCostAdjustQty - @CostAdjQty END 
					,@CostAdjQtyProxy = CASE WHEN dblCostAdjustQty < @CostAdjQty THEN @CostAdjQty - dblCostAdjustQty ELSE 0 END 
					,@intCostBucketLotOutId = costBucketOut.intId
			FROM	tblICInventoryLotOut costBucketOut 
					CROSS APPLY (
						SELECT	TOP 1 
								x.intId 
						FROM	tblICInventoryLotOut x 
						WHERE	x.intInventoryLotId = @CostBucketId
								AND ISNULL(x.dblCostAdjustQty, 0) > 0 
						ORDER BY x.intId DESC 					
					) lastCostBucketOut
			WHERE	costBucketOut.intId = lastCostBucketOut.intId 

			SET @CostAdjQty = @CostAdjQtyProxy

			-- Do this to avoid the endless loop. 
			IF @intCostBucketLotOutId IS NULL 
				SET @CostAdjQty = 0 
		END 
		
		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopLotCostBucket INTO 
			@CostBucketIntTransactionId
			,@CostBucketStrTransactionId 
			,@FobPointId
			,@CostAdjQty 
			,@CostAdjNewCost 
			,@CostBucketId
			,@CostAdjLogId
			,@CostAdjLogInventoryTransactionId
			,@CostAdjInventoryCostAdjustmentTypeId
		;
	END 

	CLOSE loopLotCostBucket;
	DEALLOCATE loopLotCostBucket;
END 

-----------------------
-- End of the loop
-----------------------
