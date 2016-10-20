CREATE VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT	-- Commented because ROW_NUMBER() will slow down huge set of data. 
			--CASE 	WHEN t.intInventoryTransactionId IS NULL THEN 
			--			CAST(ROW_NUMBER() OVER (ORDER BY t.intInventoryTransactionId) AS INT)
			--		ELSE 
			--			t.intInventoryTransactionId
			--END
		intInventoryValuationKeyId  = ISNULL(t.intInventoryTransactionId, 0) 
		,intInventoryTransactionId	= ISNULL(t.intInventoryTransactionId, 0) 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,t.intItemLocationId
		,cl.strLocationName
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
		,strBatchId
		,CostingMethod.strCostingMethod
		,strUOM						= umTransUOM.strUnitMeasure
		,strStockUOM				= umStock.strUnitMeasure
		,dblQuantityInStockUOM		= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,dblCostInStockUOM			= ISNULL(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblCost), 0)
		,strBOLNumber				= CAST (
											CASE	ty.intTransactionTypeId 
													WHEN 4 THEN receipt.strBillOfLading 
													WHEN 5 THEN shipment.strBOLNumber 
													ELSE NULL 
											END
										AS NVARCHAR(100)
									)
		,strEntity					= e.strName										
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
FROM 	tblICItem i LEFT JOIN tblICItemUOM iuStock
			ON iuStock.intItemId = i.intItemId
			AND iuStock.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure umStock
			ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICInventoryTransaction t 
			ON i.intItemId = t.intItemId
		LEFT JOIN tblICLot l
			ON l.intLotId = t.intLotId
		LEFT JOIN tblICItemUOM iuTransUOM
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICUnitMeasure umTransUOM
			ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId		
		LEFT JOIN tblICItemLocation il 
			ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId) 
		LEFT JOIN tblICCostingMethod CostingMethod
			ON CostingMethod.intCostingMethodId = t.intCostingMethod
		LEFT JOIN tblSMCompanyLocation cl 
			ON cl.intCompanyLocationId = il.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc 
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN tblICInventoryReceipt receipt 
			ON receipt.intInventoryReceiptId = t.intTransactionId
			AND receipt.strReceiptNumber = t.strTransactionId
		LEFT JOIN tblICInventoryShipment shipment 
			ON shipment.intInventoryShipmentId = t.intTransactionId
			AND shipment.strShipmentNumber = t.strTransactionId
		LEFT JOIN tblARInvoice invoice
			ON invoice.intInvoiceId = t.intTransactionId
			AND invoice.strInvoiceNumber = t.strTransactionId
		LEFT JOIN tblEMEntity e 
			ON e.intEntityId = ISNULL(receipt.intEntityVendorId, shipment.intEntityCustomerId)

WHERE	i.strType != 'Comment'