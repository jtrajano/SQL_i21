CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentAvg]
	@dtmDate AS DATETIME
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@intItemUOMId AS INT	
	,@dblQty AS NUMERIC(38,20)
	,@intCostUOMId AS INT 
	,@dblNewCost AS NUMERIC(38,20)
	,@dblNewValue AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
	,@ysnPost AS BIT = 1 
	,@intOtherChargeItemId AS INT = NULL
	,@ysnUpdateItemCostAndPrice AS BIT = 0 
	,@IsEscalate AS BIT = 0 
	,@intSourceEntityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @costAdjustmentType AS TINYINT 
DECLARE @costAdjustmentType_DETAILED AS TINYINT = 1
		,@costAdjustmentType_SUMMARIZED AS TINYINT = 2
		,@costAdjustmentType_RETROACTIVE_DETAILED AS TINYINT = 3
		,@costAdjustmentType_RETROACTIVE_SUMMARIZED AS TINYINT = 4
		,@costAdjustmentType_CURRENT_AVG AS TINYINT = 5

DECLARE @intResult AS INT

SET @costAdjustmentType = dbo.fnICGetCostAdjustmentSetup(@intItemId, @intItemLocationId) 

IF @costAdjustmentType IN (@costAdjustmentType_RETROACTIVE_DETAILED, @costAdjustmentType_RETROACTIVE_SUMMARIZED)
BEGIN 
	EXEC @intResult = [uspICPostCostAdjustmentRetroactiveAvg] 
		@dtmDate
		,@intItemId
		,@intItemLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@intItemUOMId
		,@dblQty
		,@intCostUOMId
		,@dblNewCost
		,@dblNewValue
		,@intTransactionId
		,@intTransactionDetailId 
		,@strTransactionId
		,@intSourceTransactionId 
		,@intSourceTransactionDetailId 
		,@strSourceTransactionId 
		,@strBatchId 
		,@intTransactionTypeId 
		,@intEntityUserSecurityId 
		,@intRelatedInventoryTransactionId 
		,@strTransactionForm 
		,@intFobPointId 
		,@intInTransitSourceLocationId 
		,@ysnPost 
		,@intOtherChargeItemId 
		,@ysnUpdateItemCostAndPrice 
		,@IsEscalate 
		,@intSourceEntityId 
END 

IF @costAdjustmentType IN (@costAdjustmentType_CURRENT_AVG)
BEGIN 

	EXEC @intResult = [uspICPostCostAdjustmentCurrentAvg] 
		@dtmDate
		,@intItemId 
		,@intItemLocationId 
		,@intSubLocationId 
		,@intStorageLocationId 
		,@intItemUOMId 
		,@dblQty 
		,@intCostUOMId 
		,@dblNewCost 
		,@dblNewValue 
		,@intTransactionId 
		,@intTransactionDetailId 
		,@strTransactionId 
		,@intSourceTransactionId 
		,@intSourceTransactionDetailId 
		,@strSourceTransactionId 
		,@strBatchId 
		,@intTransactionTypeId 
		,@intEntityUserSecurityId 
		,@intRelatedInventoryTransactionId 
		,@strTransactionForm 
		,@intFobPointId 
		,@intInTransitSourceLocationId 
		,@ysnPost 
		,@intOtherChargeItemId 
		,@ysnUpdateItemCostAndPrice 
		,@IsEscalate 
		,@intSourceEntityId 
END

RETURN @intResult