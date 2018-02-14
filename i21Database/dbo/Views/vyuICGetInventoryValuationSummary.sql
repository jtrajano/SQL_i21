CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
AS

SELECT	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY Item.intItemId) AS INT)
		,Item.intItemId
		,strItemNo = Item.strItemNo
		,strItemDescription = Item.strDescription 
		,ItemLocation.intItemLocationId
		,strLocationName = 
				CASE WHEN t.ysnInTransit = 1 THEN 
						[Location].strLocationName + ' (In-Transit)'
					ELSE 
						[Location].strLocationName
				END 
		,strMonthYear = FORMAT(DATEFROMPARTS(t.intYear, t.intMonth, 1), 'yyyy-MM')  
		,dblQuantity = ISNULL(dblQuantity, 0)
		,dblValue = ISNULL(dblValue, 0)
		,dblLastCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblLastCost, 2), 0)
		,dblStandardCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblStandardCost, 2),0)
		,dblAverageCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblAverageCost, 2),0)
		,strStockUOM = umStock.strUnitMeasure
		,t.dblQuantityInStockUOM
		,Category.strCategoryCode
		,Commodity.strCommodityCode
		,strInTransitLocationName = ''
		,t.intLocationId
		,intInTransitLocationId = null  
		,t.ysnInTransit
FROM	tblICItem Item 
		LEFT JOIN tblICCategory Category 
			ON Category.intCategoryId = Item.intCategoryId

		LEFT JOIN tblICCommodity Commodity 
			ON Commodity.intCommodityId = Item.intCommodityId

		OUTER APPLY (
			SELECT 
					intLocationId = ISNULL(InTransit.intLocationId, l.intLocationId) 
					,ysnInTransit = CASE WHEN l.intLocationId IS NULL THEN 1 ELSE 0 END 
					,intMonth = MONTH(t.dtmDate)
					,intYear = YEAR(t.dtmDate) 
					,dblQuantity = SUM(ISNULL(t.dblQty, 0)) 
					,dblQuantityInStockUOM = SUM(ISNULL(t.dblQty, 0) * ISNULL(t.dblUOMQty, 1)) 
					,dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))					
			FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation l
						ON t.intItemLocationId = l.intItemLocationId
					LEFT JOIN tblICItemLocation InTransit
						ON InTransit.intItemLocationId = t.intInTransitSourceLocationId
						AND t.intInTransitSourceLocationId IS NOT NULL 
			WHERE	Item.intItemId = t.intItemId
			GROUP BY 
				ISNULL(InTransit.intLocationId, l.intLocationId) 
				,CASE WHEN l.intLocationId IS NULL THEN 1 ELSE 0 END 
				,MONTH(t.dtmDate)
				,YEAR(t.dtmDate) 
		) t							

		LEFT JOIN tblICItemLocation ItemLocation 
			ON ItemLocation.intLocationId = t.intLocationId
			AND ItemLocation.intItemId = Item.intItemId 

		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId	

		LEFT JOIN tblSMCompanyLocation [Location]
			ON [Location].intCompanyLocationId = t.intLocationId

		LEFT JOIN tblICItemUOM iuStock 
			ON iuStock.intItemId = Item.intItemId
			AND iuStock.ysnStockUnit = 1  -- TODO: In 18.3, change it to use the [Stock UOM] instead of [Stock Unit]. 

			--AND iuStock.ysnStockUOM = 1
		LEFT JOIN tblICUnitMeasure umStock
			ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId

WHERE	Item.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)