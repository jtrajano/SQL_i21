﻿CREATE PROCEDURE uspICPostInventoryAdjustmentSplitLotChange  
	@intTransactionId INT = NULL
	,@strBatchId NVARCHAR(50)
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50)
	,@intUserId INT 
	,@strAdjustmentDescription AS NVARCHAR(255)
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @INVENTORY_ADJUSTMENT_QuantityChange AS INT = 10
		,@INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
		,@INVENTORY_ADJUSTMENT_ItemChange AS INT = 15
		,@INVENTORY_ADJUSTMENT_LotStatusChange AS INT = 16
		,@INVENTORY_ADJUSTMENT_SplitLot AS INT = 17
		,@INVENTORY_ADJUSTMENT_ExpiryDateChange AS INT = 18
		,@INVENTORY_ADJUSTMENT_LotMerge AS INT = 19
		,@INVENTORY_ADJUSTMENT_LotMove AS INT = 20

DECLARE @SplitLotSource AS ItemCostingTableType
		,@SplitLotTarget AS ItemCostingTableType

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------

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
		RAISERROR(80039, 11, 1, @strItemNo);
		GOTO Exit_With_Errors
	END

END

--------------------------------------------------------------------------------
-- Validate for non-negative Adjust Qty
-------------------------------------------------------------------------------
BEGIN 
	SELECT	TOP 1 
			@intItemId = Detail.intItemId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) > 0 
	
	IF @intItemId IS NOT NULL 
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem Item 
		WHERE intItemId = @intItemId		

		-- 'Split Lot requires a negative Adjust Qty on {Item} to split stocks from it.'
		RAISERROR(80057, 11, 1, @strItemNo);
		GOTO Exit_With_Errors
	END
END 

--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @SplitLotSource (
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
			,dblCost				= Detail.dblCost -- Cost saved in Adj is expected come from the cost bucket. 
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_SplitLot
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = Detail.intLotId
				AND Lot.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemUOMId = Detail.intWeightUOMId
				AND WeightUOM.intItemId = Detail.intItemId				
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) < 0 -- ensure it is reducing the stock. 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@SplitLotSource  
			,@strBatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intUserId
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
	INSERT INTO @SplitLotTarget (
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
			,intTransactionDetailId
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ISNULL(NewItemLocation.intItemLocationId, OriginalItemLocation.intItemLocationId) 

			,intItemUOMId			= 
									-- Try to use the Lot Weight UOM. 
									-- If not possible, use the new UOM Id or the source UOM Id. 
									ISNULL(
										NewLot.intWeightUOMId
										,ISNULL(NewItemUOM.intItemUOMId, FromStock.intItemUOMId)
									) 

			,dtmDate				= Header.dtmAdjustmentDate

			,dblQty					= 
									-- Try to convert the bag into Lot Weight
									-- If not possible, use the new split lot qty. 
									-- Or the source qty. 
									CASE	WHEN NewLot.intWeightUOMId IS NOT NULL THEN 
												ISNULL(Detail.dblNewSplitLotQuantity, -1 * FromStock.dblQty) 
												* NewLot.dblWeightPerQty
											ELSE 
												ISNULL(Detail.dblNewSplitLotQuantity, -1 * FromStock.dblQty) 
									END			

			,dblUOMQty				= ISNULL(
										LotWeightUOM.dblUnitQty 
										,ISNULL(NewItemUOM.dblUnitQty, FromStock.dblUOMQty)
									)

			,dblCost				=	
									-- Try to convert the cost to the cost per Lot Weight. 
									-- Otherwise, use the new cost or the source cost. 
									CASE	WHEN NewLot.intWeightUOMId IS NOT NULL THEN
												(	
													-1
													* FromStock.dblQty
													* ISNULL(Detail.dblNewCost, FromStock.dblCost) 
												)												
												/ 
												(
													ISNULL(Detail.dblNewSplitLotQuantity, -1 * FromStock.dblQty) 
													* NewLot.dblWeightPerQty 													
												)
											ELSE
												ISNULL(Detail.dblNewCost, FromStock.dblCost) 
									END 
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_SplitLot
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId			
			INNER JOIN dbo.tblICInventoryTransaction FromStock
				ON Detail.intInventoryAdjustmentDetailId = FromStock.intTransactionDetailId
				AND Detail.intInventoryAdjustmentId = FromStock.intTransactionId
				AND FromStock.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation OriginalItemLocation 
				ON OriginalItemLocation.intLocationId = Header.intLocationId 
				AND OriginalItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = FromStock.intLotId
			LEFT JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = Detail.intNewLocationId
				AND NewItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM OriginalItemUOM
				ON OriginalItemUOM.intItemUOMId = Detail.intItemUOMId
				AND OriginalItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemUOMId = Detail.intNewItemUOMId
				AND NewItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
				ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
			LEFT JOIN dbo.tblICLot NewLot
				ON NewLot.intLotId = Detail.intNewLotId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(FromStock.ysnIsUnposted, 0) = 0
			AND FromStock.strBatchId = @strBatchId

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@SplitLotTarget  
			,@strBatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intUserId
END

Exit_Successfully:
GOTO _Exit

Exit_With_Errors:
RETURN -1;

_Exit: 