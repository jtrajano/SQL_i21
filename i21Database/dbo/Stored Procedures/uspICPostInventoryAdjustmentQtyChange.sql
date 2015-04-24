CREATE PROCEDURE uspICPostInventoryAdjustmentQtyChange  
	@intTransactionId INT = NULL   
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

/*
	Kinds of Qty change: 
	1. Qty only
	2. UOM only
	3. Weight only 
	4. Cost only
	5. Qty and UOM
	6. Qty and Weight
	7. Qty and Cost
	8. UOM and Weight 
	9. UOM and Cost
	10. Weight and Cost 

*/

DECLARE @INVENTORY_ADJUSTMENT_TYPE AS INT = 10
DECLARE @ItemsForQtyChange AS ItemCostingTableType

--------------------------------------------------------------------------------
-- Qty Only
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
			,intItemUOMId			= Detail.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= Detail.dblCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId  = @INVENTORY_ADJUSTMENT_TYPE
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intItemUOMId = ItemUOM.intItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) <> 0 
			AND Detail.intNewItemUOMId IS NULL 
			AND Detail.intNewWeightUOMId IS NULL 
			AND Detail.dblNewCost IS NULL 
END


-- Return the result back to uspICPostInventoryAdjustment for further processing. 
SELECT	intItemId			
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
FROM	@ItemsForQtyChange