CREATE PROCEDURE [dbo].[uspICUpdateSystemCount]
AS

UPDATE cd
SET cd.dblSystemCount = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN nonLotted.dblOnHand ELSE lotted.dblOnHand END, 0)
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
	INNER JOIN tblICItem Item ON Item.intItemId = cd.intItemId
	LEFT OUTER JOIN (
		SELECT
			StockUOM.intItemId,
			StockUOM.intItemUOMId,
			intLocationId = ItemLoc.intLocationId,
			StockUOM.intItemLocationId,
			dblOnHand = ISNULL(StockUOM.dblOnHand, 0),
			StockUOM.intSubLocationId,
			StockUOM.intStorageLocationId
		FROM tblICItemStockUOM StockUOM
			INNER JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
			INNER JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
		WHERE Item.strLotTracking = 'No'
	) nonLotted ON nonLotted.intItemId = cd.intItemId
		AND nonLotted.intItemLocationId = cd.intItemLocationId
		AND nonLotted.intItemUOMId = cd.intItemUOMId
		AND nonLotted.intSubLocationId = cd.intSubLocationId
		AND nonLotted.intStorageLocationId = cd.intStorageLocationId
	LEFT OUTER JOIN (
		SELECT 
			Lot.strLotNumber,
			ISNULL(Lot.dblQty, 0) dblOnHand,
			Lot.intItemLocationId,
			Lot.intItemId,
			Lot.intItemUOMId,
			Lot.intWeightUOMId,
			Lot.intStorageLocationId,
			Lot.intSubLocationId,
			Lot.intLotId
		FROM tblICLot Lot
			INNER JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
		WHERE Item.strLotTracking <> 'No'
	) lotted ON lotted.intItemId = cd.intItemId
		AND lotted.intItemLocationId = cd.intItemLocationId
		AND lotted.intItemUOMId = cd.intItemUOMId
		AND lotted.intSubLocationId = cd.intSubLocationId
		AND lotted.intStorageLocationId = cd.intStorageLocationId
		AND lotted.strLotNumber = cd.strLotNo
WHERE c.intImportFlagInternal = 1

-- Update Last Cost
UPDATE cd
SET cd.dblLastCost = ISNULL(cd.dblLastCost, ISNULL(dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ISNULL(ItemLot.dblLastCost, ItemPricing.dblLastCost)), 0))
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
	INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = c.intLocationId 
		AND ItemLocation.intItemId = cd.intItemId
	LEFT JOIN dbo.tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	LEFT JOIN dbo.tblICItemUOM ItemUOM ON cd.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItem Item ON Item.intItemId = cd.intItemId
	LEFT JOIN dbo.tblICLot ItemLot ON ItemLot.intLotId = cd.intLotId AND Item.strLotTracking <> 'No'
	LEFT JOIN dbo.tblICItemUOM StockUOM ON cd.intItemId = StockUOM.intItemId AND StockUOM.ysnStockUnit = 1
WHERE c.intImportFlagInternal = 1

-- Others
UPDATE c
SET c.strCountBy = 'Item'
FROM tblICInventoryCount c
WHERE c.intImportFlagInternal = 1

-- Delete Items with blank uom
DELETE cd
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
WHERE cd.intItemUOMId IS NULL
	AND c.intImportFlagInternal = 1

-- Cleanup
-- Delete invalid details
-- Delete empty headers
DELETE c
FROM tblICInventoryCount c
	LEFT JOIN tblICInventoryCountDetail d ON c.intInventoryCountId = d.intInventoryCountId
WHERE c.intImportFlagInternal = 1
	AND d.intInventoryCountDetailId IS NULL

-- Update count numbers
DECLARE @Id INT
DECLARE @Prefix NVARCHAR(50)
DECLARE cur CURSOR FOR

SELECT DISTINCT c.intInventoryCountId
FROM tblICInventoryCount c
WHERE c.intImportFlagInternal = 1

OPEN cur

FETCH NEXT FROM cur INTO @Id

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @Prefix = strPrefix + CAST(intNumber + 1 AS NVARCHAR(50))
	FROM tblSMStartingNumber
	WHERE strTransactionType = 'Inventory Count'

	UPDATE tblICInventoryCount
	SET strCountNo = @Prefix
	WHERE intInventoryCountId = @Id

	;WITH rows_num AS
	(
		SELECT CAST(ROW_NUMBER() OVER(PARTITION BY d.intInventoryCountId ORDER BY intInventoryCountDetailId ASC) AS NVARCHAR(50)) strRowNum,
			d.intInventoryCountDetailId
		FROM tblICInventoryCountDetail d
			INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
		WHERE c.intInventoryCountId = @Id 
	)
	UPDATE d
	SET d.strCountLine = c.strCountNo + '-' + rn.strRowNum
	FROM tblICInventoryCountDetail d
		INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
		INNER JOIN rows_num rn ON rn.intInventoryCountDetailId = d.intInventoryCountDetailId
	WHERE c.intInventoryCountId = @Id

	UPDATE tblSMStartingNumber
	SET intNumber = intNumber + 1
	WHERE strTransactionType = 'Inventory Count'

	FETCH NEXT FROM cur	INTO @Id
END

CLOSE cur
DEALLOCATE cur

-- Auto-create Lot
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
	, intLotId
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
	, dblQty				= ISNULL(d.dblSystemCount, 0)
	, intLotId				= CASE NULLIF(d.strAutoCreatedLotNumber, '') WHEN NULL THEN d.intLotId ELSE NULL END
	, intLotStatusId		= 1
	, intDetailId			= d.intInventoryCountDetailId
FROM tblICInventoryCountDetail d
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
	INNER JOIN tblICItem Item ON Item.intItemId = d.intItemId
			AND Item.strLotTracking <> 'No'
WHERE c.intImportFlagInternal = 1

-- IF EXISTS(SELECT * FROM @Lots)
-- BEGIN
-- 	EXEC dbo.uspICCreateUpdateLotNumber @Lots, 1, 1, 0

-- 	UPDATE	countDetail
-- 	SET	intLotId = LotNumbers.intLotId
-- 	FROM tblICInventoryCountDetail countDetail
-- 		INNER JOIN #GeneratedLotItems LotNumbers ON countDetail.intInventoryCountDetailId = LotNumbers.intDetailId
-- 		INNER JOIN tblICItem Item ON Item.intItemId = countDetail.intItemId
-- 			AND Item.strLotTracking <> 'No'

-- END

-- Reset Count Flag
UPDATE ic
SET ic.intImportFlagInternal = NULL
FROM tblICInventoryCount ic
WHERE ic.intImportFlagInternal = 1