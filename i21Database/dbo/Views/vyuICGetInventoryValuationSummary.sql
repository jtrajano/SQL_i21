CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
	AS 

SELECT intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY Item.intItemId) AS INT), 
	Item.intItemId, 
	strItemNo = Item.strItemNo, 
	strItemDescription = Item.strDescription, 
	ISNULL([Transaction].intItemLocationId, 0) AS intItemLocationId, 
	ISNULL(Location.strLocationName, ' ') AS strLocationName, 
	ISNULL([Transaction].intSubLocationId, 0) AS intSubLocationId, 
	ISNULL (SubLocation.strSubLocationName, ' ') AS strSubLocationName, 
	ISNULL(dblQuantity, 0) AS dblQuantity, 
	ISNULL(dblValue, 0) AS dblValue, 
	ISNULL((dblQuantity * ItemPricing.dblLastCost), 0) AS dblLastCost, 
	ISNULL((dblQuantity * ItemPricing.dblStandardCost),0) AS dblStandardCost, 
	ISNULL((dblQuantity * ItemPricing.dblAverageCost),0) AS dblAverageCost,
	[Transaction].strStockUOM,
	[Transaction].dblQuantityInStockUOM
FROM (
	SELECT Item.intItemId, [Transaction].intItemLocationId, 
		[Transaction].intSubLocationId, 
		dblQuantity = SUM([Transaction].dblQty * [Transaction].dblUOMQty), 
		dblValue = SUM(ISNULL([Transaction].dblQty, 0) * ISNULL([Transaction].dblCost, 0) + ISNULL([Transaction].dblValue, 0)),
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