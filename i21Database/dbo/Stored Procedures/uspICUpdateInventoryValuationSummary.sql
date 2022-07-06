CREATE PROCEDURE dbo.[uspICUpdateInventoryValuationSummary]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@intItemUOMId AS INT
	,@dblQty AS NUMERIC(18, 6)
	,@dblCost AS NUMERIC(18, 6)
	,@dblValue AS NUMERIC(18, 6)
	,@intTransactionTypeId AS INT = NULL
	,@dtmTransactionDate AS DATETIME = NULL
	,@intInTransitSourceLocationId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @strPeriod NVARCHAR(50)

-- Get the period id. 
BEGIN 
	SELECT TOP 1 
		@strPeriod = strPeriod
	FROM 
		tblGLFiscalYearPeriod fyp
	WHERE	
		fyp.dtmStartDate <= @dtmTransactionDate
	ORDER BY 
		fyp.dtmStartDate DESC 
END

---- Update an existing valuation summary.
--UPDATE summary
--SET
--	summary.dblRunningQuantity = 
--		CASE 
--			WHEN @dblQty <> 0 THEN 
--				ISNULL(summary.dblRunningQuantity, 0)
--				+ dbo.fnCalculateQtyBetweenUOM(
--					@intItemUOMId
--					, stockUOM.intItemUOMId
--					, @dblQty
--				)
--			ELSE
--				summary.dblRunningQuantity
--		END 
--	,summary.dblRunningValue =	
--		ISNULL(summary.dblRunningValue, 0)
--		+ ROUND(ISNULL(@dblQty, 0) * ISNULL(@dblCost, 0) + ISNULL(@dblValue, 0), 2)
--	,summary.dblRunningLastCost = 
--		CASE 
--			WHEN @dblQty <> 0 THEN 
--				ROUND(
--					(
--						ISNULL(summary.dblRunningQuantity, 0)
--						+ dbo.fnCalculateQtyBetweenUOM(
--							@intItemUOMId
--							, stockUOM.intItemUOMId
--							, @dblQty
--						)
--					)
--					* ItemPricing.dblLastCost
--					, 2
--				) 
--			ELSE 
--				summary.dblRunningLastCost
--		END 
--	,summary.dblRunningStandardCost = 
--		CASE 
--			WHEN @dblQty <> 0 THEN 
--				ROUND(
--					(
--						ISNULL(summary.dblRunningQuantity, 0)
--						+ dbo.fnCalculateQtyBetweenUOM(
--							@intItemUOMId
--							, stockUOM.intItemUOMId
--							, @dblQty
--						)
--					)
--					* ItemPricing.dblStandardCost
--					, 2
--				) 
--			ELSE 
--				summary.dblRunningStandardCost
--		END 
--	,summary.dblRunningAverageCost = 
--		CASE 
--			WHEN @dblQty <> 0 THEN 
--				ROUND(
--					(
--						ISNULL(summary.dblRunningQuantity, 0)
--						+ dbo.fnCalculateQtyBetweenUOM(
--							@intItemUOMId
--							, stockUOM.intItemUOMId
--							, @dblQty
--						)
--					)
--					* ItemPricing.dblAverageCost						
--					, 2
--				) 
--			ELSE 
--				summary.dblRunningAverageCost
--		END 
--FROM 
--	tblICInventoryValuationSummary summary
--	INNER JOIN tblGLFiscalYearPeriod f
--		ON f.strPeriod = summary.strPeriod
--	CROSS APPLY (
--		SELECT TOP 1 
--			fyp.intGLFiscalYearPeriodId 
--		FROM 
--			tblGLFiscalYearPeriod fyp
--		WHERE
--			(fyp.strPeriod = @strPeriod COLLATE Latin1_General_CI_AS OR @strPeriod IS NULL) 		
--		ORDER BY
--			fyp.intGLFiscalYearPeriodId ASC 				
--	) fypStartingPoint
--	CROSS APPLY (
--		SELECT TOP 1 
--			iu.intItemUOMId
--		FROM 
--			tblICItemUOM iu
--		WHERE
--			iu.intItemId = @intItemId
--			AND iu.ysnStockUnit = 1
--	) stockUOM
--	LEFT JOIN tblICItemPricing ItemPricing 
--		ON ItemPricing.intItemLocationId = summary.intItemLocationId
--		AND ItemPricing.intItemId = summary.intItemId
--WHERE
--	summary.intItemId = @intItemId
--	AND (
--		summary.intItemLocationId = @intItemLocationId
--		OR summary.intInTransitLocationId = @intItemLocationId
--	)
--	AND f.intGLFiscalYearPeriodId >= fypStartingPoint.intGLFiscalYearPeriodId

