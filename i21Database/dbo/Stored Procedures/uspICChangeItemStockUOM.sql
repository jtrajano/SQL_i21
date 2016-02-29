CREATE PROCEDURE [dbo].[uspICChangeItemStockUOM]
	@intItemId INT,
	@intItemUOMAsNewStockUnit INT = NULL,
	@strUnitMeasureId AS NVARCHAR(50) = NULL,
	@entitySecurityUserId AS INT = NULL 
AS

DECLARE @strOriginalStockUnit AS NVARCHAR(50)
		,@strNewStockUnit AS NVARCHAR(50) 

-- Do the validations
BEGIN 

	-- Validate the item id. 
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItem WHERE intItemId = @intItemId)
	BEGIN 
		RETURN -1;
	END 

	-- Validate the item UOM 
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemUOM WHERE intItemId = @intItemId AND intItemUOMId = @intItemUOMAsNewStockUnit)
	BEGIN 
		SET @intItemUOMAsNewStockUnit = NULL 

		-- Try to get the UOM based by the string value. 
		SELECT	TOP 1 
				@intItemUOMAsNewStockUnit = ItemUOM.intItemUOMId
				,@strNewStockUnit = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ItemUOM.intItemId = @intItemId
				AND UOM.strUnitMeasure = @strUnitMeasureId

		-- If not found, return -2; 
		IF @intItemUOMAsNewStockUnit IS NULL 
		BEGIN 
			RETURN -2;
		END 
	END 

	-- Exit if the new item uom is already set as stock unit. 
	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemUOM WHERE intItemId = @intItemId AND intItemUOMId = @intItemUOMAsNewStockUnit AND ysnStockUnit = 1)
	BEGIN 
		RETURN -3; 
	END 
END

-- Get the original item uom records. 
BEGIN 
	DECLARE @OriginalItemUOM AS TABLE (
		intItemUOMId INT
		,intUnitMeasureId INT
		,dblUnitQty NUMERIC(38, 20)
		,ysnStockUnit BIT 
	)

	INSERT INTO @OriginalItemUOM (
			intItemUOMId
			,intUnitMeasureId
			,dblUnitQty
			,ysnStockUnit
	)
	SELECT	intItemUOMId
			,intUnitMeasureId
			,dblUnitQty
			,ISNULL(ysnStockUnit, 0) 
	FROM dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
END 

-- Update the inventory stock
BEGIN 
	DECLARE @intItemUOMIdOriginalStockUnit AS INT 

	SELECT	@intItemUOMIdOriginalStockUnit = ItemUOM.intItemUOMId
			,@strOriginalStockUnit = UOM.strUnitMeasure
	FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE	ItemUOM.intItemId = @intItemId
			AND ISNULL(ItemUOM.ysnStockUnit, 0) = 1

	DECLARE @dblNewStockUnit_UnitQty AS NUMERIC(38, 20)
	SELECT	@dblNewStockUnit_UnitQty = dblUnitQty
	FROM	@OriginalItemUOM
	WHERE	intItemUOMId = @intItemUOMAsNewStockUnit

	-- Convert the stock unit from the Item Stock table to the new stock unit qty. 
	UPDATE	ItemStock
	SET		dblBackOrder = dbo.fnDivide(dblBackOrder, @dblNewStockUnit_UnitQty) 
			,dblConsignedPurchase = dbo.fnDivide(dblConsignedPurchase, @dblNewStockUnit_UnitQty) 
			,dblConsignedSale = dbo.fnDivide(dblConsignedSale, @dblNewStockUnit_UnitQty) 
			,dblInTransitInbound = dbo.fnDivide(dblInTransitInbound, @dblNewStockUnit_UnitQty) 
			,dblInTransitOutbound = dbo.fnDivide(dblInTransitOutbound, @dblNewStockUnit_UnitQty) 
			,dblLastCountRetail = dbo.fnDivide(dblLastCountRetail, @dblNewStockUnit_UnitQty) 
			,dblOnOrder = dbo.fnDivide(dblOnOrder, @dblNewStockUnit_UnitQty) 
			,dblOrderCommitted = dbo.fnDivide(dblOrderCommitted, @dblNewStockUnit_UnitQty) 
			,dblUnitOnHand = dbo.fnDivide(dblUnitOnHand, @dblNewStockUnit_UnitQty) 
			,dblUnitReserved = dbo.fnDivide(dblUnitReserved, @dblNewStockUnit_UnitQty) 
			,dblUnitStorage = dbo.fnDivide(dblUnitStorage, @dblNewStockUnit_UnitQty) 
	FROM	dbo.tblICItemStock ItemStock
	WHERE	intItemId = @intItemId

	-- Convert all the quantities to original stock unit. 
	UPDATE	StockUOM
	SET		dblConsignedPurchase = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblConsignedPurchase) 
			,dblConsignedSale = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblConsignedSale) 
			,dblInConsigned = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblInConsigned) 
			,dblInTransitInbound = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblInTransitInbound) 
			,dblInTransitOutbound = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblInTransitOutbound) 
			,dblOnHand = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblOnHand) 
			,dblOnOrder = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblOnOrder) 
			,dblOrderCommitted = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblOrderCommitted) 
			,dblUnitReserved = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblUnitReserved) 
			,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, @intItemUOMIdOriginalStockUnit, dblUnitStorage) 
	FROM	dbo.tblICItemStockUOM StockUOM 
	WHERE	intItemId = @intItemId 

	-- The update it to the new stock unit. 
	UPDATE	StockUOM
	SET		dblConsignedPurchase = dbo.fnDivide(dblConsignedPurchase, @dblNewStockUnit_UnitQty) 
			,dblConsignedSale = dbo.fnDivide(dblConsignedSale, @dblNewStockUnit_UnitQty) 
			,dblInConsigned = dbo.fnDivide(dblInConsigned, @dblNewStockUnit_UnitQty) 
			,dblInTransitInbound = dbo.fnDivide(dblInTransitInbound, @dblNewStockUnit_UnitQty) 
			,dblInTransitOutbound = dbo.fnDivide(dblInTransitOutbound, @dblNewStockUnit_UnitQty) 
			,dblOnHand = dbo.fnDivide(dblOnHand, @dblNewStockUnit_UnitQty) 
			,dblOnOrder = dbo.fnDivide(dblOnOrder, @dblNewStockUnit_UnitQty) 
			,dblOrderCommitted = dbo.fnDivide(dblOrderCommitted, @dblNewStockUnit_UnitQty) 
			,dblUnitReserved = dbo.fnDivide(dblUnitReserved, @dblNewStockUnit_UnitQty) 
			,dblUnitStorage = dbo.fnDivide(dblUnitStorage, @dblNewStockUnit_UnitQty) 
	FROM	dbo.tblICItemStockUOM StockUOM 
	WHERE	intItemId = @intItemId 
