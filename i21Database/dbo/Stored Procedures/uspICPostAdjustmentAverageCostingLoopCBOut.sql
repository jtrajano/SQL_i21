/*
	
*/
CREATE PROCEDURE [dbo].[uspICPostAdjustmentAverageCostingLoopCBOut]
	@CostBucketId AS INT 
	,@AdjustCost AS NUMERIC(38, 20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE	@intId AS INT 
		,@intInventoryFIFOId AS INT 
		,@intInventoryTransactionId AS INT
		,@intRevalueFifoId AS INT
		,@dblQty AS NUMERIC(38, 20)
		,@dblCostAdjustQty AS NUMERIC(38, 20)

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopCostBucketOut CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,intInventoryFIFOId
		,intInventoryTransactionId
		,intRevalueFifoId
		,dblQty
		,dblCostAdjustQty
FROM	tblICInventoryFIFOOut cbOut
WHERE	cbOut.intInventoryFIFOId = @CostBucketId

OPEN loopCostBucketOut;

-- Initial fetch attempt
FETCH NEXT FROM loopCostBucketOut INTO 
	@intId 
	,@intInventoryFIFOId 
	,@intInventoryTransactionId 
	,@intRevalueFifoId 
	,@dblQty 
	,@dblCostAdjustQty 
;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop for sold/produced items. 
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0 
BEGIN 
	
	-- TODO: Business rules
	
	-- Get the next cbOut record. 
	FETCH NEXT FROM loopCostBucketOut INTO 
		@intId 
		,@intInventoryFIFOId 
		,@intInventoryTransactionId 
		,@intRevalueFifoId 
		,@dblQty 
		,@dblCostAdjustQty 
	;
END 

CLOSE loopCostBucketOut;
DEALLOCATE loopCostBucketOut;