; 
MERGE	
INTO	tblICInventoryValuationSummary
WITH	(HOLDLOCK) 
AS		ValuationSummary
USING (
	SELECT 
		dblQty = 
			dbo.fnCalculateQtyBetweenUOM(
				@intItemUOMId
				, stockUOM.intItemUOMId
				, @dblQty
			)
		,dblValue =	
			ROUND(ISNULL(@dblQty, 0) * ISNULL(@dblCost, 0) + ISNULL(@dblValue, 0), 2)
		,dblLastCost = ItemPricing.dblLastCost
		,dblStandardCost = ItemPricing.dblStandardCost 
		,dblAverageCost = ItemPricing.dblAverageCost

		,f.intGLFiscalYearPeriodId  
		, intInventoryValuationKeyId = NULL 
		, intItemId = Item.intItemId 
		, strItemNo = Item.strItemNo
		, strItemDescription = Item.strDescription 
		, intItemLocationId = ItemLocation.intItemLocationId 
		, strLocationName = 
				CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 
						ItemLocation.strLocationName + ' (In-Transit)'
					ELSE 
						ItemLocation.strLocationName
				END
		, strStockUOM = stockUOM.strUnitMeasure
		, strCategoryCode = Item.strCategoryCode
		, strCommodityCode = Item.strCommodityCode 
		, strInTransitLocationName = InTransit.strLocationName  
		, intLocationId = ItemLocation.intCompanyLocationId
		, intInTransitLocationId = InTransit.intItemLocationId
		, ysnInTransit = CAST(CASE WHEN InTransit.intItemLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
		, strPeriod = f.strPeriod
		, strKey = CAST(Item.intItemId AS NVARCHAR(100)) + CAST(ItemLocation.intItemLocationId AS NVARCHAR(100)) + f.strPeriod
	FROM 
		tblGLFiscalYearPeriod f
		CROSS APPLY (
			SELECT 
				i.intItemId
				,i.strItemNo
				,i.strDescription
				,cat.strCategoryCode
				,com.strCommodityCode 
			FROM 
				tblICItem i 
				LEFT JOIN tblICCategory cat
					ON cat.intCategoryId = i.intCategoryId
				LEFT JOIN tblICCommodity com
					ON com.intCommodityId = i.intCommodityId 
			WHERE
				i.intItemId = @intItemId 
		) Item 
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
		CROSS APPLY (
			SELECT TOP 1 
				iu.intItemUOMId
				,u.strUnitMeasure
			FROM 
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u 
					ON iu.intUnitMeasureId = u.intUnitMeasureId 
			WHERE
				iu.intItemId = @intItemId
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
				il.intItemLocationId = @intInTransitSourceLocationId
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
				il.intItemLocationId = COALESCE(InTransit.intItemLocationId, @intItemLocationId) 
		) ItemLocation

		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
			AND ItemPricing.intItemId = Item.intItemId

	WHERE
		f.intGLFiscalYearPeriodId >= fypStartingPoint.intGLFiscalYearPeriodId
		AND f.strPeriod = @strPeriod

) AS summaryData 
	ON ValuationSummary.intItemId = summaryData.intItemId 
	AND ValuationSummary.intItemLocationId = summaryData.intItemLocationId 
	AND ValuationSummary.strLocationName = summaryData.strLocationName
	AND ValuationSummary.strPeriod = summaryData.strPeriod	

WHEN MATCHED THEN 
	UPDATE 
	SET	
		dblRunningQuantity = 
			ROUND(
				(summaryData.dblQty + ValuationSummary.dblRunningQuantity)
				,2
			)
		,dblRunningValue = 
			ROUND(
				(summaryData.dblValue + ValuationSummary.dblRunningValue)				
				,2
			)
		,dblRunningLastCost = 
			ROUND(
				(summaryData.dblQty + ValuationSummary.dblRunningQuantity)
				* summaryData.dblLastCost 
				,2
			)
		,dblRunningStandardCost = 
			ROUND(
				(summaryData.dblQty + ValuationSummary.dblRunningQuantity)
				* summaryData.dblStandardCost 
				,2
			)
		,dblRunningAverageCost = 
			ROUND(
				(summaryData.dblQty + ValuationSummary.dblRunningQuantity)
				* summaryData.dblAverageCost 
				,2
			)
WHEN NOT MATCHED THEN 
	INSERT (
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
	VALUES (
		summaryData.intInventoryValuationKeyId 
		, summaryData.intItemId
		, summaryData.strItemNo
		, summaryData.strItemDescription
		, summaryData.intItemLocationId 
		, summaryData.strLocationName
		, summaryData.dblQty --dblRunningQuantity
		, summaryData.dblValue --dblRunningValue
		, ROUND(summaryData.dblQty * summaryData.dblLastCost, 2)  --dblRunningLastCost
		, ROUND(summaryData.dblQty * summaryData.dblStandardCost, 2) --dblRunningStandardCost
		, ROUND(summaryData.dblQty * summaryData.dblAverageCost, 2) --dblRunningAverageCost
		, summaryData.strStockUOM
		, summaryData.strCategoryCode
		, summaryData.strCommodityCode
		, summaryData.strInTransitLocationName
		, summaryData.intLocationId 
		, summaryData.intInTransitLocationId
		, summaryData.ysnInTransit
		, summaryData.strPeriod
		, summaryData.strKey	
	)
;