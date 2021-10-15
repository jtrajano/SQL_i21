CREATE VIEW [dbo].[vyuICGetInventoryDailyValuation]
AS

SELECT	t.intId 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,i.intCommodityId
		,strCommodity				= commodity.strCommodityCode
		,intLocationId				= t.intCompanyLocationId 
		,t.intItemLocationId
		,strLocationName			= [location].strLocationName 
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= t.dtmDate 		
		,dblQuantity				= ISNULL(t.dblQty, 0)
		,dblValue					= ISNULL(t.dblValue, 0)
		,dblValueRounded			= ISNULL(t.dblValueRounded, 0)
		,dblQuantityInStockUOM		= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,ysnInTransit				= CAST(CASE WHEN t.intInTransitSourceLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
FROM 	tblICInventoryDailyTransaction t 
		INNER JOIN tblICItem i 
			ON t.intItemId = i.intItemId
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId			
					,umStock.strUnitMeasure
			FROM	tblICItemUOM iuStock INNER JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	iuStock.intItemId = i.intItemId
					AND iuStock.ysnStockUnit = 1 
		) iuStock
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity commodity
			ON commodity.intCommodityId = i.intCommodityId		
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId

		LEFT JOIN tblSMCompanyLocation [location]
			ON [location].intCompanyLocationId = t.intCompanyLocationId

		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId
		LEFT JOIN (
			tblICItemUOM iuTransUOM INNER JOIN tblICUnitMeasure umTransUOM
				ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId			
		)
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICItemPricing ItemPricing
			ON ItemPricing.intItemId = i.intItemId
			AND ItemPricing.intItemLocationId = t.intItemLocationId

WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)