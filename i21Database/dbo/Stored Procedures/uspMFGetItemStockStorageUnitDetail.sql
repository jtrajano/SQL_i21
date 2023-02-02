CREATE PROCEDURE uspMFGetItemStockStorageUnitDetail 
(
	@intItemId				INT
  , @intItemUOMId			INT
  , @intLocationId			INT
  , @strStorageLocationName NVARCHAR(50) = ''
  , @strSubLocationName		NVARCHAR(50) = ''
)
AS
BEGIN
	SELECT Item.intItemId
	     , StockUOM.intStorageLocationId
	FROM tblICItem AS Item
	LEFT JOIN tblICItemLocation AS ItemLocation ON Item.intItemId = ItemLocation.intItemId AND ItemLocation.intLocationId = @intLocationId
	LEFT JOIN tblICItemStockUOM AS StockUOM ON ItemLocation.intItemLocationId = StockUOM.intItemLocationId 
	LEFT JOIN tblICItemUOM AS ItemUOM ON  Item.intItemId = ItemUOM.intItemId
	LEFT JOIN tblICStorageLocation AS StorageLocation ON StockUOM.intStorageLocationId = StorageLocation.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation AS SubLocation ON StockUOM.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
	WHERE Item.intItemId = @intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemUOM.intItemUOMId = @intItemUOMId
	  AND ISNULL(StorageLocation.strName, '') = (CASE WHEN @strStorageLocationName = '' THEN ISNULL(StorageLocation.strName, '') ELSE @strStorageLocationName END)
	  AND ISNULL(SubLocation.strSubLocationName, '') = (CASE WHEN @strSubLocationName = '' THEN ISNULL(SubLocation.strSubLocationName, '') ELSE @strSubLocationName END)
END