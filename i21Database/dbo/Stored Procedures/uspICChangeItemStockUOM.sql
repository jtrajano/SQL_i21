CREATE PROCEDURE [dbo].[uspICChangeItemStockUOM]
	@intItemId INT,
	@NewStockItemUOMId INT = NULL,
	@NewStockUnitMeasureId AS NVARCHAR(50) = NULL,
	@intEntitySecurityUserId AS INT = NULL 
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
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemUOM WHERE intItemId = @intItemId AND intItemUOMId = @NewStockItemUOMId)
	BEGIN 
		SET @NewStockItemUOMId = NULL 

		-- Try to get the UOM based by the string value. 
		SELECT	TOP 1 
				@NewStockItemUOMId = ItemUOM.intItemUOMId
				,@strNewStockUnit = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ItemUOM.intItemId = @intItemId
				AND UOM.strUnitMeasure = @NewStockUnitMeasureId

		-- If not found, return -2; 
		IF @NewStockItemUOMId IS NULL 
		BEGIN 
			RETURN -2;
		END 
	END 

	-- Exit if the new item uom is already set as stock unit. 
	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemUOM WHERE intItemId = @intItemId AND intItemUOMId = @NewStockItemUOMId AND ysnStockUnit = 1)
	BEGIN 
		RETURN -3; 
	END 
END

-- Remeber the original UOM Id. 
BEGIN 
	DECLARE @OriginalStockItemUOMId AS INT 

	SELECT	@OriginalStockItemUOMId = ItemUOM.intItemUOMId
			,@strOriginalStockUnit = UOM.strUnitMeasure
	FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE	ItemUOM.intItemId = @intItemId
			AND ISNULL(ItemUOM.ysnStockUnit, 0) = 1
END 

-- Remember the original item uom records. 
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

-- Pre-calculate price and cost fields. Convert all to new UOM Id. 
BEGIN 
	-- Item Pricing tab
	UPDATE	p
	SET		dblStandardCost = ROUND(dbo.fnCalculateCostBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblStandardCost), 5)
			,dblLastCost = ROUND(dbo.fnCalculateCostBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblLastCost), 5)
			,dblAverageCost = ROUND(dbo.fnCalculateCostBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblAverageCost), 5)
			,dblSalePrice = ROUND(dbo.fnCalculateCostBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblSalePrice), 5)
	FROM	dbo.tblICItemPricing p
	WHERE	p.intItemId = @intItemId
	
	-- Item Pricing tab
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(dbo.fnCalculateCostBetweenUOM(pl.intItemUnitMeasureId, @OriginalStockItemUOMId, pl.dblUnitPrice), 5)
	FROM	tblICItemPricingLevel pl
	WHERE	intItemId = @intItemId

	UPDATE	l
	SET		dblLastCost = ROUND(dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblLastCost) , 5)
	FROM	dbo.tblICLot l
	WHERE	l.intItemId = @intItemId
END 

-- Recalculate Unit Qty to the new UOM id. 
BEGIN 
	DECLARE @dblNewStockUnit_UnitQty AS NUMERIC(38, 20)

	SELECT	@dblNewStockUnit_UnitQty = dblUnitQty
	FROM	@OriginalItemUOM
	WHERE	intItemUOMId = @NewStockItemUOMId

	UPDATE	ItemUOM
	SET		dblUnitQty = 
					CASE	WHEN (dblUnitQty > @dblNewStockUnit_UnitQty OR dblUnitQty = 1) AND @dblNewStockUnit_UnitQty <> 0 THEN  
								dbo.fnDivide(dblUnitQty, @dblNewStockUnit_UnitQty) 
							WHEN dblUnitQty = @dblNewStockUnit_UnitQty THEN  
								1
							ELSE 
								dbo.fnMultiply(dblUnitQty, @dblNewStockUnit_UnitQty) 
					END 
	FROM	dbo.tblICItemUOM ItemUOM
	WHERE	intItemId = @intItemId
END 

