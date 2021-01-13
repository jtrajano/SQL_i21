﻿CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
	@strPeriod NVARCHAR(50)
	,@intUserId INT
	,@ysnForceRebuild AS BIT = 0
	,@strCategoryCode AS NVARCHAR(50) = NULL 
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
	,dblRunningLastCost = 
		ISNULL(
			ROUND(
				t.dblQuantityInStockUOM 
				* COALESCE(
					dbo.fnCalculateCostBetweenUOM( 
						positiveStock.intItemUOMId
						,stockUOM.intItemUOMId 
						,positiveStock.dblCost 
					)
					,NULLIF(ItemPricing.dblLastCost, 0)
					,dbo.fnCalculateCostBetweenUOM( 
						negativeStock.intItemUOMId
						,stockUOM.intItemUOMId 
						,negativeStock.dblCost 
					)
				)
				,2
			)
			, 0
		)
	,dblRunningStandardCost = ISNULL(ROUND(dblQuantityInStockUOM * ItemPricing.dblStandardCost, 2),0)
	,dblRunningAverageCost = 
		ISNULL(
			ROUND(
				t.dblQuantityInStockUOM 
				* COALESCE(
					movingAvgCost.dblAverageCost
					,ItemPricing.dblAverageCost
				)				
				, 2
			)
			, 0
		)
	,strStockUOM = Item.strUnitMeasure
	,Item.strCategoryCode
	,Item.strCommodityCode
	,strInTransitLocationName = InTransit.strLocationName
	,intLocationId = ItemLocation.intCompanyLocationId
	,intInTransitLocationId = InTransit.intItemLocationId  
	,ysnInTransit = CAST(CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
	,f.strPeriod
	,strKey = CAST(Item.intItemId AS NVARCHAR(100)) + CAST(ItemLocation.intItemLocationId AS NVARCHAR(100)) + @strPeriod
FROM	tblGLFiscalYearPeriod f	
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
		OUTER APPLY (
			SELECT 
				Item.intItemId
				,Item.strItemNo
				,Item.strDescription
				,Category.strCategoryCode
				,Commodity.strCommodityCode
				,ItemLocation.intItemLocationId
				,stockUOM.intItemUOMId
				,stockUOM.strUnitMeasure
			FROM 
				tblICItem Item INNER JOIN tblICItemLocation ItemLocation
					ON Item.intItemId = ItemLocation.intItemId				
				LEFT JOIN tblICCategory Category 
					ON Category.intCategoryId = Item.intCategoryId
				LEFT JOIN tblICCommodity Commodity
					ON Commodity.intCommodityId = Item.intCommodityId
				OUTER APPLY (
					SELECT TOP 1 
						iu.intItemUOMId
						,u.strUnitMeasure
					FROM 
						tblICItemUOM iu LEFT JOIN tblICUnitMeasure u
							ON u.intUnitMeasureId = iu.intUnitMeasureId 
					WHERE 
						iu.intItemId = Item.intItemId
						AND iu.ysnStockUnit = 1  			
				) stockUOM
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
		OUTER APPLY (
			SELECT	TOP 1 
					t2.intItemUOMId 
					,t2.dblCost
			FROM	dbo.tblICInventoryTransaction t2 
			WHERE	t2.intItemId = ItemPricing.intItemId
					AND t2.intItemLocationId = ItemPricing.intItemLocationId
					AND t2.dblQty > 0 
					AND ISNULL(t2.ysnIsUnposted, 0) = 0
					AND FLOOR(CAST(t2.dtmDate AS FLOAT)) <= FLOOR(CAST(f.dtmEndDate AS FLOAT))
			ORDER BY t2.intInventoryTransactionId DESC 						
		) positiveStock 
		OUTER APPLY (
			SELECT	TOP 1 					
					t3.intItemUOMId 
					,t3.dblCost
			FROM	dbo.tblICInventoryTransaction t3 
			WHERE	t3.intItemId = ItemPricing.intItemId
					AND t3.intItemLocationId = ItemPricing.intItemLocationId
					AND t3.dblQty < 0 
					AND ISNULL(t3.ysnIsUnposted, 0) = 0
					AND FLOOR(CAST(t3.dtmDate AS FLOAT)) <= FLOOR(CAST(f.dtmEndDate AS FLOAT))
			ORDER BY t3.intInventoryTransactionId DESC 						
		) negativeStock
		OUTER APPLY (
			SELECT TOP 1 
				t4.intInventoryTransactionId
			FROM 
				tblICInventoryTransaction t4
			WHERE
				t4.intItemId = Item.intItemId
				AND t4.intItemLocationId = ItemLocation.intItemLocationId
			ORDER BY
				t4.intInventoryTransactionId DESC 
		) lastTransaction
		OUTER APPLY (
			SELECT dblAverageCost = 
				dbo.fnICGetMovingAverageCost (
					Item.intItemId
					,ItemLocation.intItemLocationId
					,lastTransaction.intInventoryTransactionId
				)		
		) movingAvgCost 

WHERE
	ItemLocation.intItemLocationId IS NOT NULL
	AND f.intGLFiscalYearPeriodId >= fypStartingPoint.intGLFiscalYearPeriodId
	AND FLOOR(CAST(f.dtmStartDate AS FLOAT)) <= FLOOR(CAST(GETDATE() AS FLOAT))

UPDATE l
SET l.ysnRebuilding = 0
	,l.dtmEnd = GETDATE() 
FROM tblICInventoryValuationSummaryLog l
WHERE l.strPeriod = @strPeriod
	
