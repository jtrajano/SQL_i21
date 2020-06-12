CREATE PROCEDURE uspICPostInventoryAdjustmentSplitLotChange  
	@intTransactionId INT = NULL
	,@strBatchId NVARCHAR(40)
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

DECLARE @OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2

DECLARE @MergeLotSource AS ItemCostingTableType
		,@MergeLotSourceStorage AS ItemCostingTableType
		,@MergeToTargetLot AS ItemCostingTableType
		,@MergeToTargetLotStorage AS ItemCostingTableType

-- Create the temp table to skip a batch id from logging into the summary log. 
IF OBJECT_ID('tempdb..#tmpICLogRiskPositionFromOnHandSkipList') IS NULL  
BEGIN 
	CREATE TABLE #tmpICLogRiskPositionFromOnHandSkipList (
		strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	)
END 

-- insert into the temp table
BEGIN 
	INSERT INTO #tmpICLogRiskPositionFromOnHandSkipList (strBatchId) VALUES (@strBatchId) 
END 

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------
BEGIN 
	--------------------------------------------------------------------------------
	-- Validate the UOM
	--------------------------------------------------------------------------------
	DECLARE @intItemId AS INT 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @strLotNumber AS NVARCHAR(50)
	DECLARE @intLotId AS INT 

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
			EXEC uspICRaiseError 80039, @strItemNo;
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
			EXEC uspICRaiseError 80057, @strItemNo;
			RETURN -1
		END
	END 

	---------------------------------------------------------------------------------------------------
	-- Validate for Split Lot to the same lot number, location, sub location, and storage location. 
	---------------------------------------------------------------------------------------------------
	BEGIN 
		SELECT	TOP 1 
				@strLotNumber = Lot.strLotNumber
				,@intLotId = Lot.intLotId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICLot Lot
					ON Lot.intLotId = Detail.intLotId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND Lot.strLotNumber = ISNULL(Detail.strNewLotNumber, Lot.strLotNumber) 
				AND Header.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)
				AND Detail.intSubLocationId = ISNULL(Detail.intNewSubLocationId, Detail.intSubLocationId)
				AND Detail.intStorageLocationId = ISNULL(Detail.intNewStorageLocationId, Detail.intStorageLocationId)
	
		IF @intLotId IS NOT NULL 
		BEGIN
			-- 'Split Lot for %s is not allowed because it will be a split to the same lot number, location, sub location, and storage location.'
			EXEC uspICRaiseError 80073, @strLotNumber;
			RETURN -1
		END
	END 

	---------------------------------------------------------
	-- Validate if the new item location is valid
	---------------------------------------------------------
	BEGIN 
		SET @intItemId = NULL 
		SET @strItemNo = NULL 

		SELECT	TOP 1 
				@intItemId = Item.intItemId
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Detail.intItemId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = Item.intItemId
					AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId) 
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND ItemLocation.intItemLocationId IS NULL 
				
		IF @intItemId IS NOT NULL 
		BEGIN
			-- --'The new Item Location is invalid or missing for %s.'
			EXEC uspICRaiseError 80083, @strItemNo;  
			RETURN -1
		END		
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
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intItemId)
										,Detail.intItemUOMId
										,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
									)
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
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) < 0 -- ensure it is reducing the stock. 
			AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Own -- process only company-owned stocks 
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS (SELECT TOP 1 1 FROM @MergeLotSource)
	BEGIN
		EXEC	dbo.uspICPostCosting  
				@MergeLotSource  
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId
	END
END

--------------------------------------------------------------------------
-- Check if there contents in @MergeLotSource and @MergeLotSourceStorage
--------------------------------------------------------------------------
IF	NOT EXISTS (SELECT TOP 1 1 FROM @MergeLotSource) 
	AND NOT EXISTS (SELECT TOP 1 1 FROM @MergeLotSourceStorage) 
BEGIN 
	-- 'Please check if there is enough stock to do the split.'
	EXEC uspICRaiseError 80222; 
	RETURN -80222;
END 

