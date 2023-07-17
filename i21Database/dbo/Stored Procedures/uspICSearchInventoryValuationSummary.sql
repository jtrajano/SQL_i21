CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
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

-- If Inventory is closed in the Fiscal Year Period, then exit immediately. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM 
		tblICInventoryValuationSummaryLog (NOLOCK) l INNER JOIN tblGLFiscalYearPeriod fyp
			ON l.strPeriod = fyp.strPeriod 
	WHERE 
		l.strPeriod = @strPeriod
		AND fyp.ysnINVOpen = 0
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

;
MERGE	
INTO	tblICInventoryValuationSummary
WITH	(HOLDLOCK) 
AS		summaryLog 
USING (
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
	WHERE
		ItemLocation.intItemLocationId IS NOT NULL
		AND f.intGLFiscalYearPeriodId >= fypStartingPoint.intGLFiscalYearPeriodId
		AND FLOOR(CAST(f.dtmStartDate AS FLOAT)) <= FLOOR(CAST(GETDATE() AS FLOAT))
) query
	ON 
	summaryLog.intItemId = query.intItemId 
	AND summaryLog.strPeriod = query.strPeriod 
	AND summaryLog.strKey = query.strKey
	AND (
		summaryLog.intInTransitLocationId = query.intInTransitLocationId
		OR (summaryLog.intInTransitLocationId is null and query.intInTransitLocationId is null) 
	)	

WHEN MATCHED THEN 
	UPDATE 
	SET summaryLog.strItemNo = query.strItemNo
		,summaryLog.strItemDescription = query.strItemDescription
		,summaryLog.strLocationName = query.strLocationName
		,summaryLog.dblRunningQuantity = query.dblRunningQuantity
		,summaryLog.dblRunningValue = query.dblRunningValue
		,summaryLog.dblRunningLastCost = query.dblRunningLastCost
		,summaryLog.dblRunningStandardCost = query.dblRunningStandardCost
		,summaryLog.dblRunningAverageCost = query.dblRunningAverageCost
		,summaryLog.strStockUOM = query.strStockUOM
		,summaryLog.strCategoryCode = query.strCategoryCode
		,summaryLog.strCommodityCode = query.strCommodityCode 
		,summaryLog.strInTransitLocationName = query.strInTransitLocationName 
		,summaryLog.intLocationId = query.intLocationId
		,summaryLog.intInTransitLocationId = query.intInTransitLocationId
		,summaryLog.ysnInTransit = query.ysnInTransit
		,summaryLog.strKey = query.strKey 

WHEN NOT MATCHED THEN 
	INSERT (
		intInventoryValuationKeyId 
		,intItemId
		,strItemNo
		,strItemDescription 
		,intItemLocationId
		,strLocationName 
		,dblRunningQuantity
		,dblRunningValue
		,dblRunningLastCost
		,dblRunningStandardCost
		,dblRunningAverageCost
		,strStockUOM
		,strCategoryCode
		,strCommodityCode
		,strInTransitLocationName
		,intLocationId
		,intInTransitLocationId
		,ysnInTransit
		,strPeriod
		,strKey
	)
	VALUES (
		query.intInventoryValuationKeyId 
		,query.intItemId
		,query.strItemNo
		,query.strItemDescription 
		,query.intItemLocationId
		,query.strLocationName 
		,query.dblRunningQuantity
		,query.dblRunningValue
		,query.dblRunningLastCost
		,query.dblRunningStandardCost
		,query.dblRunningAverageCost
		,query.strStockUOM
		,query.strCategoryCode
		,query.strCommodityCode
		,query.strInTransitLocationName
		,query.intLocationId
		,query.intInTransitLocationId
		,query.ysnInTransit
		,query.strPeriod
		,query.strKey		
	)
;
	
UPDATE l
SET l.ysnRebuilding = 0
	,l.dtmEnd = GETDATE() 
FROM tblICInventoryValuationSummaryLog l
WHERE l.strPeriod = @strPeriod
	
