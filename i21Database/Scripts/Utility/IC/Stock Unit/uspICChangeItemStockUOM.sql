﻿CREATE PROCEDURE [dbo].[uspICChangeItemStockUOM]
	@intItemId INT,
	@intItemUOMAsNewStockUnit INT = NULL,
	@strUnitMeasureId AS NVARCHAR(50) = NULL 

AS

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
		intItemUOMId AS INT
		,intUnitMeasureId AS INT
		,dblUnitQty AS NUMERIC(38, 20)
		,ysnStockUnit AS BIT 
	)

	INSERT INTO @OriginalItemUOM (
			intItemUOMId
			,intUnitMeasureId
			,dblUnitQty
			,dblUnitQty
	)
	SELECT	intItemUOMId
			,intUnitMeasureId
			,dblUnitQty
			,ysnStockUnit
	FROM dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
END 

-- Update the inventory stock
BEGIN 
	DECLARE @intItemUOMIdOriginalStockUnit AS INT 
	SELECT	@intItemUOMIdOriginalStockUnit = intItemUOMId
	FROM	dbo.tblICItemUOM
	WHERE	ISNULL(ysnStockUnit, 0) = 1

	DECLARE @dblNewStockUnit_UnitQty AS NUMERIC(38, 20)
	SELECT	@dblNewStockUnit_UnitQty = dblUnitQty
	FROM	@OriginalItemUOM
	WHERE	intItemUOM = @intItemUOMAsNewStockUnit

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

-- Update the unit Qty of the inventory transactions. 
BEGIN 
	UPDATE	InvTrans
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItemUOM ItemUOM
				ON InvTrans.intItemUOMId = ItemUOM.intItemUOMId
	WHERE	InvTrans.intItemId = @intItemId 
END

-- Update the cost buckets
