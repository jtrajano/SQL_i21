CREATE PROCEDURE [dbo].[uspICUpdateLocationBinsReport] 
	@intUserId AS INT = NULL 
	,@ysnForceRebuild AS BIT 
	,@ysnIsRebuilding AS BIT OUTPUT 
AS

SET @ysnIsRebuilding = 1

-- If rebuild is in-progress, leave immediately to avoid deadlocks. 
IF EXISTS (SELECT TOP 1 1 FROM tblICLocationBinsReportLog (NOLOCK) WHERE ysnRebuilding = 1)
BEGIN 
	RETURN; 
END 

-- Do not rebuild the Locations YTD report if it is still up-to-date. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM 
		tblICLocationBinsReportLog (NOLOCK) l 
	WHERE 
		ABS(DATEDIFF(DAY, l.dtmLastRun, GETDATE())) <= 1
)
AND @ysnForceRebuild <> 1
BEGIN 
	SET @ysnIsRebuilding = 0
	RETURN; 
END 

-- Create or update the log. 
IF NOT EXISTS (SELECT TOP 1 1 FROM tblICLocationBinsReportLog) 
BEGIN 
	INSERT INTO tblICLocationBinsReportLog (
		dtmLastRun
		,ysnRebuilding
		,dtmStart
		,intEntityUserSecurityId
	)
	VALUES (
		dbo.fnRemoveTimeOnDate(GETDATE()) 
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
	FROM tblICLocationBinsReportLog l
END 

TRUNCATE TABLE tblICLocationBinsReport

INSERT INTO tblICLocationBinsReport(
     [intItemId]
   , [strItemNo]
   , [strType]
   , [strDescription]
   , [strLotTracking]
   , [strInventoryTracking]
   , [strStatus]
   , [intLocationId]
   , [intItemLocationId]
   , [intSubLocationId]
   , [intCategoryId]
   , [strCategoryCode]
   , [intCommodityId]
   , [strCommodityCode]
   , [intStorageLocationId]
   , [strLocationName]
   , [strLocationType]
   , [intStockUOMId]
   , [strStockUOM]
   , [strStockUOMType]
   , [dblStockUnitQty]
   , [intAllowNegativeInventory]
   , [strAllowNegativeInventory]
   , [intCostingMethod]
   , [strCostingMethod]
   , [dblAmountPercent]
   , [dblSalePrice]
   , [dblMSRPPrice]
   , [strPricingMethod]
   , [dblLastCost]
   , [dblStandardCost]
   , [dblAverageCost]
   , [dblEndMonthCost]
   , [dblOnOrder]
   , [dblInTransitInbound]
   , [dblUnitOnHand]
   , [dblInTransitOutbound]
   , [dblBackOrder]
   , [dblOrderCommitted]
   , [dblUnitStorage]
   , [dblConsignedPurchase]
   , [dblConsignedSale]
   , [dblUnitReserved]
   , [dblAvailable]
   , [dblExtended]
   , [dblExtendedRetail]
   , [dblMinOrder]
   , [dblLeadTime]
   , [dblSuggestedQty]
   , [dblReorderPoint]
   , [dblNearingReorderBy]
   , [dblCapacity]
   , [dblSpaceAvailable]
   , [dblPercentFull]
   , [dtmLastPurchaseDate]
   , [dtmLastSaleDate]
   , [strEntityVendor]
   , [dblAverageUsagePerPeriod]
   , [dblInTransitDirect]
   , [dtmDateCreated]
   , [intCreatedByUserId]
)
SELECT 
     [intItemId]
   , [strItemNo]
   , [strType]
   , [strDescription]
   , [strLotTracking]
   , [strInventoryTracking]
   , [strStatus]
   , [intLocationId]
   , [intItemLocationId]
   , [intSubLocationId]
   , [intCategoryId]
   , [strCategoryCode]
   , [intCommodityId]
   , [strCommodityCode]
   , [intStorageLocationId]
   , [strLocationName]
   , [strLocationType]
   , [intStockUOMId]
   , [strStockUOM]
   , [strStockUOMType]
   , [dblStockUnitQty]
   , [intAllowNegativeInventory]
   , [strAllowNegativeInventory]
   , [intCostingMethod]
   , [strCostingMethod]
   , [dblAmountPercent]
   , [dblSalePrice]
   , [dblMSRPPrice]
   , [strPricingMethod]
   , [dblLastCost]
   , [dblStandardCost]
   , [dblAverageCost]
   , [dblEndMonthCost]
   , [dblOnOrder]
   , [dblInTransitInbound]
   , [dblUnitOnHand]
   , [dblInTransitOutbound]
   , [dblBackOrder]
   , [dblOrderCommitted]
   , [dblUnitStorage]
   , [dblConsignedPurchase]
   , [dblConsignedSale]
   , [dblUnitReserved]
   , [dblAvailable]
   , [dblExtended]
   , [dblExtendedRetail]
   , [dblMinOrder]
   , [dblLeadTime]
   , [dblSuggestedQty]
   , [dblReorderPoint]
   , [dblNearingReorderBy]
   , [dblCapacity]
   , [dblSpaceAvailable]
   , [dblPercentFull]
   , [dtmLastPurchaseDate]
   , [dtmLastSaleDate]
   , [strEntityVendor]
   , [dblAverageUsagePerPeriod]
   , [dblInTransitDirect]
	,GETUTCDATE()
	,@intUserId
FROM
	vyuICGetLocationBins


UPDATE tblICLocationBinsReportLog 
SET ysnRebuilding = 0 
	,dtmEnd = GETDATE() 

SET @ysnIsRebuilding = 0 