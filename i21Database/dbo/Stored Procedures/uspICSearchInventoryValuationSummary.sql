CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
	@strPeriod NVARCHAR(50),
	@intUserId INT
AS

TRUNCATE TABLE tblICInventoryValuationSummary

INSERT INTO tblICInventoryValuationSummary (
	intInventoryValuationKeyId
	, intItemId
	, strItemNo
	, strItemDescription
	, intItemLocationId 
	, strLocationName
	, dblRunningQuantity
	, dblRunningValue
	, dblRunningLastCost
	, dblRunningStandardCost
	, dblRunningAverageCost
	, strStockUOM
	, strCategoryCode
	, strCommodityCode
	, strInTransitLocationName
	, intLocationId 
	, intInTransitLocationId
	, ysnInTransit
	, strPeriod
)
SELECT	
	intInventoryValuationKeyId = NULL 
	,Item.intItemId
	,Item.strItemNo
	,strItemDescription = Item.strDescription 
	,ItemLocation.intItemLocationId
	,strLocationName = 
		CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 
				ItemLocation.strLocationName + ' (In-Transit)'
			ELSE 
				ItemLocation.strLocationName
		END
	,dblRunningQuantity = ISNULL(ROUND(t.dblQuantityInStockUOM, 6), 0)
	,dblRunningValue = ISNULL(ROUND(t.dblValue, 6), 0) 
	,dblRunningLastCost = ISNULL(ROUND(t.dblQuantityInStockUOM * ItemPricing.dblLastCost, 2), 0)
	,dblRunningStandardCost = ISNULL(ROUND(dblQuantityInStockUOM * ItemPricing.dblStandardCost, 2),0)
	,dblRunningAverageCost = ISNULL(ROUND(t.dblQuantityInStockUOM * ItemPricing.dblAverageCost, 2), 0)
	,strStockUOM = stockUOM.strUnitMeasure
	,Item.strCategoryCode
	,Item.strCommodityCode
	,strInTransitLocationName = InTransit.strLocationName
	,intLocationId = ItemLocation.intCompanyLocationId
	,intInTransitLocationId = InTransit.intItemLocationId  
	,ysnInTransit = CAST(CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
	,f.strPeriod
FROM	tblGLFiscalYearPeriod f	
		OUTER APPLY (
			SELECT 
				Item.intItemId
				,Item.strItemNo
				,Item.strDescription
				,Category.strCategoryCode
				,Commodity.strCommodityCode
				,ItemLocation.intItemLocationId
			FROM 
				tblICItem Item INNER JOIN tblICItemLocation ItemLocation
					ON Item.intItemId = ItemLocation.intItemId				
				LEFT JOIN tblICCategory Category 
					ON Category.intCategoryId = Item.intCategoryId
				LEFT JOIN tblICCommodity Commodity
					ON Commodity.intCommodityId = Item.intCommodityId
			--WHERE
			--	Item.strType NOT IN ('Other Charge', 'Non-Inventory', 'Service', 'Software', 'Comment', 'Bundle')
		) Item		
		OUTER APPLY (
			SELECT 
				dblQuantity = SUM(ISNULL(t.dblQty, 0))
				,dblQuantityInStockUOM = SUM(
						dbo.fnCalculateQtyBetweenUOM(
							t.intItemUOMId
							, dbo.fnGetItemStockUOM(t.intItemId)
							, t.dblQty
						)
					)
				,dblValue = SUM(ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))  --SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
				,t.intItemId
				,t.intItemLocationId
				,t.intInTransitSourceLocationId
			FROM 
				tblICInventoryTransaction t 
			WHERE
				dbo.fnDateLessThanEquals(t.dtmDate, f.dtmEndDate) = 1
				AND t.intItemId = Item.intItemId
				AND t.intItemLocationId = Item.intItemLocationId
			GROUP BY 
				t.intItemId
				,t.intItemLocationId
				,t.intInTransitSourceLocationId				
		) t
		OUTER APPLY (
			SELECT TOP 1 
				iu.intItemUOMId
				,u.strUnitMeasure
			FROM 
				tblICItemUOM iu LEFT JOIN tblICUnitMeasure u
					ON u.intUnitMeasureId = iu.intUnitMeasureId 
			WHERE 
				iu.intItemId = t.intItemId
				AND iu.ysnStockUnit = 1  			
		) stockUOM
		OUTER APPLY (
			SELECT
				cl.strLocationName
				,cl.intCompanyLocationId
				,il.intItemLocationId
			FROM	
				tblICItemLocation il INNER JOIN tblSMCompanyLocation cl
					ON il.intLocationId = cl.intCompanyLocationId
			WHERE
				il.intItemLocationId = t.intInTransitSourceLocationId
		) InTransit
		OUTER APPLY (
			SELECT
				cl.strLocationName
				,cl.intCompanyLocationId
				,il.intItemLocationId
			FROM	
				tblICItemLocation il INNER JOIN tblSMCompanyLocation cl
					ON il.intLocationId = cl.intCompanyLocationId
			WHERE
				il.intItemLocationId = COALESCE(InTransit.intItemLocationId, t.intItemLocationId, Item.intItemLocationId) 
		) ItemLocation
		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = ItemLocation.intCompanyLocationId
