CREATE PROCEDURE [dbo].[uspICIncreaseReleasedLot]
	@ItemsToIncreaseReleasedLot AS LotReleaseTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intItemId AS INT 
		,@strItemNo AS NVARCHAR(50)
		,@strLotNumber AS NVARCHAR(50)
		,@dblQty AS NUMERIC(38, 20)
		,@dblReleasedQty AS NUMERIC(38, 20) 

-- Validate the item-location. 
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseReleasedLot ItemsToValidate LEFT JOIN dbo.tblICItem Item
				ON ItemsToValidate.intItemId = Item.intItemId
	WHERE	NOT EXISTS (
				SELECT TOP 1 1 
				FROM	dbo.tblICItemLocation
				WHERE	tblICItemLocation.intItemLocationId = ItemsToValidate.intItemLocationId
						AND tblICItemLocation.intItemId = ItemsToValidate.intItemId
			)
			AND ItemsToValidate.intItemId IS NOT NULL 	
			
	-- 'Item-Location is invalid or missing for {Item}.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80002, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate the item uom id. 
-- WHEN @msgId = 80079 THEN 'Item UOM for %s is invalid or missing.'
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseReleasedLot ItemsToValidate LEFT JOIN dbo.tblICItem Item
				ON ItemsToValidate.intItemId = Item.intItemId
	WHERE	NOT EXISTS (
				SELECT TOP 1 1 
				FROM	dbo.tblICItemUOM 
				WHERE	tblICItemUOM.intItemUOMId = ItemsToValidate.intItemUOMId
						AND tblICItemUOM.intItemId = ItemsToValidate.intItemId
			)
			AND ItemsToValidate.intItemId IS NOT NULL 	
			
	-- 'Item UOM for {Item} is invalid or missing.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80079, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate the lot id
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 

	SELECT	TOP 1 
			@intItemId = item.intItemId 
			,@strItemNo = item.strItemNo
	FROM	@ItemsToIncreaseReleasedLot ItemsToValidate 
			INNER JOIN tblICItem item
				ON ItemsToValidate.intItemId = item.intItemId
	
			LEFT JOIN dbo.tblICLot lot
				ON ItemsToValidate.intItemId = lot.intItemId
				AND ItemsToValidate.intLotId = lot.intLotId
				AND ItemsToValidate.intItemLocationId = lot.intItemLocationId
				AND (ItemsToValidate.intSubLocationId = lot.intSubLocationId OR (ItemsToValidate.intSubLocationId IS NULL AND lot.intSubLocationId IS NULL))
				AND (ItemsToValidate.intStorageLocationId = lot.intStorageLocationId OR (ItemsToValidate.intStorageLocationId IS NULL AND lot.intStorageLocationId IS NULL))

	WHERE	ItemsToValidate.intItemId IS NOT NULL 	
			AND lot.intLotId IS NULL 
			
	-- 'Lot Number is invalid or missing for item %s.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80130, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate the released qty.
-- Important note: The Qty supplied must always be in "BAGS" or the packing qty used for tblICLot.intItemUOMId. 
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 


	SELECT	TOP 1 
			@intItemId = item.intItemId 
			,@strItemNo = item.strItemNo
			,@strLotNumber = lot.strLotNumber
			,@dblQty = lot.dblQty - ISNULL(lot.dblReleasedQty, 0)
			,@dblReleasedQty = ItemsToValidate.dblQty 
	FROM	@ItemsToIncreaseReleasedLot ItemsToValidate 
			INNER JOIN tblICItem item
				ON ItemsToValidate.intItemId = item.intItemId
	
			LEFT JOIN dbo.tblICLot lot
				ON ItemsToValidate.intItemId = lot.intItemId
				AND ItemsToValidate.intLotId = lot.intLotId
				AND ItemsToValidate.intItemLocationId = lot.intItemLocationId
				AND (ItemsToValidate.intSubLocationId = lot.intSubLocationId OR (ItemsToValidate.intSubLocationId IS NULL AND lot.intSubLocationId IS NULL ))
				AND (ItemsToValidate.intStorageLocationId = lot.intStorageLocationId OR (ItemsToValidate.intStorageLocationId IS NULL AND lot.intStorageLocationId IS NULL))

	WHERE	ItemsToValidate.intItemId IS NOT NULL 	
			AND lot.dblQty - (ISNULL(lot.dblReleasedQty, 0) + ISNULL(ItemsToValidate.dblQty, 0)) < 0 
			
	-- 'Available Qty in %s is %f. Releasing %f is not allowed.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80270, @strLotNumber, @dblQty, @dblReleasedQty;
		GOTO _Exit
	END 
