CREATE PROCEDURE [dbo].[uspICUpdateSystemCount]
AS

UPDATE cd
SET cd.dblSystemCount = ISNULL(
				CASE 
					WHEN Item.strLotTracking = 'No' THEN 
						CASE 
							WHEN c.strCountBy = 'Pack' THEN 
								dbo.fnCalculateQtyBetweenUOM(stockByPackUOM.intItemUOMId, cd.intItemUOMId, stockByPackUOM.dblOnHand)
							WHEN Item.ysnSeparateStockForUOMs = 1 THEN 
								separateUOM.dblOnHand
							WHEN ISNULL(Item.ysnSeparateStockForUOMs, 0) = 0 THEN 
								byStockUOM.dblOnHand								
							ELSE 
								dbo.fnCalculateQtyBetweenUOM(byStockUOM.intItemUOMId, StockUOM.intItemUOMId, byStockUOM.dblOnHand)
						END
					ELSE 
						lotted.dblOnHand
				END
				, 0
			),
	cd.dblWeightQty = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE lotted.dblWeight END, 0)
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
	INNER JOIN tblICItem Item ON Item.intItemId = cd.intItemId
	LEFT JOIN dbo.tblICItemUOM StockUOM ON cd.intItemId = StockUOM.intItemId AND StockUOM.ysnStockUnit = 1
	OUTER APPLY (
		SELECT intItemId
			, intItemUOMId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
			, dblLastCost = MAX(ISNULL(dblLastCost, 0))
		FROM vyuICGetItemStockSummary
		WHERE	intItemId = cd.intItemId
			AND intItemLocationId = cd.intItemLocationId
			AND intItemUOMId = cd.intItemUOMId
			AND ((cd.intSubLocationId IS NULL) OR (cd.intSubLocationId = intSubLocationId OR ISNULL(intSubLocationId, 0) = 0))
			AND ((cd.intStorageLocationId IS NULL) OR (cd.intStorageLocationId = intStorageLocationId OR ISNULL(intStorageLocationId, 0) = 0))
			AND dbo.fnDateLessThanEquals(dtmDate, c.dtmCountDate) = 1
		GROUP BY 
			intItemId,
			intItemUOMId,
			intItemLocationId,
			intSubLocationId,
			intStorageLocationId
	) nonLotted
	OUTER APPLY (
		SELECT v.intItemId
			, u.intItemUOMId
			, v.intItemLocationId
			, v.intSubLocationId
			, v.intStorageLocationId
			, dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(v.intItemUOMId, u.intItemUOMId, v.dblQty))
		FROM tblICInventoryTransaction v
		INNER JOIN tblICItemUOM u ON v.intItemId = u.intItemId
			AND u.ysnStockUnit = 1
		WHERE v.intItemId = Item.intItemId
			AND v.intItemLocationId = cd.intItemLocationId
			AND dbo.fnDateLessThanEquals(v.dtmDate, c.dtmCountDate) = 1
		GROUP BY 
			v.intItemId
			, u.intItemUOMId
			, v.intItemLocationId
			, v.intSubLocationId
			, v.intStorageLocationId  
	) stockByPackUOM
	LEFT JOIN (
		SELECT 
			ss.intItemId
			, ss.intItemUOMId
			, ss.intItemLocationId
			, ss.intSubLocationId
			, ss.intStorageLocationId
			, dblOnHand = SUM(COALESCE(ss.dblOnHand, 0.00))
			, dtmDate
		FROM vyuICGetRunningStockQtyByStockUOM ss
		GROUP BY 
			ss.intItemId,
			intItemUOMId,
			intItemLocationId,
			intSubLocationId,
			intStorageLocationId,
			dtmDate
	) byStockUOM 
		ON byStockUOM.intItemId = cd.intItemId
		AND byStockUOM.intItemLocationId = cd.intItemLocationId
		AND byStockUOM.intItemUOMId = cd.intItemUOMId
		AND (
			((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
			((CASE WHEN cd.intSubLocationId = byStockUOM.intSubLocationId AND cd.intStorageLocationId = byStockUOM.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
			((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = byStockUOM.intSubLocationId THEN 0 ELSE 1 END) = 0)
		)
		AND (
			(c.strCountBy = 'Item' AND dbo.fnDateLessThanEquals(byStockUOM.dtmDate, c.dtmCountDate) = 1)
			OR (c.strCountBy = 'Retail Count' AND dbo.fnDateLessThan(byStockUOM.dtmDate, c.dtmCountDate) = 1) 
		)
		AND Item.strLotTracking = 'No'
		AND ISNULL(Item.ysnSeparateStockForUOMs, 0) = 0
	LEFT JOIN (
		SELECT 
			ss.intItemId
			, ss.intItemUOMId
			, ss.intItemLocationId
			, ss.intSubLocationId
			, ss.intStorageLocationId
			, dblOnHand =  SUM(COALESCE(ss.dblOnHand, 0.00))
			, dtmDate
		FROM vyuICGetRunningStockQtyByUOM ss
		GROUP BY 
			ss.intItemId,
			intItemUOMId,
			intItemLocationId,
			intSubLocationId,
			intStorageLocationId,
			dtmDate
	) separateUOM 
		ON separateUOM.intItemId = cd.intItemId
		AND separateUOM.intItemLocationId = cd.intItemLocationId
		AND separateUOM.intItemUOMId = cd.intItemUOMId
		AND (
			((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
			((CASE WHEN cd.intSubLocationId = separateUOM.intSubLocationId AND cd.intStorageLocationId = separateUOM.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
			((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = separateUOM.intSubLocationId THEN 0 ELSE 1 END) = 0)
		)
		AND (
			(c.strCountBy = 'Item' AND dbo.fnDateLessThanEquals(separateUOM.dtmDate, c.dtmCountDate) = 1)
			OR (c.strCountBy = 'Retail Count' AND dbo.fnDateLessThan(separateUOM.dtmDate, c.dtmCountDate) = 1) 
		)
		AND Item.strLotTracking = 'No'
		AND Item.ysnSeparateStockForUOMs = 1
	--LEFT OUTER JOIN (
	--	SELECT
	--		StockUOM.intItemId,
	--		StockUOM.intItemUOMId,
	--		intLocationId = ItemLoc.intLocationId,
	--		StockUOM.intItemLocationId,
	--		dblOnHand = ISNULL(StockUOM.dblOnHand, 0),
	--		StockUOM.intSubLocationId,
	--		StockUOM.intStorageLocationId
	--	FROM tblICItemStockUOM StockUOM
	--		INNER JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
	--		INNER JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
	--	WHERE Item.strLotTracking = 'No'
	--) nonLotted ON nonLotted.intItemId = cd.intItemId
	--	AND nonLotted.intItemLocationId = cd.intItemLocationId
	--	AND nonLotted.intItemUOMId = cd.intItemUOMId
	--	AND nonLotted.intSubLocationId = cd.intSubLocationId
	--	AND nonLotted.intStorageLocationId = cd.intStorageLocationId
	LEFT OUTER JOIN (
		SELECT
		Lot.strLotNumber,
		ISNULL(Lot.dblQty, 0) dblOnHand,
		ISNULL(Lot.dblWeight, 0) dblWeight,
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

DECLARE @OriginalCost TABLE(intInventoryCountDetailId INT,
	dblLastCost NUMERIC(38, 20) NULL)

INSERT INTO @OriginalCost
	(intInventoryCountDetailId , dblLastCost)
SELECT d.intInventoryCountDetailId, d.dblLastCost
FROM tblICInventoryCountDetail d
	INNER JOIN tblICInventoryCount c ON d.intInventoryCountId = d.intInventoryCountId
WHERE c.intImportFlagInternal = 1

-- Update Last Cost, Calculate Physical Count, Physical Weight, & Qty Per Pallet
UPDATE cd
SET cd.dblLastCost = --ISNULL(cd.dblLastCost, ISNULL(dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ISNULL(ItemLot.dblLastCost, ItemPricing.dblLastCost)), 0)),
						ISNULL(CASE 
							WHEN ItemLocation.intCostingMethod = 1 AND Item.strLotTracking = 'No'  THEN -- AVG
								COALESCE(EffectivePricing.dblCost, dbo.fnGetItemAverageCost(
									cd.intItemId
									, ItemLocation.intItemLocationId
									, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
								))
							WHEN ItemLocation.intCostingMethod = 2 AND Item.strLotTracking = 'No' THEN -- FIFO
								dbo.fnCalculateCostBetweenUOM(
									COALESCE(FIFO.intItemUOMId, StockUOM.intItemUOMId)
									,COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
									,COALESCE(EffectivePricing.dblCost, FIFO.dblCost, ItemPricing.dblLastCost)
								)
							WHEN ItemLocation.intCostingMethod = 3 AND Item.strLotTracking = 'No' THEN -- LIFO
								dbo.fnCalculateCostBetweenUOM(
									StockUOM.intItemUOMId
									, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
									, COALESCE(EffectivePricing.dblCost, ItemPricing.dblLastCost)
								)
							WHEN Item.strLotTracking != 'No' THEN
								dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ISNULL(ItemLot.dblLastCost, ItemPricing.dblLastCost))
							ELSE
								dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost)
						END, NULL),
	cd.dblNetQty = CAST(CASE WHEN cd.intWeightUOMId IS NOT NULL THEN CASE WHEN NULLIF(cd.dblPhysicalCount, 0) IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(cd.intItemUOMId, cd.intWeightUOMId, cd.dblPhysicalCount) ELSE cd.dblNetQty END ELSE NULL END AS NUMERIC(38, 20)),
	cd.dblPhysicalCount = CAST(
		CASE 
			WHEN ISNULL(cd.dblPallets, 0) <> 0 AND ISNULL(cd.dblQtyPerPallet, 0) <> 0 THEN cd.dblPallets * cd.dblQtyPerPallet
			WHEN NULLIF(cd.dblPhysicalCount, 0) IS NULL AND cd.intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(cd.intWeightUOMId, cd.intItemUOMId, cd.dblNetQty)
			ELSE cd.dblPhysicalCount
		END AS NUMERIC(38, 20))
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
	INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = c.intLocationId
		AND ItemLocation.intItemId = cd.intItemId
	LEFT JOIN dbo.tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		AND ItemPricing.intItemId = ItemLocation.intItemId
	LEFT JOIN dbo.tblICItemUOM ItemUOM ON cd.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItem Item ON Item.intItemId = cd.intItemId
	LEFT JOIN dbo.tblICLot ItemLot ON ItemLot.intLotId = cd.intLotId AND Item.strLotTracking <> 'No'
	LEFT JOIN dbo.tblICItemUOM StockUOM ON cd.intItemId = StockUOM.intItemId AND StockUOM.ysnStockUnit = 1
	OUTER APPLY(
		SELECT TOP 1
		dblCost
				, intItemUOMId
	FROM tblICInventoryFIFO FIFO
	WHERE	Item.intItemId = FIFO.intItemId
		AND ItemLocation.intItemLocationId = FIFO.intItemLocationId
		AND dblStockIn - dblStockOut > 0
		AND dbo.fnDateLessThanEquals(dtmDate, c.dtmCountDate) = 1
	ORDER BY dtmDate ASC
	) FIFO 
	OUTER APPLY dbo.fnICGetItemCostByEffectiveDate(c.dtmCountDate, cd.intItemId, cd.intItemLocationId, 0) EffectivePricing	 
WHERE c.intImportFlagInternal = 1


UPDATE cd
SET cd.dblLastCost = CASE WHEN ISNULL(cd.dblPhysicalCount, 0) > ISNULL(cd.dblSystemCount, 0) 
	THEN COALESCE(EffectivePricing.dblCost, ISNULL(oc.dblLastCost, COALESCE(NULLIF(cd.dblLastCost, 0), NULLIF(p.dblLastCost, 0), p.dblStandardCost)))
	ELSE COALESCE(EffectivePricing.dblCost, NULLIF(cd.dblLastCost, 0), NULLIF(p.dblLastCost, 0), p.dblStandardCost) END
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
	INNER JOIN @OriginalCost oc ON oc.intInventoryCountDetailId = cd.intInventoryCountDetailId
	LEFT OUTER JOIN tblICItemPricing p ON p.intItemId = cd.intItemId
		AND p.intItemLocationId = cd.intItemLocationId
	OUTER APPLY dbo.fnICGetItemCostByEffectiveDate(c.dtmCountDate, cd.intItemId, cd.intItemLocationId, 0) EffectivePricing	 
WHERE c.intImportFlagInternal = 1

-- Others
UPDATE c
SET c.strCountBy = CASE WHEN strCountBy = 'Pack' THEN 'Pack' ELSE 'Item' END
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
DECLARE @intLocationId INT
DECLARE @Prefix NVARCHAR(50)
DECLARE cur CURSOR FOR

SELECT DISTINCT c.intInventoryCountId, c.intLocationId
FROM tblICInventoryCount c
WHERE c.intImportFlagInternal = 1

OPEN cur

FETCH NEXT FROM cur INTO @Id, @intLocationId

WHILE @@FETCH_STATUS = 0
BEGIN
	-- UPDATE tblSMStartingNumber
	-- SET intNumber = intNumber + 1
	-- WHERE strTransactionType = 'Inventory Count'

	SELECT @Prefix = strPrefix + CAST(intNumber AS NVARCHAR(50))
	FROM tblSMStartingNumber
	WHERE strTransactionType = 'Inventory Count'

	UPDATE tblICInventoryCount
	SET strCountNo = @Prefix
	WHERE intInventoryCountId = @Id

	DECLARE @strTransactionId NVARCHAR(100)

	EXEC dbo.uspSMGetStartingNumber 76, @strTransactionId OUTPUT, @intLocationId

	;WITH
		rows_num
		AS
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

	FETCH NEXT FROM cur	INTO @Id, @intLocationId
END

CLOSE cur
DEALLOCATE cur

-- Auto-create Lot
-- Create the temp table 
--IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
--BEGIN 
--	CREATE TABLE #GeneratedLotItems (
--		intLotId INT
--		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
--		,intDetailId INT 
--		,intParentLotId INT
--		,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
--	)
--END

--DECLARE @Lots ItemLotTableType

--INSERT INTO @Lots(
--	  intItemId
--	, intItemLocationId
--	, intItemUOMId
--	, strLotNumber
--	, intSubLocationId
--	, intStorageLocationId
--	, dblQty
--	, intLotId
--	, intLotStatusId
--	, intDetailId
--)
--SELECT 
--	  intItemId				= d.intItemId
--	, intItemLocationId		= d.intItemLocationId
--	, intItemUOMId			= d.intItemUOMId
--	, strLotNumber			= d.strAutoCreatedLotNumber
--	, intSubLocationId		= d.intSubLocationId
--	, intStorageLocationId	= d.intStorageLocationId
--	, dblQty				= ISNULL(d.dblSystemCount, 0)
--	, intLotId				= CASE NULLIF(d.strAutoCreatedLotNumber, '') WHEN NULL THEN d.intLotId ELSE NULL END
--	, intLotStatusId		= 1
--	, intDetailId			= d.intInventoryCountDetailId
--FROM tblICInventoryCountDetail d
--	INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = d.intInventoryCountId
--	INNER JOIN tblICItem Item ON Item.intItemId = d.intItemId
--			AND Item.strLotTracking <> 'No'
--WHERE c.intImportFlagInternal = 1

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
SET ic.intImportFlagInternal = NULL, ic.strDataSource = 'Import CSV'
FROM tblICInventoryCount ic
WHERE ic.intImportFlagInternal = 1