-- Update the inventory stock
BEGIN 
	-- Convert the stock unit from the Item Stock table to the new stock unit qty. 
	UPDATE	ItemStock
	SET		dblBackOrder = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblBackOrder) 
			,dblConsignedPurchase = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblConsignedPurchase) 
			,dblConsignedSale = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblConsignedSale) 
			,dblInTransitInbound = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblInTransitInbound) 
			,dblInTransitOutbound = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblInTransitOutbound) 
			,dblLastCountRetail = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblLastCountRetail) 
			,dblOnOrder = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblOnOrder) 
			,dblOrderCommitted = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblOrderCommitted) 
			,dblUnitOnHand = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblUnitOnHand) 
			,dblUnitReserved = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblUnitReserved) 
			,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(@OriginalStockItemUOMId, @NewStockItemUOMId, dblUnitStorage) 
	FROM	dbo.tblICItemStock ItemStock
	WHERE	intItemId = @intItemId

	-- Update qty of the new stock UOM. 
	MERGE	
	INTO	dbo.tblICItemStockUOM
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM
	USING (
		SELECT	iUOM.intItemId
				,iUOM.intItemLocationId
				,iUOM.intSubLocationId
				,iUOM.intStorageLocationId
				,intItemUOMId = @NewStockItemUOMId
				,dblConsignedPurchase = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblConsignedPurchase)
				,dblConsignedSale = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblConsignedSale)
				,dblInConsigned = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblInConsigned)
				,dblInTransitInbound = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblInTransitInbound)
				,dblInTransitOutbound = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblInTransitOutbound)
				,dblOnHand = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblOnHand)
				,dblOnOrder = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblOnOrder)
				,dblOrderCommitted = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblOrderCommitted)
				,dblUnitReserved = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblUnitReserved)
				,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(iUOM.intItemUOMId, @NewStockItemUOMId, dblUnitStorage)
		FROM	tblICItemStockUOM iUOM
		WHERE	iUOM.intItemId = @intItemId
				AND iUOM.intItemUOMId = @OriginalStockItemUOMId
	) AS Source_Query  
		ON ItemStockUOM.intItemId = Source_Query.intItemId
		AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
		AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

	-- If matched, update the On-Order qty 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblConsignedPurchase = Source_Query.dblConsignedPurchase 
				,dblConsignedSale = Source_Query.dblConsignedSale
				,dblInConsigned = Source_Query.dblInConsigned
				,dblInTransitInbound = Source_Query.dblInTransitInbound
				,dblInTransitOutbound = Source_Query.dblInTransitOutbound
				,dblOnHand = Source_Query.dblOnHand
				,dblOnOrder = Source_Query.dblOnOrder
				,dblOrderCommitted = Source_Query.dblOrderCommitted
				,dblUnitReserved = Source_Query.dblUnitReserved
				,dblUnitStorage = Source_Query.dblUnitStorage

	-- If none is found, insert a new item stock record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblConsignedPurchase 
			,dblConsignedSale 
			,dblInConsigned 
			,dblInTransitInbound 
			,dblInTransitOutbound 
			,dblOnHand 
			,dblOnOrder 
			,dblOrderCommitted 
			,dblUnitReserved 
			,dblUnitStorage 
			,intConcurrencyId
		)
		VALUES (
			Source_Query.intItemId
			,Source_Query.intItemLocationId
			,Source_Query.intItemUOMId
			,Source_Query.intSubLocationId
			,Source_Query.intStorageLocationId
			,Source_Query.dblConsignedPurchase 
			,Source_Query.dblConsignedSale
			,Source_Query.dblInConsigned
			,Source_Query.dblInTransitInbound
			,Source_Query.dblInTransitOutbound
			,Source_Query.dblOnHand
			,Source_Query.dblOnOrder
			,Source_Query.dblOrderCommitted
			,Source_Query.dblUnitReserved
			,Source_Query.dblUnitStorage			
			,1	
		)
	;

END 

-- Update the dblUOMQty of all the inventory transactions 
UPDATE	t
SET		t.dblUOMQty = iUOM.dblUnitQty
FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
			ON t.intItemId = iUOM.intItemId
			AND t.intItemUOMId = iUOM.intItemUOMId 
WHERE	t.intItemId = @intItemId

-- Re-calculate the Item Pricing Levels. 
BEGIN 
	-- Item Pricing Level
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(dbo.fnCalculateCostBetweenUOM(@OriginalStockItemUOMId, pl.intItemUnitMeasureId, pl.dblUnitPrice) , 5)
	FROM	tblICItemPricingLevel pl
	WHERE	intItemId = @intItemId
END 

-- Update the flag for the new Stock UOM.
BEGIN 
	UPDATE	iUOM
	SET		ysnStockUnit = 0 
	FROM	tblICItemUOM iUOM
	WHERE	iUOM.intItemId = @intItemId

	UPDATE	iUOM
	SET		ysnStockUnit = 1
	FROM	dbo.tblICItemUOM iUOM
	WHERE	iUOM.intItemId = @intItemId
			AND iUOM.intItemUOMId = @NewStockItemUOMId 
END 

-- Create an Audit Log
BEGIN 
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intItemId						
			,@screenName = 'Inventory.view.Item'		
			,@entityId = @intEntitySecurityUserId
			,@actionType = 'Processed'                  
			,@changeDescription = 'Migrate to a new Stock Unit.'
			,@fromValue = @strOriginalStockUnit
			,@toValue = @strNewStockUnit
END