WHERE
	ItemLocation.intItemLocationId IS NOT NULL 
	AND (f.strPeriod = @strPeriod COLLATE Latin1_General_CI_AS OR @strPeriod IS NULL) 
	AND permission.intEntityId = @intUserId
--CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
--	@strPeriod NVARCHAR(50)
--AS

--SELECT TOP 1 @strPeriod = strPeriod FROM tblGLFiscalYearPeriod WHERE strPeriod = @strPeriod

--DELETE FROM tblICInventoryValuationSummary

--IF NULLIF(@strPeriod, '') IS NOT NULL
--BEGIN
--	--INSERT INTO @valuations
--	INSERT INTO tblICInventoryValuationSummary(
--		  intInventoryValuationKeyId
--		, intItemId
--		, strItemNo
--		, strItemDescription
--		, intItemLocationId 
--		, strLocationName
--		, dblRunningQuantity
--		, dblRunningValue
--		, dblRunningLastCost
--		, dblRunningStandardCost
--		, dblRunningAverageCost
--		, strStockUOM
--		, strCategoryCode
--		, strCommodityCode
--		, strInTransitLocationName
--		, intLocationId 
--		, intInTransitLocationId
--		, ysnInTransit
--		, strPeriod
--	)
--	SELECT
--		  intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY il.intItemLocationId) AS INT)
--		, i.intItemId
--		, i.strItemNo
--		, strItemDescription = i.strDescription 
--		, il.intItemLocationId
--		, strLocationName = CASE WHEN val.ysnInTransit = 1 THEN loc.strLocationName + ' (In-Transit)' ELSE loc.strLocationName END
--		, dblRunningQuantity = ISNULL(val.dblQuantity, 0)
--		, dblRunningValue = ISNULL(val.dblValue, 0)
--		, dblRunningLastCost = ISNULL(ROUND(val.dblQuantityInStockUOM * ip.dblLastCost, 2), 0)
--		, dblRunningStandardCost = ISNULL( ROUND(val.dblQuantityInStockUOM * ip.dblStandardCost, 2),0)
--		, dblRunningAverageCost = ISNULL( ROUND(val.dblQuantityInStockUOM * ip.dblAverageCost, 2),0)
--		, strStockUOM = umStock.strUnitMeasure
--		, cat.strCategoryCode
--		, com.strCommodityCode
--		, strInTransitLocationName = ''
--		, val.intLocationId
--		, intInTransitLocationId = null  
--		, val.ysnInTransit
--		, strPeriod = @strPeriod
--	FROM tblICItem i
--		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
--		INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId
--		LEFT JOIN tblICItemPricing ip ON ip.intItemLocationId = il.intItemLocationId
--			AND ip.intItemId = i.intItemId
--		LEFT JOIN tblICItemUOM ium ON ium.intItemId = i.intItemId
--			AND ium.ysnStockUnit = 1  
--		LEFT JOIN tblICUnitMeasure umStock ON umStock.intUnitMeasureId = ium.intUnitMeasureId 
--		LEFT JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
--		LEFT JOIN tblICCommodity com ON com.intCommodityId = i.intCommodityId
--		CROSS APPLY dbo.fnGetItemValuation(i.intItemId, il.intItemLocationId, @strPeriod) val	
--	ORDER BY il.intItemLocationId
--END
--GO
