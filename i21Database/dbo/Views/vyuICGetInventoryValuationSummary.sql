﻿CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
AS

SELECT	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY t.intYear DESC, t.intMonth DESC) AS INT)
		,Item.intItemId
		,strItemNo = Item.strItemNo
		,strItemDescription = Item.strDescription 
		,intItemLocationId = t.intItemLocationId
		,strLocationName = ISNULL(Location.strLocationName, InTransitLocation.strLocationName + ' (' + ItemLocation.strDescription + ')') 
		--,intSubLocationId = t.intSubLocationId
		--,strSubLocationName = SubLocation.strSubLocationName
		,t.intYear
		,t.intMonth
		,strMonthYear = FORMAT(t.dtmMaxDate, 'MMM yyyy')
		,dblQuantity = ISNULL(dblQuantity, 0)
		,dblValue = ISNULL(dblValue, 0)
		,dblLastCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblLastCost, 2), 0)
		,dblStandardCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblStandardCost, 2),0)
		,dblAverageCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblAverageCost, 2),0)
		,t.strStockUOM
		,t.dblQuantityInStockUOM
		,Category.strCategoryCode
		,Commodity.strCommodityCode
		,strInTransitLocationName = InTransitLocation.strLocationName
		,intLocationId = Location.intCompanyLocationId
		,intInTransitLocationId = InTransitLocation.intCompanyLocationId
FROM	tblICItem Item 
		OUTER APPLY (
			SELECT 
					t.intItemLocationId
					,dtmMaxDate = MAX(t.dtmDate)
					,intYear = YEAR(t.dtmDate)
					,intMonth = MONTH(t.dtmDate)
					, intInTransitSourceLocationId = CASE WHEN t.intItemLocationId <> t.intInTransitSourceLocationId THEN t.intInTransitSourceLocationId ELSE NULL END 
					, dblQuantity = SUM(t.dblQty * t.dblUOMQty) 
					, dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
					, strStockUOM = umStock.strUnitMeasure
					, dblQuantityInStockUOM = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0))
			FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation l
						ON t.intItemLocationId = l.intItemLocationId
					LEFT JOIN tblICItemUOM iuStock 
						ON iuStock.intItemId = t.intItemId
						--AND iuStock.ysnStockUnit = 1
						AND iuStock.ysnStockUOM = 1
					LEFT JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	Item.intItemId = t.intItemId
			GROUP BY 
				t.intItemLocationId
				,YEAR(t.dtmDate)
				,MONTH(t.dtmDate)
				,CASE WHEN t.intItemLocationId <> t.intInTransitSourceLocationId THEN t.intInTransitSourceLocationId ELSE NULL END  
				,umStock.strUnitMeasure
		) t							
		LEFT JOIN (
			tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation Location 
				ON Location.intCompanyLocationId = ItemLocation.intLocationId		
		)
			ON t.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN (
			tblICItemLocation InTransitItemLocation INNER JOIN tblSMCompanyLocation InTransitLocation 
				ON InTransitLocation.intCompanyLocationId = InTransitItemLocation.intLocationId	
		)
			ON t.intInTransitSourceLocationId = InTransitItemLocation.intItemLocationId

		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = t.intItemLocationId
		
		LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
		LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId

WHERE	Item.strType NOT IN ('Other Charge', 'Non-Inventory', 'Service', 'Software', 'Comment')