CREATE PROCEDURE [dbo].[uspICUpdateDetailsForRecount]
	  @intReferenceCountId INT
	, @intNewCountId INT
	, @intEntityUserSecurityId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strNewCountLine NVARCHAR(50)
SELECT @strNewCountLine = strCountNo FROM tblICInventoryCount WHERE intInventoryCountId = @intNewCountId

INSERT INTO tblICInventoryCountDetail(
			  intInventoryCountId
			, intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intCountGroupId
			, intLotId
			, strLotNo
			, strLotAlias
			, intParentLotId
			, strParentLotNo
			, strParentLotAlias
			, intStockUOMId
			, dblSystemCount
			, dblLastCost
			, strAutoCreatedLotNumber
			, strCountLine
			, dblPallets
			, dblQtyPerPallet
			, dblPhysicalCount
			, intItemUOMId
			, intWeightUOMId
			, dblWeightQty
			, dblNetQty
			, ysnRecount
			, dblQtyReceived
			, dblQtySold
			, intEntityUserSecurityId
			, ysnFetched
			, intSort
			, intConcurrencyId)
SELECT @intNewCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intCountGroupId
		, intLotId
		, strLotNo
		, strLotAlias
		, intParentLotId
		, strParentLotNo
		, strParentLotAlias
		, intStockUOMId
		, dblSystemCount
		, dblLastCost
		, strAutoCreatedLotNumber
		, strCountLine = @strNewCountLine + '-' + CAST(ROW_NUMBER() OVER(ORDER BY intInventoryCountDetailId ASC) AS NVARCHAR(50))
		, dblPallets
		, dblQtyPerPallet
		, dblPhysicalCount
		, intItemUOMId
		, intWeightUOMId
		, dblWeightQty
		, dblNetQty
		, ysnRecount = 0
		, dblQtyReceived
		, dblQtySold
		, intEntityUserSecurityId
		, ysnFetched
		, intSort
		, intConcurrencyId
FROM tblICInventoryCountDetail
WHERE ysnRecount = 1
	AND intInventoryCountId = @intReferenceCountId