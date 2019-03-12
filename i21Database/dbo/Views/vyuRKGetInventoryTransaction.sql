CREATE VIEW vyuRKGetInventoryTransaction

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
		,t.strTransactionForm	
		,t.intTransactionId	
		,t.strTransactionId	
		,t.intTransactionDetailId	
		,dblQuantity				= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,t.strBatchId	
		,strUOM						= umTransUOM.strUnitMeasure
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,ysnInTransit				= CAST(CASE WHEN InTransitLocation.intCompanyLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
		,t.dtmCreated
		,t.intCurrencyId
		,cur.strCurrency
		,i.intOriginId
		,i.strMarketValuation
		,i.strLotTracking
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

		LEFT JOIN tblSMCurrency cur
			ON cur.intCurrencyID = t.intCurrencyId
		LEFT JOIN (
			tblICItemUOM iuTransUOM INNER JOIN tblICUnitMeasure umTransUOM
				ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId			
		)
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)