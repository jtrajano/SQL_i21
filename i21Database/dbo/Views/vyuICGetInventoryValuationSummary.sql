﻿CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
AS 

SELECT 
	s.* 
	,sl.dtmLastRun
	,Certification.intCertificationId
	,Certification.strCertificationName
	,strGrade		= Grade.strDescription
	,strOrigin 		= Origin.strDescription
	,strProductType	= ProductType.strDescription
	,strRegion 		= Region.strDescription
	,strSeason 		= Season.strDescription
	,strClass 		= Class.strDescription
	,strProductLine = ProductLine.strDescription
FROM
	tblICInventoryValuationSummary s LEFT JOIN tblICInventoryValuationSummaryLog sl
		ON s.strPeriod = sl.strPeriod
	LEFT JOIN tblICItem i
		ON i.intItemId = s.intItemId
	LEFT JOIN tblICCertification Certification
		ON Certification.intCertificationId = i.intCertificationId
	LEFT JOIN tblICCommodityAttribute Grade
		ON Grade.intCommodityAttributeId = i.intGradeId
	LEFT JOIN tblICCommodityAttribute Origin
		ON Origin.intCommodityAttributeId = i.intOriginId
	LEFT JOIN tblICCommodityAttribute ProductType
		ON ProductType.intCommodityAttributeId = i.intProductTypeId
	LEFT JOIN tblICCommodityAttribute Region
		ON Region.intCommodityAttributeId = i.intRegionId
	LEFT JOIN tblICCommodityAttribute Season
		ON Season.intCommodityAttributeId = i.intSeasonId
	LEFT JOIN tblICCommodityAttribute Class
		ON Class.intCommodityAttributeId = i.intClassVarietyId
	LEFT JOIN tblICCommodityProductLine ProductLine
		ON ProductLine.intCommodityProductLineId = i.intProductLineId


--CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
--AS

--SELECT	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY Item.intItemId) AS INT)
--		,f.strPeriod
--		,Item.intItemId
--		,Item.strItemNo
--		,strItemDescription = Item.strDescription 
--		,ItemLocation.intItemLocationId
--		,strLocationName = 
--			CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 
--					ItemLocation.strLocationName + ' (In-Transit)'
--				ELSE 
--					ItemLocation.strLocationName
--			END
--		,dblRunningQuantity = ISNULL(t.dblQuantityInStockUOM, 0)
--		,dblRunningValue = ISNULL(t.dblValue, 0) 
--		,dblRunningLastCost = ISNULL(ROUND(t.dblQuantityInStockUOM * ItemPricing.dblLastCost, 2), 0)
--		,dblRunningStandardCost = ISNULL(ROUND(dblQuantityInStockUOM * ItemPricing.dblStandardCost, 2),0)
--		,dblRunningAverageCost = ISNULL(ROUND(t.dblQuantityInStockUOM * ItemPricing.dblAverageCost, 2), 0)
--		,strStockUOM = stockUOM.strUnitMeasure
--		,Item.strCategoryCode
--		,Item.strCommodityCode
--		,strInTransitLocationName = ''
--		,intLocationId = ItemLocation.intCompanyLocationId
--		,intInTransitLocationId = NULL  
--		,ysnInTransit = CAST(CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
--		,t.intInTransitSourceLocationId
--FROM	tblGLFiscalYearPeriod f	
--		OUTER APPLY (
--			SELECT 
--				Item.intItemId
--				,Item.strItemNo
--				,Item.strDescription
--				,Category.strCategoryCode
--				,Commodity.strCommodityCode
--				,ItemLocation.intItemLocationId
--			FROM 
--				tblICItem Item INNER JOIN tblICItemLocation ItemLocation
--					ON Item.intItemId = ItemLocation.intItemId				
--				LEFT JOIN tblICCategory Category 
--					ON Category.intCategoryId = Item.intCategoryId
--				LEFT JOIN tblICCommodity Commodity
--					ON Commodity.intCommodityId = Item.intCommodityId
--			WHERE
--				Item.strType NOT IN ('Other Charge', 'Non-Inventory', 'Service', 'Software', 'Comment', 'Bundle')
--		) Item		
--		OUTER APPLY (
--			SELECT 
--				dblQuantity = SUM(ISNULL(t.dblQty, 0))
--				,dblQuantityInStockUOM = SUM(
--						dbo.fnCalculateQtyBetweenUOM(
--							t.intItemUOMId
--							, dbo.fnGetItemStockUOM(t.intItemId)
--							, t.dblQty
--						)
--					)
--				,dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
--				,t.intItemId
--				,t.intItemLocationId
--				,t.intInTransitSourceLocationId
--			FROM 
--				tblICInventoryTransaction t 
--				CROSS APPLY (
--					SELECT TOP 1
--						f.strPeriod
--						,f.intGLFiscalYearPeriodId
--					FROM 
--						tblGLFiscalYearPeriod f	INNER JOIN tblGLCurrentFiscalYear c 
--							ON c.intFiscalYearId = f.intFiscalYearId
--							AND f.ysnOpen = 1 
--						INNER JOIN tblGLFiscalYear y 
--							ON y.intFiscalYearId = f.intFiscalYearId 					
--					WHERE
--						dbo.fnDateLessThanEquals(t.dtmDate, f.dtmEndDate) = 1
--					ORDER BY 
--						f.dtmEndDate ASC 
--				) fy

--			WHERE
--				fy.intGLFiscalYearPeriodId = f.intGLFiscalYearPeriodId
--				AND t.intItemId = Item.intItemId
--				AND t.intItemLocationId = Item.intItemLocationId
--				AND t.dblQty <> 0 
--			GROUP BY 
--				t.intItemId
--				,t.intItemLocationId
--				,t.intInTransitSourceLocationId				
--			HAVING 
--				SUM(ISNULL(t.dblQty, 0)) <> 0 
--		) t
--		OUTER APPLY (
--			SELECT TOP 1 
--				iu.intItemUOMId
--				,u.strUnitMeasure
--			FROM 
--				tblICItemUOM iu LEFT JOIN tblICUnitMeasure u
--					ON u.intUnitMeasureId = iu.intUnitMeasureId 
--			WHERE 
--				iu.intItemId = t.intItemId
--				AND iu.ysnStockUnit = 1  			
--		) stockUOM
--		OUTER APPLY (
--			SELECT
--				cl.strLocationName
--				,cl.intCompanyLocationId
--				,il.intItemLocationId
--			FROM	
--				tblICItemLocation il INNER JOIN tblSMCompanyLocation cl
--					ON il.intLocationId = cl.intCompanyLocationId
--			WHERE
--				il.intItemLocationId = t.intInTransitSourceLocationId
--		) InTransit
--		OUTER APPLY (
--			SELECT
--				cl.strLocationName
--				,cl.intCompanyLocationId
--				,il.intItemLocationId
--			FROM	
--				tblICItemLocation il INNER JOIN tblSMCompanyLocation cl
--					ON il.intLocationId = cl.intCompanyLocationId
--			WHERE
--				il.intItemLocationId = COALESCE(InTransit.intItemLocationId, t.intItemLocationId, Item.intItemLocationId) 
--		) ItemLocation
--		LEFT JOIN tblICItemPricing ItemPricing 
--			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
--WHERE
--	ItemLocation.intItemLocationId IS NOT NULL 
