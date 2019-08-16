CREATE PROCEDURE uspICUpdateItemTransactionStockUnits  
    @intItemId INT,
    @intOriginalItemStockUOMId INT,
    @intNewItemStockUOMId INT,
    @dblOldUnitQty NUMERIC(38, 20),
    @dblNewUnitQty NUMERIC(38, 20),
    @intUserId INT
AS

IF EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intItemUOMId = @intNewItemStockUOMId AND ysnStockUnit = 1)
BEGIN
    -- Pre-calculate price and cost fields. Convert all to new UOM Id. 
    UPDATE	p
	SET		dblStandardCost = ROUND(dbo.fnCalculateCostBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblStandardCost), 5)
			,dblLastCost = ROUND(dbo.fnCalculateCostBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblLastCost), 5)
			,dblAverageCost = ROUND(dbo.fnCalculateCostBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblAverageCost), 5)
			,dblSalePrice = ROUND(dbo.fnCalculateCostBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblSalePrice), 6)
	FROM	dbo.tblICItemPricing p
	WHERE	p.intItemId = @intItemId
	
	-- Item Pricing tab
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(dbo.fnCalculateCostBetweenUOM(pl.intItemUnitMeasureId, @intOriginalItemStockUOMId, pl.dblUnitPrice), 6)
	FROM	tblICItemPricingLevel pl
	WHERE	intItemId = @intItemId

	UPDATE	l
	SET		dblLastCost = ROUND(dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblLastCost), 6)
	FROM	dbo.tblICLot l
	WHERE	l.intItemId = @intItemId

    -- Commented out for now, this causes too many issues
    -- DECLARE @OldQty NUMERIC(38, 20)
    -- SELECT @OldQty = stockUOM.dblOnHand
    -- FROM tblICItemStockUOM stockUOM
    -- WHERE stockUOM.intItemId = @intItemId
    --     AND stockUOM.intItemUOMId = @intOriginalItemStockUOMId

    -- UPDATE stockUOM
    -- SET stockUOM.dblOnHand = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, @OldQty) 
    -- FROM tblICItemStockUOM stockUOM
    -- WHERE stockUOM.intItemId = @intItemId
    --     AND stockUOM.intItemUOMId = @intNewItemStockUOMId

    -- Update the inventory stock
	-- Convert the stock unit from the Item Stock table to the new stock unit qty. 
	UPDATE	ItemStock
	SET		dblBackOrder = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblBackOrder) 
			,dblConsignedPurchase = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblConsignedPurchase) 
			,dblConsignedSale = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblConsignedSale) 
			,dblInTransitInbound = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblInTransitInbound) 
			,dblInTransitOutbound = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblInTransitOutbound) 
			,dblLastCountRetail = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblLastCountRetail) 
			,dblOnOrder = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblOnOrder) 
			,dblOrderCommitted = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblOrderCommitted) 
			,dblUnitOnHand = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblUnitOnHand) 
			,dblUnitReserved = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblUnitReserved) 
			,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(@intOriginalItemStockUOMId, @intNewItemStockUOMId, dblUnitStorage) 
	FROM	dbo.tblICItemStock ItemStock
	WHERE	intItemId = @intItemId

    -- Update the dblUOMQty of all the inventory transactions 
    UPDATE	t
    SET		t.dblUOMQty = iUOM.dblUnitQty
    FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
                ON t.intItemId = iUOM.intItemId
                AND t.intItemUOMId = iUOM.intItemUOMId 
    WHERE	t.intItemId = @intItemId

    -- Re-calculate the Item Pricing Levels. 
	-- Item Pricing Level
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(dbo.fnCalculateCostBetweenUOM(@intOriginalItemStockUOMId, pl.intItemUnitMeasureId, pl.dblUnitPrice) , 5)
	FROM	tblICItemPricingLevel pl
	WHERE	intItemId = @intItemId

END