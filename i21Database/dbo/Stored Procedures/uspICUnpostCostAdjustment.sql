
/*
	This is the stored procedure that handles the unposting of the cost adjustment. 
	
	Parameters: 
	@intTransactionId - The integer value that represents the id of the transaction. Ex: tblAPBill.intBillId. 
	
	@strTransactionId - The string value that represents the id of the transaction. Ex: tblAPBill.strBillId

	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intEntityUserSecurityId - The user who is initiating the unpost. 

	@AccountCategory_Cost_Adjustment - What contr-account GL account id to use when doing the unpost. 
*/
CREATE PROCEDURE [dbo].[uspICUnpostCostAdjustment]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@AccountCategory_Cost_Adjustment AS NVARCHAR(50) = 'AP Clearing' 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN 
	-- Create the variables for the internal transaction types used by costing. 
	DECLARE	@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26

	-- Declare the cost types
	DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
			,@COST_ADJ_TYPE_New_Cost AS INT = 2
			,@COST_ADJ_TYPE_Adjust_Value AS INT = 3
			,@COST_ADJ_TYPE_Adjust_Sold AS INT = 4
			,@COST_ADJ_TYPE_Adjust_WIP AS INT = 5
			,@COST_ADJ_TYPE_Adjust_InTransit AS INT = 6
			,@COST_ADJ_TYPE_Adjust_InTransit_Inventory AS INT = 7
			,@COST_ADJ_TYPE_Adjust_InTransit_Sold AS INT = 8
			,@COST_ADJ_TYPE_Adjust_InventoryAdjustment AS INT = 9
END

-- Validate 
IF NOT EXISTS (
	SELECT	TOP 1 1  
	FROM	tblICInventoryTransaction t 
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0 
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
)
BEGIN 
	RETURN; 
END 