END 

-- Do an upsert for the Item Stock table when updating the Released Lot
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	c.intItemId
				,c.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(c.intItemUOMId, StockUOM.intItemUOMId, c.dblQty)) 
		FROM	@ItemsToIncreaseReleasedLot c
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = c.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblReleasedLot = CASE WHEN ISNULL(ItemStock.dblReleasedLot, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblReleasedLot, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitOnHand
		,dblReleasedLot
		,dblOnOrder
		,dblLastCountRetail
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,0
		,CASE WHEN Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE Source_Query.Aggregrate_Qty END -- dblReleasedLot
		,0
		,0
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the Released Lot
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- If separate UOMs is not enabled, convert the qty to stock unit. 
		SELECT	c.intItemId
				,c.intItemLocationId
				,StockUOM.intItemUOMId
				,c.intSubLocationId
				,c.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(c.intItemUOMId, StockUOM.intItemUOMId, c.dblQty)) 
		FROM	@ItemsToIncreaseReleasedLot c
				INNER JOIN tblICItem i
					ON c.intItemId = i.intItemId 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = c.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 
			AND i.strLotTracking NOT LIKE 'Yes%'
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
			, StockUOM.intItemUOMId
			, c.intSubLocationId
			, c.intStorageLocationId
		-- If separate UOMs is enabled, don't convert the qty. Track it using the same uom. 
		UNION ALL 
		SELECT	c.intItemId
				,c.intItemLocationId
				,c.intItemUOMId
				,c.intSubLocationId
				,c.intStorageLocationId
				,Aggregrate_Qty = SUM(c.dblQty)
		FROM	@ItemsToIncreaseReleasedLot c
				INNER JOIN tblICItem i
					ON c.intItemId = i.intItemId 
		WHERE	
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 1
			OR i.strLotTracking LIKE 'Yes%'
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
			, c.intItemUOMId
			, c.intSubLocationId
			, c.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblReleasedLot = CASE WHEN ISNULL(ItemStockUOM.dblReleasedLot, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblReleasedLot, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblOnHand
		,dblOnOrder
		,dblReleasedLot
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,0
		,0
		,CASE WHEN Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE Source_Query.Aggregrate_Qty END
		,1	
	)
;

-- Create the Item Stock Detail 
BEGIN 
	DECLARE		
		@stockType_ReleasedLot AS INT = 13
		
	INSERT INTO tblICItemStockDetail (
			intItemStockTypeId 
			,intItemId   
			,intItemLocationId 
			,intItemUOMId 
			,intSubLocationId 
			,intStorageLocationId 
			,strTransactionId
			,dblQty
			,intLotId
			,intConcurrencyId
	)
	SELECT 
			intItemStockTypeId	= @stockType_ReleasedLot
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId 
			,strTransactionId
			,dblQty
			,intLotId 
			,intConcurrencyId	= 1
	FROM	@ItemsToIncreaseReleasedLot cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

-- Update the Released Qty in the lot table. 
BEGIN 
	UPDATE	lot
	SET 
		lot.dblReleasedQty = ISNULL(lot.dblReleasedQty, 0) + ISNULL(released.dblQty, 0) 	
	FROM	@ItemsToIncreaseReleasedLot released
			INNER JOIN dbo.tblICLot lot
				ON released.intItemId = lot.intItemId
				AND released.intLotId = lot.intLotId
				AND released.intItemLocationId = lot.intItemLocationId
				AND (released.intSubLocationId = lot.intSubLocationId OR (released.intSubLocationId IS NULL AND lot.intSubLocationId IS NULL)) 
				AND (released.intStorageLocationId = lot.intStorageLocationId OR (released.intStorageLocationId IS NULL AND lot.intStorageLocationId IS NULL))
				AND released.intItemUOMId = lot.intItemUOMId
END 

_Exit: