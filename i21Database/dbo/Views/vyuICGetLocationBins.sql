﻿CREATE VIEW [dbo].[vyuICGetLocationBins]
AS 
SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId) AS INT)
	,Item.intItemId
	,Item.strItemNo
	,Item.strType
	,Item.strDescription
	,Item.strLotTracking
	,Item.strInventoryTracking
	,Item.strStatus
	,ItemLocation.intLocationId
	,ItemLocation.intItemLocationId
	,ItemLocation.intSubLocationId
	,ItemLocation.strStorageUnitNo
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

	,dblOnOrder = dbo.fnMaxNumeric(ISNULL(ItemStock.dblOnOrder, 0.00) - ISNULL(ItemStock.dblOpenReceive, 0.00), 0)
	,dblInTransitInbound = ISNULL(ItemStock.dblInTransitInbound, 0.00)
	,dblUnitOnHand = CAST(ISNULL(ItemStock.dblOnHand, 0.00) AS NUMERIC(38, 7))
	,dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0)
	,dblBackOrder =	dbo.fnMaxNumeric(ISNULL(ItemStock.dblOrderCommitted, 0.00) - (ISNULL(ItemStock.dblOnHand, 0.00) - (ISNULL(ItemStock.dblUnitReserved, 0.00) + ISNULL(ItemStock.dblConsignedSale, 0.00))), 0)
	,dblOrderCommitted = ISNULL(ItemStock.dblOrderCommitted, 0.00)
	,dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0.00)
	,dblConsignedPurchase = ISNULL(ItemStock.dblConsignedPurchase, 0.00)
	,dblConsignedSale = ISNULL(ItemStock.dblConsignedSale, 0.00)
	,dblUnitReserved = ISNULL(ItemStock.dblUnitReserved, 0.00)
	,dblAvailable = 
			ISNULL(ItemStock.dblOnHand, 0.00)  
			- ISNULL(ItemStock.dblUnitReserved, 0.00)
			- ISNULL(ItemStock.dblConsignedSale, 0.00)
			+ ISNULL(ItemStock.dblUnitStorage, 0.00)
	,dblExtended = 
			(
				ISNULL(ItemStock.dblOnHand, 0.00) 
				+ ISNULL(ItemStock.dblUnitStorage,0.00) 
				+ ISNULL(ItemStock.dblConsignedPurchase, 0.00)
			) 
			* ISNULL(ItemPricing.dblAverageCost, 0.00)
	,dblExtendedRetail = (ISNULL(ItemStock.dblOnHand, 0.00) + ISNULL(ItemStock.dblUnitStorage,0.00) + ISNULL(ItemStock.dblConsignedPurchase, 0.00))* ISNULL(ItemPricing.dblSalePrice, 0.00)
	,dblMinOrder = ISNULL(ItemLocation.dblMinOrder, 0.00)
	,dblLeadTime = ISNULL(ItemLocation.dblLeadTime, 0.00)
	,dblSuggestedQty = ISNULL(ItemLocation.dblSuggestedQty, 0.00)
	,dblReorderPoint = ISNULL(ItemLocation.dblReorderPoint, 0.00)
	,dblNearingReorderBy = CAST(ISNULL(ItemStock.dblOnHand, 0.00) - ISNULL(ItemLocation.dblReorderPoint, 0.00) AS NUMERIC(38, 7))
	,dblCapacity = --ISNULL(ItemStock.dblCapacity, 0.00)
		ISNULL(StorageLocation.dblCapacity, 0)

	,dblSpaceAvailable = --ISNULL(ItemStock.dblAvailable, 0.00)
		CASE 
			WHEN ISNULL(StorageLocation.dblCapacity, 0) <> 0 THEN 
				ISNULL(StorageLocation.dblCapacity, 0)
				- ISNULL(ItemStock.dblOnHand, 0)
				- ISNULL(ItemStock.dblUnitStorage, 0)
			ELSE 
				0.00
		END 

	,dblPercentFull = -- ISNULL(ItemStock.dblPercentFull, 0.00)
		CASE 
			WHEN ISNULL(StorageLocation.dblCapacity, 0) <> 0 THEN 
				dbo.fnMultiply(
					dbo.fnDivide(
						ISNULL(StorageLocation.dblCapacity, 0)
						,ISNULL(StorageLocation.dblCapacity, 0) - ISNULL(ItemStock.dblOnHand, 0) - ISNULL(ItemStock.dblUnitStorage, 0)
					)
					, 100
				)
			ELSE 
				0.00 
		END

	,dtmLastPurchaseDate = ItemStock.dtmLastPurchaseDate
	,dtmLastSaleDate = ItemStock.dtmLastSaleDate
	,strEntityVendor = VendorEntity.strName
	,dblAverageUsagePerPeriod = CAST(ISNULL(AvgUsagePerPeriod.dblAvgUsagePerPeriod, 0.00) AS NUMERIC(38, 7))
	,dblInTransitDirect = ISNULL(ItemStock.dblInTransitDirect, 0)
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
		SELECT	ItemStock.intItemId
				,ItemStock.intItemLocationId				
				,dblOnOrder = SUM(ISNULL(dblOnOrder, 0)) 
				,dblOpenReceive = SUM(purchase.dblOpenReceive)
				,dblOrderCommitted = SUM(ISNULL(dblOrderCommitted, 0)) 
				,dblOnHand = SUM(ISNULL(dblUnitOnHand, 0)) 
				,dblUnitReserved = SUM(ISNULL(dblUnitReserved, 0)) 
				,dblInTransitInbound = SUM(ISNULL(dblInTransitInbound, 0)) 
				,dblInTransitOutbound = SUM(ISNULL(dblInTransitOutbound, 0)) 
				,dblInTransitDirect = SUM(ISNULL(dblInTransitDirect, 0)) 
				,dblUnitStorage = SUM(ISNULL(dblUnitStorage, 0)) 
				,dblConsignedPurchase = SUM(ISNULL(dblConsignedPurchase, 0)) 
				,dblConsignedSale = SUM(ISNULL(dblConsignedSale, 0)) 
				,dtmLastPurchaseDate = MAX(ItemStock.dtmLastPurchaseDate)
				,dtmLastSaleDate = MAX(ItemStock.dtmLastSaleDate) 						
		FROM	tblICItemStock ItemStock 
			INNER JOIN tblICItemLocation il ON il.intItemLocationId = ItemStock.intItemLocationId
			OUTER APPLY (
				SELECT SUM(pr.dblOpenReceive) dblOpenReceive
				FROM vyuICPurchaseReceipts pr
				WHERE pr.intItemId = ItemStock.intItemId
					AND pr.intStockUOM = StockUOM.intItemUOMId
					AND pr.intLocationId = il.intLocationId
			) purchase
		WHERE	ItemStock.intItemId = Item.intItemId 
				AND ItemStock.intItemLocationId = ItemLocation.intItemLocationId
		GROUP BY 
				ItemStock.intItemId
				,ItemStock.intItemLocationId
	) ItemStock

	OUTER APPLY (
		SELECT 
			dblCapacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
		FROM 
			tblICStorageLocation sl
		WHERE
			sl.intItemId = Item.intItemId
			AND sl.intLocationId = ItemLocation.intLocationId
	
	) StorageLocation

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
		WHERE Details.intItemId = ItemStock.intItemId
			AND Details.intItemLocationId = ItemStock.intItemLocationId
	) AvgUsagePerPeriod