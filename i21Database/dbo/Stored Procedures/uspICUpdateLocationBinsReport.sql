CREATE PROCEDURE [dbo].[uspICUpdateLocationBinsReport] @intUserId AS INT = NULL 
AS
DELETE FROM tblICLocationBinsReport

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
	 Item.intItemId
	,Item.strItemNo
	,Item.strType
	,Item.strDescription
	,Item.strLotTracking
	,Item.strInventoryTracking
	,Item.strStatus
	,ItemLocation.intLocationId
	,ItemLocation.intItemLocationId
	,ItemLocation.intSubLocationId
	,Item.intCategoryId
	,Category.strCategoryCode
	,Item.intCommodityId
	,Commodity.strCommodityCode
	,ItemLocation.intStorageLocationId
	,l.strLocationName
	,l.strLocationType
	,intStockUOMId = StockUOM.intItemUOMId
	,strStockUOM = sUOM.strUnitMeasure
	,strStockUOMType = sUOM.strUnitType
	,dblStockUnitQty = StockUOM.dblUnitQty
	,ItemLocation.intAllowNegativeInventory
	,strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END) COLLATE Latin1_General_CI_AS
	,ItemLocation.intCostingMethod
	,strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END) COLLATE Latin1_General_CI_AS
	,dblAmountPercent = ISNULL(ItemPricing.dblAmountPercent, 0.00)
	,dblSalePrice = ISNULL(ItemPricing.dblSalePrice, 0.00)
	,dblMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0.00)
	,ItemPricing.strPricingMethod
	,dblLastCost = ISNULL(ItemPricing.dblLastCost, 0.00)
	,dblStandardCost = ISNULL(ItemPricing.dblStandardCost, 0.00)
	,dblAverageCost = ISNULL(ItemPricing.dblAverageCost, 0.00)
	,dblEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0.00)

	,dblOnOrder = ISNULL(ItemStockUOM.dblOnOrder, 0.00)
	,dblInTransitInbound = ISNULL(ItemStockUOM.dblInTransitInbound, 0.00)
	,dblUnitOnHand = CAST(ISNULL(ItemStockUOM.dblOnHand, 0.00) AS NUMERIC(38, 7))
	,dblInTransitOutbound = ISNULL(ItemStockUOM.dblInTransitOutbound, 0)
	,dblBackOrder =	dbo.fnMaxNumeric(ISNULL(ItemStockUOM.dblOrderCommitted, 0.00) - (ISNULL(ItemStockUOM.dblOnHand, 0.00) - (ISNULL(ItemStockUOM.dblUnitReserved, 0.00) + ISNULL(ItemStockUOM.dblConsignedSale, 0.00))), 0)
	,dblOrderCommitted = ISNULL(ItemStockUOM.dblOrderCommitted, 0.00)
	,dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0.00)
	,dblConsignedPurchase = ISNULL(ItemStockUOM.dblConsignedPurchase, 0.00)
	,dblConsignedSale = ISNULL(ItemStockUOM.dblConsignedSale, 0.00)
	,dblUnitReserved = ISNULL(ItemStockUOM.dblUnitReserved, 0.00)
	,dblAvailable = 
			ISNULL(ItemStockUOM.dblOnHand, 0.00)  
			- ISNULL(ItemStockUOM.dblUnitReserved, 0.00)
			- ISNULL(ItemStockUOM.dblConsignedSale, 0.00)
			+ ISNULL(ItemStockUOM.dblUnitStorage, 0.00)
	,dblExtended = 
			(
				ISNULL(ItemStockUOM.dblOnHand, 0.00) 
				+ ISNULL(ItemStockUOM.dblUnitStorage,0.00) 
				+ ISNULL(ItemStockUOM.dblConsignedPurchase, 0.00)
			) 
			* ISNULL(ItemPricing.dblAverageCost, 0.00)
	,dblExtendedRetail = (ISNULL(ItemStockUOM.dblOnHand, 0.00) + ISNULL(ItemStockUOM.dblUnitStorage,0.00) + ISNULL(ItemStockUOM.dblConsignedPurchase, 0.00))* ISNULL(ItemPricing.dblSalePrice, 0.00)
	,dblMinOrder = ISNULL(ItemLocation.dblMinOrder, 0.00)
	,dblLeadTime = ISNULL(ItemLocation.dblLeadTime, 0.00)
	,dblSuggestedQty = ISNULL(ItemLocation.dblSuggestedQty, 0.00)
	,dblReorderPoint = ISNULL(ItemLocation.dblReorderPoint, 0.00)
	,dblNearingReorderBy = CAST(ISNULL(ItemStockUOM.dblOnHand, 0.00) - ISNULL(ItemLocation.dblReorderPoint, 0.00) AS NUMERIC(38, 7))
	,dblCapacity = ISNULL(ItemStockUOM.dblCapacity, 0.00)
	,dblSpaceAvailable = ISNULL(ItemStockUOM.dblAvailable, 0.00)
	,dblPercentFull = ISNULL(ItemStockUOM.dblPercentFull, 0.00)
	,dtmLastPurchaseDate = ItemStockUOM.dtmLastPurchaseDate
	,dtmLastSaleDate = ItemStockUOM.dtmLastSaleDate
	,strEntityVendor = VendorEntity.strName
	,dblAverageUsagePerPeriod = CAST(ISNULL(AvgUsagePerPeriod.dblAvgUsagePerPeriod, 0.00) AS NUMERIC(38, 7))
	,dblInTransitDirect = ISNULL(ItemStockUOM.dblInTransitDirect, 0)
	,GETUTCDATE()
	,@intUserId
