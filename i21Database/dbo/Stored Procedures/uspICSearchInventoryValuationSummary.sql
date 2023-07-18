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

CREATE TABLE #valuation (
	  intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, intItemLocationId INT
	, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblRunningQuantity NUMERIC(38, 6)
	, dblRunningValue NUMERIC(38, 6)
	, dblRunningLastCost NUMERIC(38, 6)
	, dblRunningStandardCost NUMERIC(38, 6)
	, dblRunningAverageCost NUMERIC(38, 6)
	, strStockUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strInTransitLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, intInTransitLocationId INT
	, ysnInTransit BIT
	, strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strKey NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

INSERT #valuation
SELECT	
		 Item.intItemId
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

INSERT INTO tblICInventoryValuationSummary (
	  intItemId
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
	  v.intItemId
	, v.strItemNo
	, v.strItemDescription
	, v.intItemLocationId
	, v.strLocationName
	, v.dblRunningQuantity
	, v.dblRunningValue
	, v.dblRunningLastCost
	, v.dblRunningStandardCost
	, v.dblRunningAverageCost
	, v.strStockUOM
	, v.strCategoryCode
	, v.strCommodityCode
	, v.strInTransitLocationName
	, v.intLocationId
	, v.intInTransitLocationId
	, v.ysnInTransit
	, v.strPeriod
	, v.strKey
FROM #valuation v
WHERE NOT EXISTS (
	SELECT TOP 1 1
	FROM tblICInventoryValuationSummary s
	WHERE s.intItemId = v.intItemId 
		AND s.strPeriod = v.strPeriod 
		AND ISNULL(s.intInTransitLocationId, 0) = ISNULL(v.intInTransitLocationId, 0)
)

UPDATE s
SET   s.strItemNo = v.strItemNo
	, s.strItemDescription = v.strItemDescription
	, s.strLocationName = v.strLocationName
	, s.dblRunningQuantity = v.dblRunningQuantity
	, s.dblRunningValue = v.dblRunningValue
	, s.dblRunningLastCost = v.dblRunningLastCost
	, s.dblRunningStandardCost = v.dblRunningStandardCost
	, s.dblRunningAverageCost = v.dblRunningAverageCost
	, s.strStockUOM = v.strStockUOM
	, s.strCategoryCode = v.strCategoryCode
	, s.strCommodityCode = v.strCommodityCode 
	, s.strInTransitLocationName = v.strInTransitLocationName 
	, s.intLocationId = v.intLocationId
	, s.intInTransitLocationId = v.intInTransitLocationId
	, s.ysnInTransit = v.ysnInTransit
	, s.strKey = v.strKey 
FROM tblICInventoryValuationSummary s
JOIN #valuation v ON v.intItemId = s.intItemId 
	AND v.strPeriod = s.strPeriod 
	AND ISNULL(v.intInTransitLocationId, 0) = ISNULL(s.intInTransitLocationId, 0)
	
UPDATE l
SET l.ysnRebuilding = 0
	,l.dtmEnd = GETDATE() 
FROM tblICInventoryValuationSummaryLog l
WHERE l.strPeriod = @strPeriod
	
