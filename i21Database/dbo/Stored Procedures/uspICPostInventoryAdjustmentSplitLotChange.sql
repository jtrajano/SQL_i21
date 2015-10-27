﻿CREATE PROCEDURE uspICPostInventoryAdjustmentSplitLotChange  
	@intTransactionId INT = NULL
	,@strBatchId NVARCHAR(50)
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50)
	,@intEntityUserSecurityId INT 
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

DECLARE @MergeLotSource AS ItemCostingTableType
		,@MergeToTargetLot AS ItemCostingTableType

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
		RETURN -1
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

		-- 'Split Lot requires a negative Adjust Qty on %s to split stocks from it.'
		RAISERROR(80057, 11, 1, @strItemNo);
		RETURN -1
	END
END 


--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeLotSource (
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
			,dblCost				= Detail.dblCost --* ItemUOM.dblUnitQty-- Cost saved in Adj is expected come from the cost bucket. 
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
			@MergeLotSource  
			,@strBatchId  
			,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intEntityUserSecurityId
END

--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot 
			@intTransactionId
			,@intEntityUserSecurityId

	IF @intCreateUpdateLotError <> 0 RETURN -1
	
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON MERGE
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeToTargetLot (
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
			,intItemLocationId		= ISNULL(NewLotItemLocation.intItemLocationId, SourceLotItemLocation.intItemLocationId) 

			,intItemUOMId			= 
									-- Try to use the new-lot's weight UOM id. 
									-- Otherwise, use the new-lot's item uom id. 
									CASE	WHEN NewLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId IS NOT NULL THEN 
												NewLot.intWeightUOMId
											ELSE 
												NewLot.intItemUOMId												
									END 

			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					=		
											-- Try to use the Weight UOM Qty. 
									CASE	WHEN SourceLot.intWeightUOMId IS NOT NULL AND NewLot.intWeightUOMId IS NOT NULL THEN -- There is a new weight UOM Id. 
												ISNULL(
													Detail.dblNewWeight
													,CASE	-- New Lot has the same weight UOM Id. 	
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN															
																-1 * FromStock.dblQty
														
															-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
																ISNULL(Detail.dblNewSplitLotQuantity, -1 * FromStock.dblQty) 
																* NewLot.dblWeightPerQty

															--New Lot has a different weight UOM Id. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, (-1 * FromStock.dblQty)
																)
															--New Lot has a different weight UOM Id but source lot was reduced by bags. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, (-1 * FromStock.dblQty * SourceLot.dblWeightPerQty)
																)
													END 
												)
											-- Else, use the Item UOM Qty
											ELSE 
												ISNULL(
													Detail.dblNewSplitLotQuantity 
													,CASE	WHEN SourceLot.intWeightUOMId = FromStock.intItemUOMId AND ISNULL(SourceLot.dblWeightPerQty, 0) <> 0 THEN 
																-- From stock is in source-lot's weight UOM Id. 
																-- Convert it to source-lot's item UOM Id. 
																-- and then convert it to the new-lot's item UOM Id. 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, (-1 * FromStock.dblQty / SourceLot.dblWeightPerQty)
																)
															ELSE 
																-- 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, (-1 * FromStock.dblQty)
																)
													END 
												) 
									END
			,dblUOMQty				=	
										CASE	WHEN NewLot.intWeightUOMId IS NOT NULL AND SourceLot.intWeightUOMId IS NOT NULL THEN 
													NewLotWeightUOM.dblUnitQty
												ELSE 
													NewLotItemUOM.dblUnitQty
										END 
			,dblCost				=	
											-- Try to get the cost in terms of Weight UOM. 
									CASE	WHEN SourceLot.intWeightUOMId IS NOT NULL AND NewLot.intWeightUOMId IS NOT NULL THEN -- There is a new weight UOM Id. 
												CASE	-- New Lot has the same weight UOM Id. 	
														WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN															
																	-- Compute a new cost if there is a new weight. 
															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
																		-1 
																		* FromStock.dblQty 
																		* ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																				StockUnit.intItemUOMId
																				, SourceLotItemUOM.intWeightUOMId
																				, Detail.dblNewCost / SourceLotItemUOM.dblUnitQty
																			)	
																			-- otherwise, use the cost coming from the cost bucket. 
																			, FromStock.dblCost
																		)	
																		/ Detail.dblNewWeight
																	ELSE 
																		ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																				StockUnit.intItemUOMId
																				, SourceLotItemUOM.intWeightUOMId
																				, Detail.dblNewCost / SourceLotItemUOM.dblUnitQty
																			)	
																			-- otherwise, use the cost coming from the cost bucket. 
																			, FromStock.dblCost
																		)
															END 
														
														-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
														WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
															-- Convert the cost in terms of weight UOM. 

																	-- Compute a new cost if there is a new weight. 
															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
																		-1 
																		-- Convert the pack to weight. 
																		* FromStock.dblQty 																		
																		* ISNULL(Detail.dblNewCost, FromStock.dblCost)
																		/ Detail.dblNewWeight
																	ELSE
																		-- Get the value of the stock
																		-1 
																		* FromStock.dblQty
																		* ISNULL(Detail.dblNewCost, FromStock.dblCost)
																		-- divide it by the new-lot's weight qty. 
																		/ dbo.fnCalculateQtyBetweenUOM (
																				SourceLotWeightUOM.intItemUOMId
																				, NewLotWeightUOM.intItemUOMId
																				, (-1 * FromStock.dblQty * SourceLot.dblWeightPerQty)
																		)
															END															

														--New Lot has a different weight UOM Id. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
														-- Convert the source weight into the new lot weight. 

																	-- Compute a new cost if there is new weight. 
															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
																		
																		-1 
																		* FromStock.dblQty
																		* ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																					StockUnit.intItemUOMId
																					, SourceLot.intWeightUOMId
																					, Detail.dblNewCost / SourceLotItemUOM.dblUnitQty
																			)	
																			-- otherwise, use the cost coming from the cost bucket. 
																			, FromStock.dblCost
																		)
																		/ Detail.dblNewWeight

																	ELSE 
																		-1 
																		* FromStock.dblQty
																		* ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																					StockUnit.intItemUOMId
																					, SourceLot.intWeightUOMId
																					, Detail.dblNewCost / SourceLotItemUOM.dblUnitQty
																			)	
																			-- otherwise, use the cost coming from the cost bucket. 
																			, FromStock.dblCost
																		)																			 
																		/ dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, (-1 * FromStock.dblQty)
																		)
															END
															
														--New Lot has a different weight UOM Id but source lot was reduced by bags. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 

															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 
																		
																		-1 
																		* FromStock.dblQty
																		* ISNULL(Detail.dblNewCost, FromStock.dblCost)
																		/ Detail.dblNewWeight

																	ELSE 
																		-1 
																		* FromStock.dblQty
																		* ISNULL(Detail.dblNewCost, FromStock.dblCost)																			 
																		/ dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, (-1 * FromStock.dblQty * SourceLot.dblWeightPerQty)
																		)
															END
												END 
											-- Else, use the cost in termns of Item UOM. 
											ELSE 
												ISNULL(
													Detail.dblNewCost
													,CASE	WHEN SourceLot.intWeightUOMId = FromStock.intItemUOMId AND ISNULL(SourceLot.dblWeightPerQty, 0) <> 0 THEN 
																-- From-stock is in source-lot's weight UOM Id. 
																-- Convert it to source-lot's item UOM Id. 
																-- and then convert it to the new-lot's item UOM Id. 
																(	
																	-1 
																	* FromStock.dblQty
																	* ISNULL((Detail.dblNewCost / NewLotItemUOM.dblUnitQty), FromStock.dblCost) 																
																)
																/ dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, (-1 * FromStock.dblQty / SourceLot.dblWeightPerQty)
																)
															ELSE 
																(
																	-1 
																	* FromStock.dblQty
																	* ISNULL(Detail.dblNewCost, FromStock.dblCost) 																
																)																
																/ dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, (-1 * FromStock.dblQty)
																)
													END 
												) 
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
			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = FromStock.intLotId
			INNER JOIN dbo.tblICItemLocation SourceLotItemLocation 
				ON SourceLotItemLocation.intLocationId = Header.intLocationId 
				AND SourceLotItemLocation.intItemId = SourceLot.intItemId

			LEFT JOIN dbo.tblICItemUOM SourceLotItemUOM
				ON SourceLotItemUOM.intItemUOMId = SourceLot.intItemUOMId
				AND SourceLotItemUOM.intItemId = SourceLot.intItemId
			LEFT JOIN dbo.tblICItemUOM SourceLotWeightUOM 
				ON SourceLotWeightUOM.intItemUOMId = SourceLot.intWeightUOMId
				AND SourceLotWeightUOM.intItemId = SourceLot.intItemId

			LEFT JOIN dbo.tblICLot NewLot
				ON NewLot.intLotId = Detail.intNewLotId
			LEFT JOIN dbo.tblICItemLocation NewLotItemLocation 
				ON NewLotItemLocation.intLocationId = Detail.intNewLocationId
				AND NewLotItemLocation.intItemId = NewLot.intItemId
			LEFT JOIN dbo.tblICItemUOM NewLotItemUOM
				ON NewLotItemUOM.intItemUOMId = NewLot.intItemUOMId
				AND NewLotItemUOM.intItemId = NewLot.intItemId
			LEFT JOIN dbo.tblICItemUOM NewLotWeightUOM
				ON NewLotWeightUOM.intItemUOMId = NewLot.intWeightUOMId
				AND NewLotWeightUOM.intItemId = NewLot.intItemId

			LEFT JOIN dbo.tblICItemUOM StockUnit 
				ON StockUnit.intItemId = Detail.intItemId
				AND StockUnit.ysnStockUnit = 1

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(FromStock.ysnIsUnposted, 0) = 0
			AND FromStock.strBatchId = @strBatchId
			AND NewLot.intLotId IS NOT NULL 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@MergeToTargetLot  
			,@strBatchId  
			,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intEntityUserSecurityId
END