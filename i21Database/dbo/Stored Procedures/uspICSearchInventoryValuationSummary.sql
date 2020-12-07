﻿CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
	@strPeriod NVARCHAR(50)
	,@intUserId INT
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@ysnForceRebuild AS BIT = 0
AS

-- If rebuild is in-progress, leave immediately to avoid deadlocks. 
IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryValuationSummaryLog (NOLOCK) WHERE ysnRebuilding = 1)
BEGIN 
	RETURN; 
END 

-- If fyp is Open and the log is more than a day old, continue with the rebuild. 
-- Otherwise, exit immediately. Do not rebuild the valuation summary. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM 
		tblICInventoryValuationSummaryLog (NOLOCK) l INNER JOIN tblGLFiscalYearPeriod fyp
			ON l.strPeriod = fyp.strPeriod 
	WHERE 
		l.strPeriod = @strPeriod
		AND fyp.ysnINVOpen = 1 
		AND ABS(DATEDIFF(DAY, l.dtmLastRun, GETDATE())) <= 1
)
AND @ysnForceRebuild <> 1
BEGIN 
	RETURN; 
END 

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryValuationSummaryLog WHERE strPeriod = @strPeriod)
BEGIN 
	INSERT INTO tblICInventoryValuationSummaryLog (
		strPeriod
		,dtmLastRun
		,ysnRebuilding
		,dtmStart
		,intEntityUserSecurityId
	)
	VALUES (
		@strPeriod
		,dbo.fnRemoveTimeOnDate(GETDATE()) 
		,1
		,GETDATE() 
		,@intUserId
	)
END 
ELSE 
BEGIN 
	UPDATE l
	SET l.ysnRebuilding = 1
		,l.dtmLastRun = dbo.fnRemoveTimeOnDate(GETDATE()) 
		,l.dtmStart = GETDATE() 
	FROM tblICInventoryValuationSummaryLog l
	WHERE l.strPeriod = @strPeriod
END 

DELETE summary
FROM 
	tblICInventoryValuationSummary summary
	INNER JOIN tblICItem i 
		ON summary.intItemId = i.intItemId
	INNER JOIN tblGLFiscalYearPeriod f
		ON summary.strPeriod = f.strPeriod 
	CROSS APPLY (
		SELECT TOP 1 
			fyp.intGLFiscalYearPeriodId 
		FROM 
			tblGLFiscalYearPeriod fyp
		WHERE
			(fyp.strPeriod = @strPeriod COLLATE Latin1_General_CI_AS OR @strPeriod IS NULL) 		
		ORDER BY
			fyp.intGLFiscalYearPeriodId ASC 				
	) fypStartingPoint
	LEFT JOIN tblICCategory c 
		ON c.intCategoryId = i.intCategoryId
WHERE
	f.intGLFiscalYearPeriodId >= fypStartingPoint.intGLFiscalYearPeriodId
	AND (c.strCategoryCode = @strCategoryCode OR @strCategoryCode IS NULL)

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
	, strKey
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
	,strKey = CAST(Item.intItemId AS NVARCHAR(100)) + CAST(ItemLocation.intItemLocationId AS NVARCHAR(100)) + @strPeriod
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
			WHERE
				(Category.strCategoryCode = @strCategoryCode OR @strCategoryCode IS NULL)
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
				,dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
				,t.intItemId
				,t.intItemLocationId
				,t.intInTransitSourceLocationId
			FROM 
				tblICInventoryTransaction t 
			WHERE
				--dbo.fnDateLessThanEquals(t.dtmDate, f.dtmEndDate) = 1
				FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(f.dtmEndDate AS FLOAT))
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
			AND ItemPricing.intItemId = Item.intItemId
WHERE
	ItemLocation.intItemLocationId IS NOT NULL 
	AND (f.strPeriod = @strPeriod COLLATE Latin1_General_CI_AS OR @strPeriod IS NULL) 

UPDATE l
SET l.ysnRebuilding = 0
	,l.dtmEnd = GETDATE() 
FROM tblICInventoryValuationSummaryLog l
WHERE l.strPeriod = @strPeriod