END 

-- Migrate all inventory transactions using the original stock unit to the new stock unit. 
BEGIN 
	-- Convert Qty, Cost, and Sales Price to the new stock unit. 
	UPDATE	InvTrans
	SET		dblQty = dbo.fnDivide(dblQty, @dblNewStockUnit_UnitQty) 
			,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
			,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, @dblNewStockUnit_UnitQty) 
			,intItemUOMId = @intItemUOMAsNewStockUnit
	FROM	dbo.tblICInventoryTransaction InvTrans 
	WHERE	InvTrans.intItemId = @intItemId 
			AND InvTrans.intItemUOMId = @intItemUOMIdOriginalStockUnit

	UPDATE	InvLotTrans
	SET		dblQty = dbo.fnDivide(dblQty, @dblNewStockUnit_UnitQty) 
			,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
			,intItemUOMId = @intItemUOMAsNewStockUnit
	FROM	dbo.tblICInventoryLotTransaction InvLotTrans 
	WHERE	InvLotTrans.intItemId = @intItemId 
			AND InvLotTrans.intItemUOMId = @intItemUOMIdOriginalStockUnit

	-- Migrate the Lot cost bucket from the original stock unit to the new stock unit.
	BEGIN 
		UPDATE	LotOut
		SET		dblQty = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblCostAdjustQty = dbo.fnDivide(dblCostAdjustQty, @dblNewStockUnit_UnitQty) 
		FROM	dbo.tblICInventoryLot InvLot INNER JOIN dbo.tblICInventoryLotOut LotOut
					ON InvLot.intInventoryLotId = LotOut.intInventoryLotId
		WHERE	InvLot.intItemId = @intItemId
				AND InvLot.intItemUOMId = @intItemUOMIdOriginalStockUnit

		UPDATE	InvLot
		SET		dblStockIn = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblStockOut = dbo.fnDivide(dblStockOut, @dblNewStockUnit_UnitQty) 
				,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
				,intItemUOMId = @intItemUOMAsNewStockUnit
		FROM	dbo.tblICInventoryLot InvLot
		WHERE	InvLot.intItemId = @intItemId 
				AND InvLot.intItemUOMId = @intItemUOMIdOriginalStockUnit
	END 

	-- Migrate the FIFO cost bucket from the original stock unit to the new stock unit.
	BEGIN 
		UPDATE	FIFOOut
		SET		dblQty = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblCostAdjustQty = dbo.fnDivide(dblCostAdjustQty, @dblNewStockUnit_UnitQty) 
		FROM	dbo.tblICInventoryFIFO InvFIFO INNER JOIN dbo.tblICInventoryFIFOOut FIFOOut
					ON InvFIFO.intInventoryFIFOId = FIFOOut.intInventoryFIFOId
		WHERE	InvFIFO.intItemId = @intItemId
				AND InvFIFO.intItemUOMId = @intItemUOMIdOriginalStockUnit

		UPDATE	InvFIFO
		SET		dblStockIn = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblStockOut = dbo.fnDivide(dblStockOut, @dblNewStockUnit_UnitQty) 
				,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
				,intItemUOMId = @intItemUOMAsNewStockUnit
		FROM	dbo.tblICInventoryFIFO InvFIFO
		WHERE	InvFIFO.intItemId = @intItemId 
				AND InvFIFO.intItemUOMId = @intItemUOMIdOriginalStockUnit
	END

	-- Migrate the LIFO cost bucket from the original stock unit to the new stock unit.
	BEGIN 
		UPDATE	LIFOOut
		SET		dblQty = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblCostAdjustQty = dbo.fnDivide(dblCostAdjustQty, @dblNewStockUnit_UnitQty) 
		FROM	dbo.tblICInventoryLIFO InvLIFO INNER JOIN dbo.tblICInventoryLIFOOut LIFOOut
					ON InvLIFO.intInventoryLIFOId = LIFOOut.intInventoryLIFOId
		WHERE	InvLIFO.intItemId = @intItemId
				AND InvLIFO.intItemUOMId = @intItemUOMIdOriginalStockUnit
	
		UPDATE	InvLIFO
		SET		dblStockIn = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblStockOut = dbo.fnDivide(dblStockOut, @dblNewStockUnit_UnitQty) 
				,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
				,intItemUOMId = @intItemUOMAsNewStockUnit
		FROM	dbo.tblICInventoryLIFO InvLIFO
		WHERE	InvLIFO.intItemId = @intItemId 
				AND InvLIFO.intItemUOMId = @intItemUOMIdOriginalStockUnit
	END 

	-- Migrate the Actual Cost bucket from the original stock unit to the new stock unit.
	BEGIN 
		UPDATE	ActualCostOut
		SET		dblQty = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblCostAdjustQty = dbo.fnDivide(dblCostAdjustQty, @dblNewStockUnit_UnitQty) 
		FROM	dbo.tblICInventoryActualCost InvActualCost INNER JOIN dbo.tblICInventoryActualCostOut ActualCostOut
					ON InvActualCost.intInventoryActualCostId = ActualCostOut.intInventoryActualCostId
		WHERE	InvActualCost.intItemId = @intItemId
				AND InvActualCost.intItemUOMId = @intItemUOMIdOriginalStockUnit

		UPDATE	InvActualCost
		SET		dblStockIn = dbo.fnDivide(dblStockIn, @dblNewStockUnit_UnitQty) 
				,dblStockOut = dbo.fnDivide(dblStockOut, @dblNewStockUnit_UnitQty) 
				,dblCost = dbo.fnMultiply(dblCost, @dblNewStockUnit_UnitQty) 
				,intItemUOMId = @intItemUOMAsNewStockUnit
		FROM	dbo.tblICInventoryActualCost InvActualCost
		WHERE	InvActualCost.intItemId = @intItemId 
				AND InvActualCost.intItemUOMId = @intItemUOMIdOriginalStockUnit
	END 
