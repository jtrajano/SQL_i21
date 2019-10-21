CREATE VIEW [dbo].[vyuICGetStorageUnitStock]
AS
SELECT
    intStorageUnitId		= StorageLocation.intStorageLocationId
	, strStorageUnit		= StorageLocation.strName
	, strItemNo				= Item.strItemNo
	, intItemId				= Item.intItemId
	, intCommodityId		= Item.intCommodityId
	, strCommodityCode		= Commodity.strCommodityCode
	, intLocationId			= StorageLocation.intLocationId
	, strLocation			= CompLocation.strLocationName
	, intStorageLocationId	= SubLocation.intCompanyLocationSubLocationId
	, strStorageLocation	= SubLocation.strSubLocationName		
	, dblLastCost			= ISNULL(ItemPricing.dblLastCost, ItemPricing.dblStandardCost)
	, dblOnHand				= ISNULL(StockUOM.dblOnHand, 0)
	, strUnitMeasure		= UOM.strUnitMeasure
	, dblEffectiveDepth		= StorageLocation.dblEffectiveDepth
	, dblResidualUnit		= StorageLocation.dblResidualUnit
	, dblUnitPerFoot		= StorageLocation.dblUnitPerFoot
	, dblPackFactor			= StorageLocation.dblPackFactor
	, strUPC				= ItemUOM.strUpcCode
	, strLongUPC			= ItemUOM.strLongUPCCode
FROM 
	tblICStorageLocation StorageLocation 
	LEFT JOIN (
		tblICItem Item INNER JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1
		INNER JOIN tblICUnitMeasure UOM 
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId AND UOM.strUnitType IN('Volume', 'Weight')
		LEFT JOIN tblICItemStockUOM StockUOM 
			ON StockUOM.intItemId = Item.intItemId AND StockUOM.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN tblICCommodity Commodity 
			ON Commodity.intCommodityId = Item.intCommodityId
	)
		ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
	LEFT JOIN tblSMCompanyLocation CompLocation 
		ON CompLocation.intCompanyLocationId = StorageLocation.intLocationId
	OUTER APPLY (
		SELECT Scat.*
		FROM tblICStorageLocationCategory Scat
		WHERE Scat.intStorageLocationId = StorageLocation.intStorageLocationId
		AND Item.intCategoryId = Scat.intCategoryId
	) AllowedCategory
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = StorageLocation.intSubLocationId
	OUTER APPLY (
		SELECT 
			ItemPricing.*
		FROM 
			tblICItemLocation ItemLoc LEFT JOIN tblICItemPricing ItemPricing 
				ON ItemPricing.intItemLocationId = ItemLoc.intItemLocationId
		WHERE
			ItemLoc.intItemId = Item.intItemId
			AND ItemLoc.intLocationId = StorageLocation.intLocationId	
	) ItemPricing
	WHERE AllowedCategory.intCategoryId = Item.intCategoryId OR 
		NOT EXISTS(SELECT Scat.*
			FROM tblICStorageLocationCategory Scat
			WHERE Scat.intStorageLocationId = StorageLocation.intStorageLocationId
		)