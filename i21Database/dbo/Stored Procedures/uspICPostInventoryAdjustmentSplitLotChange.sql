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
			,intItemUOMId			=	-- Use weight UOM id if it is present. Otherwise, use the qty UOM. 
										CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) <> 0 THEN Detail.intWeightUOMId 
												ELSE Detail.intItemUOMId 
										END
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					=	-- If using Weight UOM, convert the qty from Item UOM to Weight UOM. 
										-- Otherwise, use the same value (New Quantity - Original Quantity). 
										CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) <> 0  THEN
													dbo.fnCalculateQtyBetweenUOM(
														Detail.intItemUOMId,
														Detail.intWeightUOMId, 
														ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
													)
												ELSE 
													ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)
										END 
			,dblUOMQty				=	-- If using Weight UOM, use the Unit Qty from the Weight UOM. 
										-- Otherwise, use the unit qty from the Item UOM. 
										CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) <> 0  THEN
													WeightUOM.dblUnitQty
												ELSE 
													ItemUOM.dblUnitQty
										END 				
			,dblCost				=	-- If using Weight UOM, use the same cost. This is the cost from the Lot costing bucket. 
										-- Otherwise, adjustment needs to calculate the cost by the Item UOM > Unit Qty. 
										CASE	WHEN ISNULL(Detail.intWeightUOMId, 0) <> 0  THEN
													Detail.dblCost
												ELSE 
													Detail.dblCost * ItemUOM.dblUnitQty
										END
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
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemUOMId = Detail.intWeightUOMId
				AND WeightUOM.intItemId = Detail.intItemId				
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
			,intItemUOMId			=	-- If there is a weight UOM, try to use the new weight UOM.
										-- Otherwise, try to use the new item UOM. 		
										CASE	WHEN Detail.intWeightUOMId IS NOT NULL THEN 
													ISNULL(Detail.intNewWeightUOMId, Detail.intWeightUOMId)
												ELSE 
													ISNULL(Detail.intNewItemUOMId, Detail.intItemUOMId) 
										END

			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= CASE	WHEN Detail.intWeightUOMId IS NOT NULL THEN 
													CASE	
															WHEN Detail.dblNewWeight IS NOT NULL THEN 
																-- Use the new net weight. 
																ISNULL(Detail.dblNewWeight, 0) 
															ELSE 
																-- If there is no new weight, calculate as: {Weight per Qty} x {Adjust by Qty}. 
																-- And then the result is converted into the new weight UOM. 
																dbo.fnCalculateQtyBetweenUOM(
																	Detail.intWeightUOMId,
																	ISNULL(Detail.intNewWeightUOMId, Detail.intWeightUOMId), 
																	ABS(ISNULL(Detail.dblWeightPerQty, 0) * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)))
																)
													END 													
												WHEN Detail.dblNewSplitLotQuantity IS NOT NULL THEN 
													Detail.dblNewSplitLotQuantity
												ELSE 
													-1 * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
										END 

			,dblUOMQty				=	-- If there is a weight UOM, try to use the new weight UOM > unit qty. 
										-- Otherwise, try to use the new item UOM > unit qty. 
										CASE	WHEN Detail.intWeightUOMId IS NOT NULL THEN 
													ISNULL(NewWeightUOM.dblUnitQty, WeightUOM.dblUnitQty)
												ELSE 
													ISNULL(NewItemUOM.dblUnitQty, ItemUOM.dblUnitQty)
										END

			,dblCost				=	
										CASE	
												WHEN Detail.intWeightUOMId IS NOT NULL THEN 
													-- If Weight is used, use the Cost per Weight. Otherwise, use the cost per qty. 
													dbo.fnCalculateCostPerWeight (
														-- 1 of 2. Calculate the overall item value according to the (new or original) cost and original net weight. 
														ISNULL(Detail.dblNewCost, Detail.dblCost) 
														* ABS(ISNULL(Detail.dblWeightPerQty, 0) * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)))

														-- 2 of 2. Determine the weight to use (either new or original). 
														,ISNULL(
															Detail.dblNewWeight, 
															dbo.fnCalculateQtyBetweenUOM(
																Detail.intWeightUOMId,
																ISNULL(Detail.intNewWeightUOMId, Detail.intWeightUOMId), 
																ABS(ISNULL(Detail.dblWeightPerQty, 0) * (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)))
															)													
														) 
													) 
										
												WHEN Detail.dblNewSplitLotQuantity IS NOT NULL THEN 
													-- Distribute the value over the new split lot qty. 
													CASE	WHEN Detail.dblNewSplitLotQuantity = 0 THEN 
																ISNULL(Detail.dblNewCost, Detail.dblCost)
															WHEN Detail.intWeightUOMId IS NOT NULL THEN 
																-- If there is weight uom, 
																ABS (
																	ISNULL(Detail.dblNewCost, Detail.dblCost) 
																	* ABS(ISNULL(Detail.dblWeightPerQty, 0) 
																	* (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)))
																	/ Detail.dblNewSplitLotQuantity																
																)
																
															ELSE 
																ISNULL(Detail.dblNewCost, Detail.dblCost)
																* (ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0))
																/ Detail.dblNewSplitLotQuantity
													END
												ELSE 
													-- Otherwise, recalculate the (new or original) cost to the (new or original) Item UOM unit qty. 
													ISNULL(Detail.dblNewCost, Detail.dblCost)
													* ISNULL(NewItemUOM.dblUnitQty, ItemUOM.dblUnitQty)
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
				ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemUOMId = Detail.intNewItemUOMId
				AND NewItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemUOMId = Detail.intWeightUOMId
				AND WeightUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM NewWeightUOM
				ON NewWeightUOM.intItemUOMId = Detail.intNewWeightUOMId
				AND NewWeightUOM.intItemId = Detail.intItemId
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