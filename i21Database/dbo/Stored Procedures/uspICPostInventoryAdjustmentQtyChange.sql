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
	2. UOM only - TODO
	3. Weight only - TODO
	4. Cost only - TODO
	5. Qty and UOM - TODO
	6. Qty and Weight - TODO
	7. Qty and Cost - TODO
	8. UOM and Weight - TODO
	9. UOM and Cost - TODO
	10. Weight and Cost  - TODO

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
			,intItemUOMId			= -- Use weight UOM id if it is present. Otherwise, use the qty UOM. 
										CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) <> 0 THEN Detail.intWeightUOMId 
												ELSE Detail.intItemUOMId 
										END

			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					=	CASE	WHEN ISNULL(Detail.intLotId, 0) <> 0  THEN 
												-- When item is a Lot 
													CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) = 0  THEN 												
																-- Lot has no weight UOM. Do regular computation on the Qty. 
																ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
															ELSE
																-- The item has a weight UOM, convert the Qty to Weight.  																
																dbo.fnCalculateQtyBetweenUOM(
																	Detail.intItemUOMId, 
																	Detail.intWeightUOMId, 
																	ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
																)
													END 									
												ELSE	
													-- Else the item is just a regular item. Do regular computation on the Qty. 
													ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
										END 
			,dblUOMQty				=	CASE	WHEN ISNULL(Detail.intLotId, 0) <> 0  THEN 
													CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) = 0  THEN 																												
																ItemUOM.dblUnitQty
															ELSE
																WeightUOM.dblUnitQty
													END 									
												ELSE	
													ItemUOM.dblUnitQty
										END 
			,dblCost				=	ISNULL(Detail.dblNewCost, 
											Detail.dblCost
										)	
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
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON Detail.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) <> 0 
			AND Detail.intNewItemUOMId IS NULL 
			AND Detail.intNewWeightUOMId IS NULL 
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