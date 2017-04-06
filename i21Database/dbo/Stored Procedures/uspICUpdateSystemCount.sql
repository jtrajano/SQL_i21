CREATE PROCEDURE [dbo].[uspICUpdateSystemCount]
AS

UPDATE cd
SET cd.dblSystemCount = s.dblOnHand
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
	INNER JOIN (
		SELECT
			StockUOM.intItemStockUOMId,
			StockUOM.intItemId,
			intLocationId = ItemLoc.intLocationId,
			StockUOM.intItemLocationId,
			StockUOM.intItemUOMId,
			dblOnHand = (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END),	
			dblUnitQty = ItemUOM.dblUnitQty,
			ysnStockUnit = ItemUOM.ysnStockUnit
		FROM tblICItemStockUOM StockUOM
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
			LEFT JOIN tblICLot Lot ON Lot.intItemId = StockUOM.intItemId
				AND Lot.intItemLocationId = StockUOM.intItemLocationId
				AND Lot.intItemUOMId = StockUOM.intItemUOMId
				AND Lot.intSubLocationId = StockUOM.intSubLocationId
				AND Lot.intStorageLocationId = StockUOM.intStorageLocationId
		WHERE ItemUOM.ysnStockUnit = 1
	) s ON s.intItemId = cd.intItemId
		AND s.intLocationId = c.intLocationId
WHERE c.intImportFlagInternal = 1

-- Cleanup
DELETE d
FROM tblICInventoryCountDetail d
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
WHERE c.intImportFlagInternal = 1
	AND (d.intItemUOMId IS NULL
	OR d.intItemLocationId IS NULL
	OR d.intItemId IS NULL)

-- Autocreate Lot
-- Create the temp table 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
BEGIN 
	CREATE TABLE #GeneratedLotItems (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intDetailId INT 
		,intParentLotId INT
		,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)
END

DECLARE @Lots ItemLotTableType

INSERT INTO @Lots(
	  intItemId
	, intItemLocationId
	, intItemUOMId
	, strLotNumber
	, intSubLocationId
	, intStorageLocationId
	, dblQty
	, intLotStatusId
	, intDetailId
)
SELECT 
	  intItemId				= d.intItemId
	, intItemLocationId		= d.intItemLocationId
	, intItemUOMId			= d.intItemUOMId
	, strLotNumber			= d.strAutoCreatedLotNumber
	, intSubLocationId		= d.intSubLocationId
	, intStorageLocationId	= d.intStorageLocationId
	, dblQty				= d.dblSystemCount
	, intLotStatusId		= 1
	, intDetailId			= d.intInventoryCountDetailId
FROM tblICInventoryCountDetail d
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
	INNER JOIN tblICItem Item ON Item.intItemId = d.intItemId
			AND Item.strLotTracking <> 'No'
WHERE c.intImportFlagInternal = 1
	AND d.intItemUOMId IS NOT NULL
	AND d.intItemLocationId IS NOT NULL
	AND d.intItemId IS NOT NULL
	AND d.strAutoCreatedLotNumber IS NOT NULL

IF EXISTS(SELECT * FROM @Lots)
BEGIN
	EXEC dbo.uspICCreateUpdateLotNumber @Lots, 1, 1, 0
	
	UPDATE	countDetail
	SET	intLotId = LotNumbers.intLotId
	FROM tblICInventoryCountDetail countDetail
		INNER JOIN #GeneratedLotItems LotNumbers ON countDetail.intInventoryCountDetailId = LotNumbers.intDetailId
		INNER JOIN tblICItem Item ON Item.intItemId = countDetail.intItemId
			AND Item.strLotTracking <> 'No'

END

-- Reset Count Flag
UPDATE ic
SET ic.intImportFlagInternal = NULL
FROM tblICInventoryCount ic
WHERE ic.intImportFlagInternal = 1