END

-- Recalculate the Unit Qty's 
BEGIN 
	UPDATE	ItemUOM
	SET		dblUnitQty = dbo.fnDivide(dblUnitQty, @dblNewStockUnit_UnitQty) 
	FROM	dbo.tblICItemUOM ItemUOM
	WHERE	intItemId = @intItemId
END 

-- Update costs and sales prices. 
BEGIN 
	UPDATE	ItemPricing
	SET		dblStandardCost = dbo.fnMultiply(dblStandardCost, @dblNewStockUnit_UnitQty) 
			,dblLastCost = dbo.fnMultiply(dblLastCost, @dblNewStockUnit_UnitQty) 
			,dblAverageCost = dbo.fnMultiply(dblAverageCost, @dblNewStockUnit_UnitQty) 
			,dblSalePrice = dbo.fnMultiply(dblSalePrice, @dblNewStockUnit_UnitQty) 
	FROM	dbo.tblICItemPricing ItemPricing 
	WHERE	ItemPricing.intItemId = @intItemId
END 

-- Update the UOM Qty on all transactions to the new Unit Qty. 
BEGIN 
	UPDATE	InvTrans
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItemUOM ItemUOM
				ON InvTrans.intItemId = ItemUOM.intItemId
				AND InvTrans.intItemUOMId = ItemUOM.intItemUOMId
	WHERE	InvTrans.intItemId = @intItemId 
END 

-- Change to the new Stock Unit
BEGIN 
	UPDATE	ItemUOM
	SET		ysnStockUnit = 0 
	FROM	dbo.tblICItemUOM ItemUOM
	WHERE	intItemId = @intItemId

	UPDATE	ItemUOM
	SET		ysnStockUnit = 1
	FROM	dbo.tblICItemUOM ItemUOM
	WHERE	intItemId = @intItemId
			AND intItemUOMId = @intItemUOMAsNewStockUnit 
END 

-- Create an Audit Log
BEGIN 
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intItemId						
			,@screenName = 'Inventory.view.Item'		
			,@entityId = @entitySecurityUserId
			,@actionType = 'Processed'                  
			,@changeDescription = 'Migrate to a new Stock Unit.'
			,@fromValue = @strOriginalStockUnit
			,@toValue = @strNewStockUnit
END