CREATE PROCEDURE uspICPostInventoryAdjustmentSplitLotChange  
	@intTransactionId INT = NULL
	,@intUserId INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @INVENTORY_ADJUSTMENT_TYPE AS INT = 10
DECLARE @ItemsForQtyChange AS ItemCostingTableType

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------

-- TODO: Validate for non-negative split Qty. 

--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @ItemsForQtyChange (
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
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= ItemUOM.intItemUOMId 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= Detail.dblCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_TYPE
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemUOM.intItemId = Detail.intItemId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) <> 0 
END

--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot 
			@intTransactionId
			,@intUserId

	IF @intCreateUpdateLotError <> 0
	BEGIN 
		GOTO Exit_With_Errors;
	END
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON THE SPLIT LOT NUMBER 
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @ItemsForQtyChange (
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
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
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= ItemUOM.intItemUOMId 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= 
										CASE	WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) = 0 THEN Detail.dblAdjustByQuantity * -1
												ELSE Detail.dblNewSplitLotQuantity
										END			
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= 
										CASE	WHEN ISNULL(Detail.dblNewSplitLotQuantity, 0) = 0 THEN 
													CASE	WHEN ISNULL(Detail.dblNewCost, 0) = 0 THEN Detail.dblCost
															ELSE Detail.dblNewCost
													END 
												ELSE 
													CASE	WHEN ISNULL(Detail.dblNewCost, 0) = 0 THEN	
																-- Redistribute the cost from the qty to adjust to the Qty of the Split lot. 
																ABS(Detail.dblCost * Detail.dblAdjustByQuantity / Detail.dblNewSplitLotQuantity)		
															ELSE
																-- The user manually computed the new cost for the split lot.  
																Detail.dblNewCost
													END 													
										END 
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_TYPE
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId)
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) <> 0 
END

-- Return the result back to uspICPostInventoryAdjustment for further processing. 
SELECT	intItemId			
		,intItemLocationId	
		,intItemUOMId		
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
		,intTransactionTypeId  
		,intLotId 
		,intSubLocationId
		,intStorageLocationId
FROM	@ItemsForQtyChange


Exit_Successfully:
GOTO _Exit

Exit_With_Errors:
RETURN -1;

_Exit: 