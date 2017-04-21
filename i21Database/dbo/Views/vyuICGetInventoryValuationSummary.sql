CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
AS 

SELECT	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY Item.intItemId) AS INT)
		,Item.intItemId
		,strItemNo = Item.strItemNo
		,strItemDescription = Item.strDescription
		,intItemLocationId = ISNULL([Transaction].intItemLocationId, 0)
		,strLocationName = ISNULL(Location.strLocationName, ' ') 
		,intSubLocationId = ISNULL([Transaction].intSubLocationId, 0)
		,strSubLocationName = ISNULL(SubLocation.strSubLocationName, ' ') 
		,dblQuantity = ISNULL(dblQuantity, 0)
		,dblValue = ISNULL(dblValue, 0)
		,dblLastCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblLastCost, 2), 0)
		,dblStandardCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblStandardCost, 2),0)
		,dblAverageCost = ISNULL( ROUND(dblQuantity * ItemPricing.dblAverageCost, 2),0)
		,[Transaction].strStockUOM
		,[Transaction].dblQuantityInStockUOM
		,Category.strCategoryCode
		,Commodity.strCommodityCode
FROM	tblICItem Item 
		OUTER APPLY (
			SELECT 
					ItemLocation.intLocationId
					, [Transaction].intItemLocationId
					, [Transaction].intSubLocationId
					, dblQuantity = SUM([Transaction].dblQty * [Transaction].dblUOMQty) 
					, dblValue = SUM(ROUND(ISNULL([Transaction].dblQty, 0) * ISNULL([Transaction].dblCost, 0) + ISNULL([Transaction].dblValue, 0), 2))
					, strStockUOM = umStock.strUnitMeasure
					, dblQuantityInStockUOM = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM([Transaction].intItemUOMId, iuStock.intItemUOMId, [Transaction].dblQty), 0))
			FROM	tblICInventoryTransaction [Transaction] INNER JOIN tblICItemLocation ItemLocation 
						ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId
					LEFT JOIN tblICItemUOM iuStock 
						ON iuStock.intItemId = [Transaction].intItemId
						AND iuStock.ysnStockUnit = 1
					LEFT JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	Item.intItemId = [Transaction].intItemId
			GROUP BY 
				ItemLocation.intLocationId
				, [Transaction].intItemLocationId
				,[Transaction].intSubLocationId
				,umStock.strUnitMeasure
		) [Transaction]							
		
		LEFT JOIN tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = [Transaction].intItemLocationId
		LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = [Transaction].intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId
		LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
		LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId

WHERE	Item.strType NOT IN ('Other Charge', 'Non-Inventory', 'Service', 'Software', 'Comment')