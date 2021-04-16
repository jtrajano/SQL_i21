CREATE PROCEDURE [dbo].[uspICUpdateInventoryCountDetails]
	  @intInventoryCountId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intLocationId INT = 0
	, @intCategoryId INT = 0
	, @intCommodityId INT = 0
	, @intCountGroupId INT = 0
	, @intSubLocationId INT = 0
	, @intStorageLocationId INT = 0
	, @ysnIncludeZeroOnHand BIT = 0
	, @ysnCountByLots BIT = 0
	, @AsOfDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE FROM tblICInventoryCountDetail
WHERE intInventoryCountId = @intInventoryCountId

IF @ysnCountByLots = 1
BEGIN
	INSERT INTO tblICInventoryCountDetail(
		  intInventoryCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intParentLotId
		, strParentLotNo
		, strParentLotAlias
		, intLotId
		, strLotNo
		, strLotAlias
		, dblSystemCount
		, dblWeightQty
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort
		, dblPhysicalCount
	)
	SELECT 	intInventoryCountId = @intInventoryCountId
			, Item.intItemId
			, ItemLocation.intItemLocationId
			, Lot.intSubLocationId
			, Lot.intStorageLocationId
			, Lot.intParentLotId
			, ParentLot.strParentLotNumber
			, ParentLot.strParentLotAlias
			, Lot.intLotId
			, Lot.strLotNumber
			, Lot.strLotAlias
			, dblSystemCount = ISNULL(Transactions.dblOnHand, 0)
			, dblWeightQty = Lot.dblWeight
			, dblLastCost = ISNULL(LastTransaction.dblCost, 0)
			, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY Lot.intItemId ASC) AS NVARCHAR(50))
			, Lot.intItemUOMId
			, Lot.intWeightUOMId
			, ysnRecount = 0
			, ysnFetched = 1
			, intEntityUserSecurityId = @intEntityUserSecurityId
			, intConcurrencyId = 1
			, intSort = 1
			, dblPhysicalCount = NULL
	FROM tblICLot Lot
		INNER JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
		INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = Lot.intItemLocationId
		INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
			AND StockUOM.ysnStockUnit = 1
		LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId
		CROSS APPLY (
			SELECT					
				 dblOnHand = SUM(t.dblQty)
			FROM 
				tblICInventoryTransaction t
			WHERE 
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				AND t.intSubLocationId = Lot.intSubLocationId
				AND t.intStorageLocationId = Lot.intStorageLocationId
				AND t.intLotId = Lot.intLotId
				AND t.intItemUOMId = Lot.intItemUOMId						
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@AsOfDate AS FLOAT))
		) Transactions 		
		CROSS APPLY (
			SELECT TOP 1 
				 dblCost = t.dblCost
			FROM 
				tblICInventoryTransaction t
			WHERE 
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				AND t.intSubLocationId = Lot.intSubLocationId
				AND t.intStorageLocationId = Lot.intStorageLocationId
				AND t.intLotId = Lot.intLotId
				AND t.intItemUOMId = Lot.intItemUOMId						
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@AsOfDate AS FLOAT))
			ORDER BY
				t.intInventoryTransactionId DESC 
		) LastTransaction  			
	WHERE 
		(ItemLocation.intLocationId = @intLocationId OR ISNULL(@intLocationId, 0) = 0)
		AND (intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND (intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (Lot.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0)
		AND (Lot.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0)	
		AND Item.strLotTracking <> 'No'
		AND ((Transactions.dblOnHand <> 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
END
ELSE
BEGIN
	INSERT INTO tblICInventoryCountDetail (
		  intInventoryCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intLotId
		, dblSystemCount
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort
		, dblPhysicalCount
	)
	SELECT
		intInventoryCountId = @intInventoryCountId
		, intItemId = il.intItemId
		, intItemLocationId = COALESCE(stock.intItemLocationId, il.intItemLocationId)
		, intSubLocationId = stock.intSubLocationId
		, intStorageLocationId = stock.intStorageLocationId
		, intLotId = NULL
		, dblSystemCount = ISNULL(stockUnit.dblOnHand, 0) 
		, dblLastCost = 
			-- Convert the last cost from Stock UOM to stock.intItemUOMId
			CASE 
				-- Get the average cost. 
				WHEN il.intCostingMethod = 1 THEN 				
					dbo.fnCalculateCostBetweenUOM (
						stockUOM.intItemUOMId
						,COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						,ISNULL(
							dbo.fnICGetMovingAverageCost(
								i.intItemId
								,il.intItemLocationId
								,lastTransaction.intInventoryTransactionId
							
							)
							,p.dblLastCost
						)					
					)
					
				-- Get the last cost from the transactions
				WHEN lastTransaction.dblCost IS NOT NULL THEN 
					dbo.fnCalculateQtyBetweenUOM (
						lastTransaction.intItemUOMId
						, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						, lastTransaction.dblCost
					)

				-- If all above fails, use the item pricing's last cost. 
				ELSE 				
					dbo.fnCalculateQtyBetweenUOM (
						stockUOM.intItemUOMId
						, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						, p.dblLastCost
					)					
			END

		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY il.intItemId ASC, il.intItemLocationId ASC, stockUOM.intItemUOMId ASC) AS NVARCHAR(50))
		, intItemUOMId = COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
		, NULL
	FROM 
		tblICItemLocation il
		INNER JOIN tblICItemPricing p 
			ON p.intItemLocationId = il.intItemLocationId
			AND p.intItemId = il.intItemId
		INNER JOIN tblICItemUOM stockUOM 
			ON stockUOM.intItemId = il.intItemId
			AND stockUOM.ysnStockUnit = 1
		INNER JOIN tblICItem i 
			ON i.intItemId = il.intItemId
		OUTER APPLY (
			SELECT	intItemId
					,intItemUOMId
					,intItemLocationId
					,intSubLocationId
					,intStorageLocationId
					,dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
					,dblLastCost = MAX(dblLastCost)
			FROM	vyuICGetItemStockSummary summary
			WHERE	
				summary.intItemId = i.intItemId
				AND summary.intItemUOMId = stockUOM.intItemUOMId
				AND summary.intItemLocationId = il.intItemLocationId
				AND FLOOR(CAST(dtmDate AS FLOAT)) <= FLOOR(CAST(@AsOfDate AS FLOAT))
			GROUP BY 
					intItemId,
					intItemUOMId,
					intItemLocationId,
					intSubLocationId,
					intStorageLocationId
		) stock
		OUTER APPLY (
			SELECT	 st.intItemId
					,st.intItemLocationId
					,st.intSubLocationId
					,st.intStorageLocationId
					,st.intLocationId
					,dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(st.intItemUOMId, suom.intItemUOMId, ISNULL(st.dblOnHand, 0.00)))
					,dblLastCost = MAX(dblLastCost)
			FROM	
				vyuICGetItemStockSummary st
				LEFT OUTER JOIN tblICItemUOM suom 
					ON suom.intItemId = st.intItemId
					AND suom.ysnStockUnit = 1
			WHERE				
				st.intItemId = i.intItemId
				AND st.intItemLocationId = il.intItemLocationId
				AND st.intLocationId = il.intLocationId
				AND ISNULL(st.intStorageLocationId, 0) = ISNULL(stock.intStorageLocationId, 0)
				AND ISNULL(st.intSubLocationId, 0) = ISNULL(stock.intSubLocationId, 0)
				AND FLOOR(CAST(dtmDate AS FLOAT)) <= FLOOR(CAST(@AsOfDate AS FLOAT))
			GROUP BY 
					st.intItemId,
					st.intItemLocationId,
					st.intSubLocationId,
					st.intStorageLocationId,
					st.intLocationId
		) stockUnit

		-- last transaction
		OUTER APPLY (
			SELECT
				TOP 1 
				t.intItemUOMId
				,t.dblCost
				,t.intInventoryTransactionId
			FROM 
				tblICInventoryTransaction t
			WHERE 
				t.intItemId = i.intItemId
				AND t.intItemLocationId = il.intItemLocationId 
				AND t.dblQty > 0 
				AND ISNULL(t.ysnIsUnposted, 0) = 0 
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@AsOfDate AS FLOAT))			
			ORDER BY
				t.intInventoryTransactionId DESC 		
		) lastTransaction 

	WHERE 
		il.intLocationId = @intLocationId
		AND ((stock.dblOnHand <> 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (i.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (i.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND ((@intSubLocationId IS NULL) OR (stock.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0))
		AND ((@intStorageLocationId IS NULL) OR (stock.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))
		AND i.strLotTracking = 'No'	
END
