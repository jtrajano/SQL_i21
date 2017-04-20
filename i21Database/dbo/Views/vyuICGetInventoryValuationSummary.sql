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
FROM	(
			SELECT Item.intItemId, [Transaction].intItemLocationId, 
				[Transaction].intSubLocationId, 
				dblQuantity = SUM([Transaction].dblQty * [Transaction].dblUOMQty), 
				dblValue = SUM(ROUND(ISNULL([Transaction].dblQty, 0) * ISNULL([Transaction].dblCost, 0) + ISNULL([Transaction].dblValue, 0), 2)),
				strStockUOM = umStock.strUnitMeasure,
				dblQuantityInStockUOM = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM([Transaction].intItemUOMId, iuStock.intItemUOMId, [Transaction].dblQty), 0))
			FROM tblICItem Item
				LEFT JOIN tblICInventoryTransaction [Transaction] ON [Transaction].intItemId = Item.intItemId
				LEFT JOIN tblICItemUOM iuStock ON iuStock.intItemId = Item.intItemId
					AND iuStock.ysnStockUnit = 1
				LEFT JOIN tblICUnitMeasure umStock
					ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			GROUP BY Item.intItemId, 
				[Transaction].intItemLocationId, 
				[Transaction].intSubLocationId, umStock.strUnitMeasure
		) [Transaction]
		LEFT JOIN tblICItem Item ON Item.intItemId = [Transaction].intItemId
		LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId
		LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId
WHERE	Item.strType != 'Comment'