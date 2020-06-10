CREATE VIEW [dbo].[vyuSTMarkUpDownDetail]
	AS
SELECT 
	markDetail.intMarkUpDownDetailId,
	markDetail.intMarkUpDownId,
	markDetail.intItemId,
	markDetail.intCategoryId,
	strMarkUpOrDown = CASE
						WHEN (mark.strType = 'Item Level' AND markDetail.dblRetailPerUnit > ISNULL(itemPricing.dblSalePrice, 0))
							THEN 'Mark Up'
						WHEN (mark.strType = 'Item Level' AND markDetail.dblRetailPerUnit < ISNULL(itemPricing.dblSalePrice, 0))
							THEN 'Mark Down'

						-- Note: Please see comment here http://jira.irelyserver.com/browse/ST-1014
						WHEN (mark.strType = 'Department Level' AND markDetail.dblTotalRetailAmount > 0)
							THEN 'Mark Up'
						WHEN (mark.strType = 'Department Level' AND markDetail.dblTotalRetailAmount < 0)
							THEN 'Mark Down'
						--WHEN (mark.strType = 'Department Level' AND markDetail.dblTotalRetailAmount > ISNULL(catPricing.dblTotalRetailValue, 0))
						--	THEN 'Mark Up'
						--WHEN (mark.strType = 'Department Level' AND markDetail.dblTotalRetailAmount < ISNULL(catPricing.dblTotalRetailValue, 0))
						--	THEN 'Mark Down'
						ELSE ''
					END COLLATE Latin1_General_CI_AS,
	markDetail.strRetailShrinkRS,
	markDetail.intQty, 
    markDetail.dblRetailPerUnit, 
    markDetail.dblTotalRetailAmount, 
    markDetail.dblTotalCostAmount, 
    markDetail.strNote, 
    markDetail.dblActulaGrossProfit, 
    ysnSentToHost							=	ISNULL(markDetail.ysnSentToHost, 0), 
    markDetail.strReason, 
    markDetail.intConcurrencyId,

	--Category
	cat.strCategoryCode,

	--Mark
	mark.strType,
	mark.strAdjustmentType,

	--Item
	item.strItemNo,
	strItemDescription						=	item.strDescription,

	--CStore
	store.intStoreId,
	store.intStoreNo,

	--CompanyLocation
	companyLoc.intCompanyLocationId,
	companyLoc.strLocationName,

	--Pricing
	itemPricing.intItemPricingId,
	dblItemLevelCurrentRetailPrice			=	ISNULL(itemPricing.dblSalePrice, 0),
	dblItemLevelCurrentRunningBalanceCost	=	ISNULL(dbo.fnICGetItemRunningCost(
																					item.intItemId, 
																					itemLoc.intLocationId, 
																					NULL, 
																					itemLoc.intStorageLocationId, 
																					NULL, 
																					item.intCommodityId, 
																					item.intCategoryId, 
																					NULL, 
																					1
																				 ), 0),

	--ISNULL([dbo].[fnICGetRunningBalance](invItemLevelValuation.intInventoryTransactionId), 0)	AS dblItemLevelCurrentRunningBalanceCost

	--CategoryPricing
	dblDeptLevelTotalCostValue				=	ISNULL(catPricing.dblTotalCostValue, 0),
	dblDeptLevelTotalRetailValue			=	ISNULL(catPricing.dblTotalRetailValue, 0)
FROM tblSTMarkUpDownDetail markDetail
INNER JOIN tblSTMarkUpDown mark
	ON markDetail.intMarkUpDownId = mark.intMarkUpDownId
INNER JOIN tblSTStore store
	ON mark.intStoreId = store.intStoreId
INNER JOIN tblSMCompanyLocation companyLoc
	ON store.intCompanyLocationId = companyLoc.intCompanyLocationId
INNER JOIN tblICItemLocation itemLoc
	ON companyLoc.intCompanyLocationId = itemLoc.intLocationId

--Item Level
INNER JOIN tblICItem item
	ON markDetail.intItemId = item.intItemId
INNER JOIN tblICItemPricing itemPricing
	ON itemLoc.intItemLocationId = itemPricing.intItemLocationId
		AND item.intItemId = itemPricing.intItemId	
--OUTER APPLY
--(
--	SELECT	TOP 1 * 
--	FROM	vyuICGetInventoryValuationByLocation 
--	WHERE	intItemId = item.intItemId
--		AND intLocationId = companyLoc.intCompanyLocationId
--	ORDER BY dtmDate DESC
--) itemValuation

--Department Level
INNER JOIN tblICCategory cat
	ON markDetail.intCategoryId = cat.intCategoryId
LEFT JOIN tblICCategoryPricing catPricing
	ON cat.intCategoryId = catPricing.intCategoryId
		AND itemLoc.intItemLocationId = catPricing.intItemLocationId



--SELECT * FROM tblSTMarkUpDownDetail

---- Inventory Valuation
--SELECT TOP 1 * 
--FROM vyuICGetInventoryValuationByLocation
--WHERE strItemNo = '1068424206'
--	AND intLocationId = 5
--ORDER BY dtmDate DESC 

--SELECT TOP 1 * 
--FROM vyuICGetInventoryValuationByLocation
--WHERE strItemNo = '1200000579'
--	AND intLocationId = 5
--ORDER BY dtmDate DESC 

---- Retail Valuation
----SELECT * FROM vyuICGetRetailValuationByLocation

--SELECT * FROM	tblICInventoryTransaction
--WHERE intInventoryTransactionId = 1690324

----SELECT [dbo].[fnICGetRunningBalance](1690324)

--DECLARE  @intItemId INT = 68
--	, @intLocationId INT = 5
--	, @intLotId INT = NULL
--	, @intStorageLocationId INT = NULL
--	, @intStorageUnitId INT = NULL
--	, @intCommodityId INT = NULL
--	, @intCategoryId INT = 16
--	, @dtmAsOfDate DATETIME = '2018-11-30 00:00:00.000'
--	, @ysnActiveOnly BIT = 1

--SELECT dbo.fnICGetItemRunningCost(
--	  @intItemId
--	, @intLocationId
--	, @intLotId
--	, @intStorageLocationId
--	, @intStorageUnitId
--	, @intCommodityId
--	, @intCategoryId
--	, @dtmAsOfDate
--	, @ysnActiveOnly
--)
	