FROM	
	tblICItem Item 
	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = Item.intGradeId
	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	)
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId IS NOT NULL
	LEFT JOIN tblEMEntity VendorEntity
		ON VendorEntity.intEntityId = ItemLocation.intVendorId

	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemPricing.intItemId = Item.intItemId 
		AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	LEFT JOIN (
		tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	)
		ON StockUOM.intItemId = Item.intItemId 
		AND StockUOM.ysnStockUnit = 1
	OUTER APPLY (
		SELECT	ItemStockUOM.intItemId
				,ItemStockUOM.intItemLocationId				
				,dblOnOrder = SUM(ISNULL(dblOnOrder, 0)) 
				,dblOrderCommitted = SUM(ISNULL(dblOrderCommitted, 0)) 
				,dblOnHand = SUM(ISNULL(dblOnHand, 0)) 
				,dblUnitReserved = SUM(ISNULL(dblUnitReserved, 0)) 
				,dblInTransitInbound = SUM(ISNULL(dblInTransitInbound, 0)) 
				,dblInTransitOutbound = SUM(ISNULL(dblInTransitOutbound, 0)) 
				,dblInTransitDirect = SUM(ISNULL(dblInTransitDirect, 0)) 
				,dblUnitStorage = SUM(ISNULL(dblUnitStorage, 0)) 
				,dblConsignedPurchase = SUM(ISNULL(dblConsignedPurchase, 0)) 
				,dblConsignedSale = SUM(ISNULL(dblConsignedSale, 0)) 
				,dblCapacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
				,dblAvailable = 
					SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
					- SUM(ISNULL(dblOnHand, 0)) 
					- SUM(ISNULL(dblUnitStorage, 0))
				,dblPercentFull = 
					CASE 
						WHEN SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0)) <> 0 THEN 
							dbo.fnMultiply (
								dbo.fnDivide(
									(
										SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
										- SUM(ISNULL(dblOnHand, 0)) 
										- SUM(ISNULL(dblUnitStorage, 0))
									)
									, SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
								)
								, 100
							)
						ELSE 
							NULL 
					END
				,dtmLastPurchaseDate = MAX(ItemStockUOM.dtmLastPurchaseDate)
				,dtmLastSaleDate = MAX(ItemStockUOM.dtmLastSaleDate) 						
		FROM	tblICItemStockUOM ItemStockUOM LEFT JOIN tblICStorageLocation sl
					ON sl.intStorageLocationId = ItemStockUOM.intStorageLocationId
		WHERE	ItemStockUOM.intItemId = Item.intItemId 
				AND ItemStockUOM.intItemUOMId = StockUOM.intItemUOMId
				AND ItemStockUOM.intItemLocationId = ItemLocation.intItemLocationId
		GROUP BY 
				ItemStockUOM.intItemId
				,ItemStockUOM.intItemLocationId
	) ItemStockUOM

	OUTER APPLY(
		SELECT dblAvgUsagePerPeriod = dbo.fnDivide(SUM([dbo].[fnICConvertUOMtoStockUnit](Details.intItemId, Details.intItemUOMId, Details.dblQty)), MONTH(GETDATE()))
		FROM (
			SELECT	InvDet.intItemId
					,InvDet.intItemUOMId
					,ItemLocation.intItemLocationId
					,dblQty = CASE WHEN Inv.strTransactionType = 'Credit Memo'
							THEN -InvDet.dblQtyShipped
							ELSE InvDet.dblQtyShipped
						END
			FROM tblARInvoice Inv
			INNER JOIN tblARInvoiceDetail InvDet
				ON InvDet.intInvoiceId = Inv.intInvoiceId
			INNER JOIN tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = InvDet.intItemId
				AND ItemLocation.intLocationId = Inv.intCompanyLocationId
			WHERE Inv.ysnPosted = 1 
				AND Inv.strTransactionType IN(
					'Invoice'
					,'Cash'
					,'Credit Memo'
					,'Debit Memo'
				)
				AND YEAR(Inv.dtmDate) = YEAR(GETDATE())
			UNION ALL
			SELECT	PrepaidDetail.intItemId
					,PrepaidDetail.intItemUOMId
					,ItemLocation.intItemLocationId
					,dblQty = -PrepaidDetail.dblQtyShipped
			FROM tblARInvoice Inv
			INNER JOIN tblARPrepaidAndCredit Prepaid
				ON Prepaid.intInvoiceId = Inv.intInvoiceId
			INNER JOIN tblARInvoiceDetail PrepaidDetail
				ON PrepaidDetail.intInvoiceId = Prepaid.intPrepaymentId
			INNER JOIN tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = PrepaidDetail.intItemId
				AND ItemLocation.intLocationId = Inv.intCompanyLocationId
			WHERE Inv.ysnPosted = 1 
				AND Inv.strTransactionType IN(
					'Cash Refund'
				)	
				AND YEAR(Inv.dtmDate) = YEAR(GETDATE())
		) Details
		WHERE Details.intItemId = ItemStockUOM.intItemId
			AND Details.intItemLocationId = ItemStockUOM.intItemLocationId
	) AvgUsagePerPeriod