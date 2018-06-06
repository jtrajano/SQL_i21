CREATE PROCEDURE [dbo].[uspSTUpdateShiftPhysical]
	  @intCheckoutId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intCompanyLocationId INT = 0
	, @intCategoryId INT = 0
	, @intCommodityId INT = 0
	, @intCountGroupId INT = 0
	, @intCompanyLocationSubLocationId INT = 0
	, @intStorageLocationId INT = 0
	, @ysnIncludeZeroOnHand BIT = 0
	, @ysnCountByLots BIT = 0
	, @strStatusMsg NVARCHAR(1000) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
SET @strStatusMsg = 'Success'

DELETE FROM tblSTCheckoutShiftPhysical
WHERE intCheckoutId = @intCheckoutId

IF @ysnCountByLots = 1
BEGIN
	INSERT INTO tblSTCheckoutShiftPhysical(
		  intCheckoutId
		, intItemId
		, intItemLocationId
		, intCompanyLocationSubLocationId
		, intStorageLocationId
		, intParentLotId
		, strParentLotNo
		, strParentLotAlias
		, intLotId
		, strLotNo
		, strLotAlias
		, dblSystemCount
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort)
	SELECT 
		  @intCheckoutId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intParentLotId
		, strParentLotNumber
		, strParentLotAlias
		, intLotId
		, strLotNumber
		, strLotAlias
		, dblSystemCount = dblLotQty
		, dblLastCost
		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY intKey ASC) AS NVARCHAR(50))
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
	FROM vyuICGetItemStockSummaryByLot
	WHERE (intLocationId = @intCompanyLocationId OR ISNULL(@intCompanyLocationId, 0) = 0)
		AND (intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND (intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (intSubLocationId = @intCompanyLocationSubLocationId OR ISNULL(@intCompanyLocationSubLocationId, 0) = 0)
		AND (intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0)
		AND ((dblLotQty > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND strLotTracking <> 'No'		
END

ELSE
BEGIN
	INSERT INTO tblSTCheckoutShiftPhysical(
		  intCheckoutId
		, intItemId
		, intItemLocationId
		, intCompanyLocationSubLocationId
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
		, intSort)
	SELECT
		intCheckoutId = @intCheckoutId
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
		, ysnFetched = 1
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
	WHERE il.intLocationId = @intCompanyLocationId
		AND ((stock.dblOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (i.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (i.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND ((il.intSubLocationId IS NULL) OR (il.intSubLocationId = @intCompanyLocationSubLocationId OR ISNULL(@intCompanyLocationSubLocationId, 0) = 0))
		AND ((il.intStorageLocationId IS NULL) OR (il.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))
		AND i.strLotTracking = 'No'

END


END TRY
BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
END CATCH