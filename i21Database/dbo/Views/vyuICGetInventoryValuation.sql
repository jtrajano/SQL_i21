CREATE VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT	intInventoryValuationKeyId  = 
			CASE 	WHEN t.intInventoryTransactionId IS NULL THEN 
						CAST(ROW_NUMBER() OVER (ORDER BY t.intInventoryTransactionId) AS INT)
					ELSE 
						t.intInventoryTransactionId
			END 
		,t.intInventoryTransactionId
		,t.intItemId
		,strItemNo				= i.strItemNo
		,strItemDescription		= i.strDescription
		,i.intCategoryId
		,strCategory			= c.strCategoryCode
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
		,dblQuantity				= t.dblQty 
		,dblRunningQtyBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblCost					= t.dblCost
		,dblBeginningBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblValue					= ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2) 
		,dblRunningBalance			= CAST(0 AS NUMERIC(38, 20))
		,strBatchId
		,CostingMethod.strCostingMethod
		,strUOM						= umTransUOM.strUnitMeasure
		,strStockUOM				= umStock.strUnitMeasure
		,dblQuantityInStockUOM		= dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty) 
		,dblCostInStockUOM			= dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblCost) 
FROM 	tblICItem i LEFT JOIN tblICItemUOM iuStock
			ON iuStock.intItemId = i.intItemId
			AND iuStock.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure umStock
			ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICInventoryTransaction t 
			ON i.intItemId = t.intItemId
		LEFT JOIN tblICItemUOM iuTransUOM
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICUnitMeasure umTransUOM
			ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId		
		LEFT JOIN tblICItemLocation il 
			ON il.intItemLocationId = t.intItemLocationId
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