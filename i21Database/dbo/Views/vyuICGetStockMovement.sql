CREATE VIEW [dbo].[vyuICGetStockMovement]
AS

--SELECT	intInventoryValuationKeyId  = COALESCE(t.intInventoryStockMovementId, i.intItemId) --ISNULL(t.intInventoryStockMovementId, 0) 		
SELECT	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER(ORDER BY commodity.strCommodityCode, c.strCategoryCode, i.strItemNo, [Location].strLocationName, t.dtmDate, t.strTransactionId) AS INT)
									--subLoc.strStorageLocationSorter, subLoc.intStorageLocationSorter, strgLoc.strStorageUnitSorter, strgLoc.intStorageUnitSorter, t.dtmDate) AS INT)
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,intLocationId				= [Location].intCompanyLocationId
		,t.intItemLocationId
		,strLocationName			= [Location].strLocationName
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= dbo.fnRemoveTimeOnDate(t.dtmDate)
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,commodity.intCommodityId
		,strCommodity				= commodity.strCommodityCode 
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
		,intBatchId					= CAST(CASE 
										WHEN CHARINDEX('-',t.strBatchId, PATINDEX('%[0-9]%', t.strBatchId)) = 0 THEN
											SUBSTRING(t.strBatchId, PATINDEX('%[0-9]%',t.strBatchId), LEN(t.strBatchId) - CHARINDEX('-',t.strBatchId))
										ELSE 
											SUBSTRING(t.strBatchId, PATINDEX('%[0-9]%',t.strBatchId), LEN(t.strBatchId) - CHARINDEX('-',t.strBatchId) - CHARINDEX('-', REVERSE(t.strBatchId)))
									END AS INT)
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
		,strParentLotNumber			= ParentLot.strParentLotNumber
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,t.intInventoryTransactionId
		,t.intInventoryTransactionStorageId
		,strOwnership = 
			CASE 
				WHEN t.intOwnershipType = 1 THEN 'Own'
				WHEN t.intOwnershipType = 2 THEN 'Storage'
			END COLLATE Latin1_General_CI_AS
		,dtmCreated					= dbo.fnRemoveTimeOnDate(t.dtmCreated)
		,subLoc.strStorageLocationSorter
		,subLoc.intStorageLocationSorter
		,strgLoc.strStorageUnitSorter
		,strgLoc.intStorageUnitSorter
FROM 	tblICItem i 
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId			
					,umStock.strUnitMeasure
			FROM	tblICItemUOM iuStock INNER JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	iuStock.intItemId = i.intItemId
					AND iuStock.ysnStockUnit = 1 
		) iuStock
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity commodity
			ON commodity.intCommodityId = i.intCommodityId
		LEFT JOIN tblICInventoryStockMovement t 
			ON i.intItemId = t.intItemId
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN (SELECT	intStorageLocationId
							,strName
							,strStorageUnitSorter = CASE WHEN PATINDEX('%[0-9]%', strName) > 1 THEN LEFT(strName, PATINDEX('%[0-9]%', strName) - 1) ELSE strName END
							,intStorageUnitSorter = CASE WHEN PATINDEX('%[0-9]%', strName) > 1 THEN CASE WHEN ISNUMERIC(SUBSTRING(strName, PATINDEX('%[0-9]%', strName), LEN(strName))) = 1 THEN CONVERT(INT, SUBSTRING(strName, PATINDEX('%[0-9]%', strName), LEN(strName))) ELSE NULL END ELSE NULL END
					FROM tblICStorageLocation
			) strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId
		LEFT JOIN (
			tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
				ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
		)
			ON t.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN (SELECT 
					intCompanyLocationSubLocationId
					,strSubLocationName
					,strStorageLocationSorter = CASE WHEN PATINDEX('%[0-9]%', strSubLocationName) > 1 THEN LEFT(strSubLocationName, PATINDEX('%[0-9]%', strSubLocationName) - 1) ELSE strSubLocationName END
					--,intStorageLocationSorter = CASE WHEN PATINDEX('%[0-9]%', strSubLocationName) > 1 THEN CONVERT(INT, SUBSTRING(strSubLocationName, PATINDEX('%[0-9]%', strSubLocationName), LEN(strSubLocationName))) ELSE 0 END
					,intStorageLocationSorter = CASE WHEN PATINDEX('%[0-9]%', strSubLocationName) > 1 THEN CASE WHEN ISNUMERIC(SUBSTRING(strSubLocationName, PATINDEX('%[0-9]%', strSubLocationName), LEN(strSubLocationName))) = 1 THEN CONVERT(INT, SUBSTRING(strSubLocationName, PATINDEX('%[0-9]%', strSubLocationName), LEN(strSubLocationName))) ELSE NULL END ELSE NULL END
					FROM tblSMCompanyLocationSubLocation
			) subLoc
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
		LEFT JOIN tblICParentLot ParentLot
			ON ParentLot.intItemId = l.intItemId
			AND ParentLot.intParentLotId = l.intParentLotId

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
		LEFT JOIN tblGRSettleStorage settleStorage 
			ON settleStorage.intSettleStorageId = t.intTransactionId
			AND settleStorage.intSettleStorageId = t.intTransactionDetailId
			AND t.strTransactionForm IN ('Settle Storage', 'Storage Settlement')
			AND ty.intTransactionTypeId = 44 
		LEFT JOIN tblEMEntity e 
			ON e.intEntityId = COALESCE(
				receipt.intEntityVendorId
				, shipment.intEntityCustomerId
				, invoice.intEntityCustomerId
				, bill.intEntityVendorId
				, loadShipmentSchedule.intVendorEntityId
				, loadShipmentSchedule.intCustomerEntityId
				, settleStorage.intEntityId
			)  
WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)