-- Get the original cost adjustment value. 
BEGIN 
	DECLARE @ReverseCostAdjustment as ItemCostAdjustmentTableType
	INSERT INTO @ReverseCostAdjustment 
	(
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId]
			,[dtmDate] 
			,[dblNewValue]
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[intSourceTransactionDetailId] 
			,[strSourceTransactionId] 
	)
	SELECT 
			[intItemId]	= t.intItemId 
			,[intItemLocationId] = t.intItemLocationId
			,[intItemUOMId] = t.intItemUOMId 
			,[dtmDate] = t.dtmDate
			,[dblNewValue] = cbLog.dblValue
			,[intTransactionId] = t.intTransactionId
			,[intTransactionDetailId] = t.intTransactionDetailId
			,[strTransactionId] = t.strTransactionId
			,[intTransactionTypeId] = t.intTransactionTypeId
			,[intLotId] = t.intLotId
			,[intSubLocationId] = t.intSubLocationId 
			,[intStorageLocationId] = t.intStorageLocationId
			,[ysnIsStorage] = 0
			,[strActualCostId] = NULL 
			,[intSourceTransactionId] = cbLog.intRelatedTransactionId
			,[intSourceTransactionDetailId] = cbLog.intRelatedTransactionDetailId
			,[strSourceTransactionId] = cbLog.strRelatedTransactionId
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON t.intInventoryTransactionId = cbLog.intInventoryTransactionId
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0 
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND cbLog.intInventoryCostAdjustmentTypeId IN (@COST_ADJ_TYPE_Adjust_Value, @COST_ADJ_TYPE_New_Cost)
			AND cbLog.ysnIsUnposted = 0 
	UNION ALL 
	SELECT 
			[intItemId]	= t.intItemId 
			,[intItemLocationId] = t.intItemLocationId
			,[intItemUOMId] = t.intItemUOMId 
			,[dtmDate] = t.dtmDate
			,[dblNewValue] = cbLog.dblValue
			,[intTransactionId] = t.intTransactionId
			,[intTransactionDetailId] = t.intTransactionDetailId
			,[strTransactionId] = t.strTransactionId
			,[intTransactionTypeId] = t.intTransactionTypeId
			,[intLotId] = t.intLotId
			,[intSubLocationId] = t.intSubLocationId 
			,[intStorageLocationId] = t.intStorageLocationId
			,[ysnIsStorage] = 0
			,[strActualCostId] = NULL 
			,[intSourceTransactionId] = cbLog.intRelatedTransactionId
			,[intSourceTransactionDetailId] = cbLog.intRelatedTransactionDetailId
			,[strSourceTransactionId] = cbLog.strRelatedTransactionId
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON t.intInventoryTransactionId = cbLog.intInventoryTransactionId
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0 
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND cbLog.intInventoryCostAdjustmentTypeId IN (@COST_ADJ_TYPE_Adjust_Value, @COST_ADJ_TYPE_New_Cost)
			AND cbLog.ysnIsUnposted = 0 
	UNION ALL 
	SELECT 
			[intItemId]	= t.intItemId 
			,[intItemLocationId] = t.intItemLocationId
			,[intItemUOMId] = t.intItemUOMId 
			,[dtmDate] = t.dtmDate
			,[dblNewValue] = cbLog.dblValue
			,[intTransactionId] = t.intTransactionId
			,[intTransactionDetailId] = t.intTransactionDetailId
			,[strTransactionId] = t.strTransactionId
			,[intTransactionTypeId] = t.intTransactionTypeId
			,[intLotId] = t.intLotId
			,[intSubLocationId] = t.intSubLocationId 
			,[intStorageLocationId] = t.intStorageLocationId
			,[ysnIsStorage] = 0
			,[strActualCostId] = NULL 
			,[intSourceTransactionId] = cbLog.intRelatedTransactionId
			,[intSourceTransactionDetailId] = cbLog.intRelatedTransactionDetailId
			,[strSourceTransactionId] = cbLog.strRelatedTransactionId
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON t.intInventoryTransactionId = cbLog.intInventoryTransactionId
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0 
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND cbLog.intInventoryCostAdjustmentTypeId IN (@COST_ADJ_TYPE_Adjust_Value, @COST_ADJ_TYPE_New_Cost)
			AND cbLog.ysnIsUnposted = 0 
	UNION ALL 
	SELECT 
			[intItemId]	= t.intItemId 
			,[intItemLocationId] = t.intItemLocationId
			,[intItemUOMId] = t.intItemUOMId 
			,[dtmDate] = t.dtmDate
			,[dblNewValue] = cbLog.dblValue
			,[intTransactionId] = t.intTransactionId
			,[intTransactionDetailId] = t.intTransactionDetailId
			,[strTransactionId] = t.strTransactionId
			,[intTransactionTypeId] = t.intTransactionTypeId
			,[intLotId] = t.intLotId
			,[intSubLocationId] = t.intSubLocationId 
			,[intStorageLocationId] = t.intStorageLocationId
			,[ysnIsStorage] = 0
			,[strActualCostId] = NULL 
			,[intSourceTransactionId] = cbLog.intRelatedTransactionId
			,[intSourceTransactionDetailId] = cbLog.intRelatedTransactionDetailId
			,[strSourceTransactionId] = cbLog.strRelatedTransactionId
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON t.intInventoryTransactionId = cbLog.intInventoryTransactionId
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0 
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND cbLog.intInventoryCostAdjustmentTypeId IN (@COST_ADJ_TYPE_Adjust_Value, @COST_ADJ_TYPE_New_Cost)
			AND cbLog.ysnIsUnposted = 0 
END 

-- Reverse the cost adjustment by calling the same sp that posted it. 
IF EXISTS (SELECT TOP 1 1 FROM @ReverseCostAdjustment) 
BEGIN 
	-- Reverse the qty and value. 
	UPDATE @ReverseCostAdjustment
	SET dblNewValue = -dblNewValue

	EXEC uspICPostCostAdjustment 
		@ReverseCostAdjustment
		,@strBatchId
		,@intEntityUserSecurityId
		,0
END 

-- Update the flags
BEGIN 
	-------------------------------------------------------------------
	-- Update the ysnIsUnposted flag for the inventory transactions 
	-------------------------------------------------------------------
	UPDATE	t
	SET		ysnIsUnposted = 1
	FROM	tblICInventoryTransaction t
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0

	-------------------------------------------------------------------
	-- Update the ysnIsUnposted flag for the LOT transactions 
	-------------------------------------------------------------------
	UPDATE	t
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryLotTransaction t
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0

	-------------------------------------------------------------------
	-- Update the ysnIsUnposted flag in the GL Detail 
	-------------------------------------------------------------------
	UPDATE	gd
	SET		ysnIsUnposted = 1
	FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
				ON gd.intJournalLineNo = t.intInventoryTransactionId
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND gd.ysnIsUnposted = 0 
END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
	@strBatchId 
	,@intEntityUserSecurityId 
	,NULL 
	,0
	,@AccountCategory_Cost_Adjustment 
;