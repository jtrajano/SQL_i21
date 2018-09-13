﻿CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
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
		--,dblQuantity = ISNULL(dblQuantityInStockUOM, 0)
		,dblRunningQuantity = CAST(dblQuantityInStockUOM AS NUMERIC(38, 20)) 
		--,dblValue = ISNULL(dblValue, 0)
		,dblRunningValue = ISNULL(dblValue, 0)
		--,dblLastCost = ISNULL(ROUND(dblQuantityInStockUOM * ItemPricing.dblLastCost, 2), 0)
		,dblRunningLastCost = ISNULL(ROUND(dblQuantityInStockUOM * ItemPricing.dblLastCost, 2), 0)
		--,dblStandardCost = ISNULL( ROUND(dblQuantityInStockUOM * ItemPricing.dblStandardCost, 2),0)
		,dblRunningStandardCost = ISNULL( ROUND(dblQuantityInStockUOM * ItemPricing.dblStandardCost, 2),0)
		--,dblAverageCost = ISNULL( ROUND(dblQuantityInStockUOM * ItemPricing.dblAverageCost, 2),0)
		,dblRunningAverageCost = ISNULL( ROUND(dblQuantityInStockUOM * ItemPricing.dblAverageCost, 2),0)
		,strStockUOM = umStock.strUnitMeasure
		--,t.dblQuantityInStockUOM
		,Category.strCategoryCode
		,Commodity.strCommodityCode
		,strInTransitLocationName = ''
		,t.intLocationId
		,intInTransitLocationId = null  
		,t.ysnInTransit
		,strPeriod = f.strPeriod
FROM	tblGLFiscalYearPeriod f	INNER JOIN tblGLCurrentFiscalYear c 
			ON c.intFiscalYearId = f.intFiscalYearId
			AND f.ysnOpen = 1 
        INNER JOIN tblGLFiscalYear y 
			ON y.intFiscalYearId = f.intFiscalYearId 
		LEFT JOIN  tblICItem Item 
			ON 1 = 1
		LEFT JOIN tblICItemUOM stockUOM 
			ON stockUOM.intItemId = Item.intItemId
			AND stockUOM.ysnStockUnit = 1  
		LEFT JOIN tblICUnitMeasure umStock
			ON umStock.intUnitMeasureId = stockUOM.intUnitMeasureId 
		LEFT JOIN tblICCategory Category 
			ON Category.intCategoryId = Item.intCategoryId
		LEFT JOIN tblICCommodity Commodity 
			ON Commodity.intCommodityId = Item.intCommodityId
		OUTER APPLY (
			SELECT 
					intLocationId = ISNULL(InTransit.intLocationId, l.intLocationId) 
					,ysnInTransit = CASE WHEN l.intLocationId IS NULL THEN 1 ELSE 0 END 
					--,intMonth = MONTH(t.dtmDate)
					--,intYear = YEAR(t.dtmDate) 
					,dblQuantity = SUM(ISNULL(t.dblQty, 0)) 
					,dblQuantityInStockUOM = 
						SUM(
							dbo.fnCalculateQtyBetweenUOM (
								t.intItemUOMId
								,stockUOM.intItemUOMId
								,t.dblQty
							)
						) 
					,dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))					
			FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation l
						ON t.intItemLocationId = l.intItemLocationId
					LEFT JOIN tblICItemUOM stockUOM 
						ON stockUOM.intItemId = t.intItemId
						AND stockUOM.ysnStockUnit = 1  
					LEFT JOIN tblICItemLocation InTransit
						ON InTransit.intItemLocationId = t.intInTransitSourceLocationId
						AND t.intInTransitSourceLocationId IS NOT NULL 
			WHERE	Item.intItemId = t.intItemId					
					AND dbo.fnDateLessThanEquals(t.dtmDate, f.dtmEndDate) = 1
			GROUP BY 
				ISNULL(InTransit.intLocationId, l.intLocationId) 
				,CASE WHEN l.intLocationId IS NULL THEN 1 ELSE 0 END 
				--,MONTH(t.dtmDate)
				--,YEAR(t.dtmDate) 
		) t							

		LEFT JOIN tblICItemLocation ItemLocation 
			ON ItemLocation.intLocationId = t.intLocationId
			AND ItemLocation.intItemId = Item.intItemId 

		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId	

		LEFT JOIN tblSMCompanyLocation [Location]
			ON [Location].intCompanyLocationId = t.intLocationId


WHERE	Item.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)