--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER STORAGE
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeLotSourceStorage (
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
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intItemId)
										,Detail.intItemUOMId
										,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
									)
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
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) < 0 -- ensure it is reducing the stock. 
			AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Storage -- process only storage stocks 
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS (SELECT TOP 1 1 FROM @MergeLotSourceStorage)
	BEGIN
		EXEC	dbo.uspICPostStorage
				@MergeLotSourceStorage  
				,@strBatchId 
				,@intEntityUserSecurityId
	END
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
-- INCREASE THE STOCK ON SPLIT
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
																-FromStock.dblQty
														
															-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
																dbo.fnMultiply( 
																	ISNULL(Detail.dblNewSplitLotQuantity, -FromStock.dblQty)
																	,NewLot.dblWeightPerQty
																)

															--New Lot has a different weight UOM Id. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, -FromStock.dblQty
																)
															--New Lot has a different weight UOM Id but source lot was reduced by bags. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
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
																	, dbo.fnDivide(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																)
															ELSE 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, -FromStock.dblQty
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
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																						StockUnit.intItemUOMId
																						, SourceLotItemUOM.intWeightUOMId
																						, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)
																			,Detail.dblNewWeight
																		)

																	ELSE 
																		ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																				StockUnit.intItemUOMId
																				, SourceLotItemUOM.intWeightUOMId
																				, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
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
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)
																		
																			,Detail.dblNewWeight
																		)

																	ELSE
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)
																		
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLotWeightUOM.intItemUOMId
																				, NewLotWeightUOM.intItemUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																			)
																		)
															END															

														--New Lot has a different weight UOM Id. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
														-- Convert the source weight into the new lot weight. 

																	-- Compute a new cost if there is new weight. 
															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)																	
																			,Detail.dblNewWeight
																		)
																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(Detail.dblNewCost,  SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, -FromStock.dblQty
																			)
																		)
															END
															
														--New Lot has a different weight UOM Id but source lot was reduced by bags. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 

															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 

																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)																		
																			,Detail.dblNewWeight
																		)

																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)																			 
																			)
																			, dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																			)
																		
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

																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(dbo.fnDivide(Detail.dblNewCost, NewLotItemUOM.dblUnitQty), FromStock.dblCost)
																	)
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, dbo.fnDivide(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																	)
																)


															ELSE 
																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																	)
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, -FromStock.dblQty
																	)
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
			,intSubLocationId		= ISNULL(Detail.intNewSubLocationId, Detail.intSubLocationId)
			,intStorageLocationId	= ISNULL(Detail.intNewStorageLocationId, Detail.intStorageLocationId) 
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
			AND NewLot.intOwnershipType = @OWNERSHIP_TYPE_Own
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @MergeToTargetLot)
	BEGIN
		DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList

		EXEC	dbo.uspICPostCosting  
				@MergeToTargetLot  
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId
	END
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SPLIT STORAGE
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeToTargetLotStorage (
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
																-FromStock.dblQty
														
															-- New Lot has the same weight UOM Id but Source Lot is reduced by bags. 
															WHEN NewLot.intWeightUOMId = SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN
																dbo.fnMultiply( 
																	ISNULL(Detail.dblNewSplitLotQuantity, -FromStock.dblQty)
																	,NewLot.dblWeightPerQty
																)

															--New Lot has a different weight UOM Id. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, -FromStock.dblQty
																)
															--New Lot has a different weight UOM Id but source lot was reduced by bags. 
															WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 
																-- Convert the source weight into the new lot weight. 
																dbo.fnCalculateQtyBetweenUOM(
																		SourceLot.intWeightUOMId
																		, NewLot.intWeightUOMId
																		, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
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
																	, dbo.fnDivide(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																)
															ELSE 
																dbo.fnCalculateQtyBetweenUOM (
																	SourceLot.intItemUOMId
																	, NewLot.intItemUOMId
																	, -FromStock.dblQty
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
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																						StockUnit.intItemUOMId
																						, SourceLotItemUOM.intWeightUOMId
																						, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)
																			,Detail.dblNewWeight
																		)

																	ELSE 
																		ISNULL(
																			-- convert the new cost to stock unit, and then convert it to source lot weight UOM. 
																			dbo.fnCalculateQtyBetweenUOM (
																				StockUnit.intItemUOMId
																				, SourceLotItemUOM.intWeightUOMId
																				, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
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
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)
																		
																			,Detail.dblNewWeight
																		)

																	ELSE
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)
																		
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLotWeightUOM.intItemUOMId
																				, NewLotWeightUOM.intItemUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																			)
																		)
															END															

														--New Lot has a different weight UOM Id. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId = FromStock.intItemUOMId THEN 
														-- Convert the source weight into the new lot weight. 

																	-- Compute a new cost if there is new weight. 
															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(Detail.dblNewCost, SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)																	
																			,Detail.dblNewWeight
																		)
																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(
																					-- convert the new cost to stock unit, and then convert it to source-lot Item UOM. 
																					dbo.fnCalculateQtyBetweenUOM (
																							StockUnit.intItemUOMId
																							, SourceLot.intWeightUOMId
																							, dbo.fnDivide(Detail.dblNewCost,  SourceLotItemUOM.dblUnitQty)
																					)	
																					-- otherwise, use the cost coming from the cost bucket. 
																					, FromStock.dblCost
																				)
																			)
																			,dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, -FromStock.dblQty
																			)
																		)
															END
															
														--New Lot has a different weight UOM Id but source lot was reduced by bags. 
														WHEN NewLot.intWeightUOMId <> SourceLot.intWeightUOMId AND SourceLot.intWeightUOMId <> FromStock.intItemUOMId THEN 

															CASE	WHEN ISNULL(Detail.dblNewWeight, 0) <> 0 THEN 

																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																			)																		
																			,Detail.dblNewWeight
																		)

																	ELSE 
																		dbo.fnDivide(
																			dbo.fnMultiply(
																				-FromStock.dblQty
																				,ISNULL(Detail.dblNewCost, FromStock.dblCost)																			 
																			)
																			, dbo.fnCalculateQtyBetweenUOM (
																				SourceLot.intWeightUOMId
																				, NewLot.intWeightUOMId
																				, dbo.fnMultiply(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																			)
																		
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

																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(dbo.fnDivide(Detail.dblNewCost, NewLotItemUOM.dblUnitQty), FromStock.dblCost)
																	)
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, dbo.fnDivide(-FromStock.dblQty, SourceLot.dblWeightPerQty)
																	)
																)


															ELSE 
																dbo.fnDivide(
																	dbo.fnMultiply(
																		-FromStock.dblQty
																		,ISNULL(Detail.dblNewCost, FromStock.dblCost)
																	)
																	,dbo.fnCalculateQtyBetweenUOM (
																		SourceLot.intItemUOMId
																		, NewLot.intItemUOMId
																		, -FromStock.dblQty
																	)
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
			,intSubLocationId		= ISNULL(Detail.intNewSubLocationId, Detail.intSubLocationId)
			,intStorageLocationId	= ISNULL(Detail.intNewStorageLocationId, Detail.intStorageLocationId) 
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId			
			INNER JOIN dbo.tblICInventoryTransactionStorage FromStock
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
			AND NewLot.intOwnershipType = @OWNERSHIP_TYPE_Storage
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @MergeToTargetLotStorage)
	BEGIN
		EXEC	dbo.uspICPostStorage
				@MergeToTargetLotStorage
				,@strBatchId  
				,@intEntityUserSecurityId
	END
END