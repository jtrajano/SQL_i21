CREATE VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT	intInventoryValuationKeyId  = ISNULL(t.intInventoryTransactionId, 0) 
		,intInventoryTransactionId	= ISNULL(t.intInventoryTransactionId, 0) 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,intLocationId				= ISNULL(InTransitLocation.intCompanyLocationId, [Location].intCompanyLocationId) 
		,t.intItemLocationId
		,strLocationName			= ISNULL(InTransitLocation.strLocationName, [Location].strLocationName) --ISNULL([Location].strLocationName, InTransitLocation.strLocationName + ' (' + ItemLocation.strDescription + ')') 
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= dbo.fnRemoveTimeOnDate(t.dtmDate)
		,strTransactionType			= ty.strName
		,t.strTransactionForm
		,t.strTransactionId
		,dblBeginningQtyBalance		= CAST(0 AS NUMERIC(38, 20)) 
		,dblQuantity				= ISNULL(t.dblQty, 0)
		,dblRunningQtyBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblCost					= ISNULL(t.dblCost, 0)
		,dblBeginningBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblValue					= ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)   --ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2) 
		,dblRunningBalance			= CAST(0 AS NUMERIC(38, 20))
		,t.strBatchId
		,CostingMethod.strCostingMethod
		,strUOM						= umTransUOM.strUnitMeasure
		,strStockUOM				= iuStock.strUnitMeasure
		,dblQuantityInStockUOM		= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,dblCostInStockUOM			= ISNULL(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblCost), 0)
		,strBOLNumber				= CAST (
											CASE	ty.intTransactionTypeId 
													WHEN 4 THEN receipt.strBillOfLading 
													WHEN 42 THEN receipt.strBillOfLading 
													WHEN 5 THEN shipment.strBOLNumber 
													WHEN 33 THEN invoice.strBOLNumber 
													WHEN 44 THEN loadShipmentSchedule.strBLNumber
													ELSE NULL 
											END
										AS NVARCHAR(100)
									)
		,strEntity					= e.strName										
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,ysnInTransit				= CAST(CASE WHEN InTransitLocation.intCompanyLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
FROM 	tblICItem i 
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId			
					,umStock.strUnitMeasure
			FROM	tblICItemUOM iuStock INNER JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	iuStock.intItemId = i.intItemId
					AND iuStock.ysnStockUnit = 1 -- TODO: In 18.3, change it to use the [Stock UOM] instead of [Stock Unit]. 
					--AND iuStock.ysnStockUOM = 1
		) iuStock
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICInventoryTransaction t 
			ON i.intItemId = t.intItemId
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId
		LEFT JOIN (
			tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
				ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
		)
			ON t.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN (
			tblICItemLocation InTransitItemLocation INNER JOIN tblSMCompanyLocation InTransitLocation 
				ON InTransitLocation.intCompanyLocationId = InTransitItemLocation.intLocationId	
		)
			ON t.intInTransitSourceLocationId = InTransitItemLocation.intItemLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId
		LEFT JOIN tblICCostingMethod CostingMethod
			ON CostingMethod.intCostingMethodId = t.intCostingMethod
		LEFT JOIN (
			tblICItemUOM iuTransUOM INNER JOIN tblICUnitMeasure umTransUOM
				ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId			
		)
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICLot l
			ON l.intLotId = t.intLotId

		LEFT JOIN tblICInventoryReceipt receipt 
			ON receipt.intInventoryReceiptId = t.intTransactionId
			AND receipt.strReceiptNumber = t.strTransactionId
			AND ty.intTransactionTypeId IN (4, 42)
		LEFT JOIN tblICInventoryShipment shipment 
			ON shipment.intInventoryShipmentId = t.intTransactionId
			AND shipment.strShipmentNumber = t.strTransactionId
			AND ty.intTransactionTypeId = 5
		LEFT JOIN tblARInvoice invoice
			ON invoice.intInvoiceId = t.intTransactionId
			AND invoice.strInvoiceNumber = t.strTransactionId
			AND ty.intTransactionTypeId = 33
		LEFT JOIN tblAPBill bill
			ON bill.intBillId = t.intTransactionId
			AND bill.strBillId = t.strTransactionId
			AND ty.intTransactionTypeId IN (26, 27) 
		OUTER APPLY (
			SELECT	TOP 1 
					ld.intVendorEntityId
					,ld.intCustomerEntityId
					,l.strBLNumber
			FROM	tblLGLoad l INNER JOIN tblLGLoadDetail ld
						ON l.intLoadId = ld.intLoadId
			WHERE	l.strLoadNumber = t.strTransactionId
					AND ld.intLoadDetailId = t.intTransactionDetailId
					AND l.intLoadId = t.intTransactionId
					AND ld.intItemId = t.intItemId		
					AND ty.intTransactionTypeId = 44
		) loadShipmentSchedule 
		LEFT JOIN tblEMEntity e 
			ON e.intEntityId = COALESCE(
				receipt.intEntityVendorId
				, shipment.intEntityCustomerId
				, invoice.intEntityCustomerId
				, bill.intEntityVendorId
				, loadShipmentSchedule.intVendorEntityId
				, loadShipmentSchedule.intCustomerEntityId
			)  
WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)