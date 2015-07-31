﻿CREATE PROCEDURE uspICPostInventoryAdjustmentQtyChange  
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
-- Validate the UOM
--------------------------------------------------------------------------------
DECLARE @intItemId AS INT 
DECLARE @strItemNo AS NVARCHAR(50)

BEGIN 
	SELECT TOP 1 
			@intItemId = Detail.intItemId			
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON Detail.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(WeightUOM.intItemUOMId, ItemUOM.intItemUOMId) IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem Item 
		WHERE intItemId = @intItemId		

		-- 'The UOM is missing on {Item}.'
		RAISERROR(51130, 11, 1, @strItemNo);
		GOTO _Exit
	END

END

--------------------------------------------------------------------------------
-- Validate the Adjust By Qty or New Quantity
-------------------------------------------------------------------------------
BEGIN 
	SELECT	TOP 1 
			@intItemId = Detail.intItemId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.dblQuantity, 0) = 0
			AND ISNULL(Detail.dblNewQuantity, 0) = 0
	
	IF @intItemId IS NOT NULL 
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem Item 
		WHERE intItemId = @intItemId		

		-- 'Please specify the Adjust By Quantity or New Quantity on {Item}.'
		RAISERROR(51131, 11, 1, @strItemNo);
		GOTO _Exit
	END
END 

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
			,intTransactionDetailId
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
			,dblCost				= CASE	WHEN ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) > 0 THEN 
												ISNULL(Detail.dblNewCost, Detail.dblCost)	
											ELSE 
												ISNULL(Detail.dblCost, 0)	
									  END 			
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId   = @INVENTORY_ADJUSTMENT_TYPE
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
		,intTransactionDetailId  
		,strTransactionId  
		,intTransactionTypeId  
		,intLotId 
		,intSubLocationId
		,intStorageLocationId
FROM	@ItemsForQtyChange

_Exit: