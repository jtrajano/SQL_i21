﻿CREATE PROCEDURE [dbo].[uspICUpdateInventoryCountDetails]
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
		, intLotId
		, strLotNo
		, strLotAlias
		, dblSystemCount
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort)
	SELECT 
		  @intInventoryCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intLotId
		, strLotNumber
		, strLotAlias
		, dblSystemCount = dblOnHand
		, dblLastCost
		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY intKey ASC) AS NVARCHAR(50))
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount = 0
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
	FROM vyuICGetItemStockSummaryByLot
	WHERE (intLocationId = @intLocationId OR ISNULL(@intLocationId, 0) = 0)
		AND (intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND (intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0)
		AND (intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0)
		AND ((dblOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND strLotTracking <> 'No'		
END
ELSE
BEGIN
	INSERT INTO tblICInventoryCountDetail(
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
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort)
	SELECT
		intInventoryCountId = @intInventoryCountId
		, intItemId = il.intItemId
		, intItemLocationId = COALESCE(stock.intItemLocationId, il.intItemLocationId)
		, intSubLocationId = COALESCE(stock.intSubLocationId, il.intSubLocationId)
		, intStorageLocationId = COALESCE(stock.intStorageLocationId, il.intStorageLocationId)
		, intLotId = NULL
		, dblSystemCount = COALESCE(stock.dblOnHand, 0.00)
		, dblLastCost = COALESCE(stock.dblLastCost, p.dblLastCost)
		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY il.intItemId ASC, il.intItemLocationId ASC, uom.intItemUOMId ASC) AS NVARCHAR(50))
		, intItemUOMId = COALESCE(stock.intItemUOMId, uom.intItemUOMId)
		, ysnRecount = 0
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
	FROM tblICItemLocation il
		INNER JOIN tblICItemPricing p ON p.intItemLocationId = il.intItemLocationId
			AND p.intItemId = il.intItemId
		INNER JOIN tblICItemUOM uom ON uom.intItemId = il.intItemId
			AND uom.ysnStockUnit = 1
		INNER JOIN tblICItem i ON i.intItemId = il.intItemId
		LEFT JOIN vyuICGetItemStockSummary stock ON stock.intItemId = i.intItemId
			AND uom.intItemUOMId = stock.intItemUOMId
	WHERE il.intLocationId = @intLocationId
		AND ((stock.dblOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (i.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (i.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND ((il.intSubLocationId IS NULL) OR (il.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0))
		AND ((il.intStorageLocationId IS NULL) OR (il.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))
		AND i.strLotTracking = 'No'
END