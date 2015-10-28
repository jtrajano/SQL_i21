CREATE VIEW [dbo].[vyuICGetInventoryValuationSummary]
	AS 

SELECT 
	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER(ORDER BY [Transaction].intItemId) AS INT),
	[Transaction].intItemId,
	strItemNo = Item.strItemNo,
	strItemDescription = Item.strDescription,
	[Transaction].intItemLocationId,
	Location.strLocationName,
	[Transaction].intSubLocationId,
	SubLocation.strSubLocationName,
	dblQuantity,
	dblValue,
	dblLastCost = dblQuantity * ItemPricing.dblLastCost,
	dblStandardCost = dblQuantity * ItemPricing.dblStandardCost,
	dblAverageCost = dblQuantity * ItemPricing.dblAverageCost
FROM (
	SELECT [Transaction].intItemId,
		[Transaction].intItemLocationId,
		[Transaction].intSubLocationId,
		dblQuantity = SUM([Transaction].dblQty * [Transaction].dblUOMQty),
		dblValue = SUM(([Transaction].dblQty * [Transaction].dblUOMQty * [Transaction].dblCost) + [Transaction].dblValue)
	FROM tblICInventoryTransaction [Transaction]
	GROUP BY [Transaction].intItemId,
		[Transaction].intItemLocationId,
		[Transaction].intSubLocationId
	) [Transaction]
LEFT JOIN tblICItem Item ON Item.intItemId = [Transaction].intItemId
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId
LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId