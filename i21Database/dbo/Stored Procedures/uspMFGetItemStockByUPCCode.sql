CREATE PROCEDURE dbo.uspMFGetItemStockByUPCCode 
(
	@strUPCCode			  NVARCHAR(50)
  , @intLocationId		  INT
  , @intStorageLocationId INT = NULL
)
AS
DECLARE @intItemUOMId		INT
	  , @intItemId			INT
	  , @intItemLocationId	INT

SELECT @intItemUOMId = ItemUOM.intItemUOMId
	 , @intItemId	 = ItemUOM.intItemId
FROM tblICItemUOM AS ItemUOM
JOIN tblICItem AS Item ON Item.intItemId = ItemUOM.intItemId
LEFT JOIN tblICItemUomUpc AS ItemUPC ON ItemUPC.intItemUOMId = ItemUOM.intItemUOMId
WHERE ItemUPC.strLongUpcCode = @strUPCCode OR ItemUOM.strLongUPCCode = @strUPCCode;

SELECT @intItemLocationId = intItemLocationId
FROM tblICItemLocation
WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId


SELECT Item.intItemId
		, Item.strItemNo
		, Item.strDescription
		, ItemUOM.strLongUPCCode AS strUPCCode
		, ItemUOM.strUpcCode AS strShortUpcCode
		, dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, StockUOM.dblOnHand) AS dblOnHandQty
		, dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, StockUOM.dblUnitReserved) AS dblReservedQty
		, dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, StockUOM.dblOnHand) - dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, StockUOM.dblUnitReserved) AS dblAvailableQty
		, @intItemUOMId AS intItemUOMId
		, UnitOfMeasure.intUnitMeasureId
		, UnitOfMeasure.strUnitMeasure
		, StockUOM.intStorageLocationId
		, StorageLocation.strName AS strStorageUnit
		, StockUOM.intSubLocationId
		, SubLocation.strSubLocationName AS strStorageLocation
		, ItemLocation.intItemLocationId
FROM tblICItem AS Item
LEFT JOIN tblICItemStockUOM AS StockUOM ON Item.intItemId = StockUOM.intItemId
LEFT JOIN tblICItemLocation AS ItemLocation ON Item.intItemId = ItemLocation.intItemId
LEFT JOIN tblICItemUOM AS ItemUOM ON  Item.intItemId = ItemUOM.intItemId
LEFT JOIN tblICStorageLocation AS StorageLocation ON StockUOM.intStorageLocationId = StorageLocation.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation AS SubLocation ON StockUOM.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
LEFT JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
WHERE Item.intItemId = @intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemUOM.intItemUOMId = @intItemUOMId
	/* Non required storage units. */
	AND ((NULLIF(@intStorageLocationId, '') IS NULL OR @intStorageLocationId = 0 OR @intStorageLocationId IS NULL) 
	/* Required storage units. */
	OR (@intStorageLocationId IS NOT NULL AND StockUOM.intStorageLocationId = @intStorageLocationId))

