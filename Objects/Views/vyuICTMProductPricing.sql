CREATE VIEW [dbo].[vyuICTMProductPricing]
AS
SELECT product.intItemId, product.strShortName, CAST(product.priceId AS NUMERIC(18, 6)) priceId
FROM (
	SELECT item.intItemId, item.strShortName, price.dblPrice priceId
	FROM tblICItem item
		INNER JOIN (
			SELECT
				Item.intItemId intItemId, Item.intLocationId,
				dblPrice = CAST(ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6))
			FROM vyuICGetItemStock Item
				LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = Item.intVendorId
				LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
				LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
				INNER JOIN tblICItemLocation itemLocation ON itemLocation.intItemLocationId = ItemPricing.intItemLocationId
					AND ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) > 0
		) price ON price.intItemId = item.intItemId
	WHERE item.ysnAvailableTM = 1
		OR item.strType = 'Service'

	UNION ALL

	SELECT item.intItemId, item.strShortName, price.dblUnitPrice priceId
	FROM tblICItem item
		INNER JOIN tblICItemPricingLevel price ON price.intItemId = item.intItemId
		INNER JOIN tblICItemLocation itemLocation ON itemLocation.intItemLocationId = price.intItemLocationId
	WHERE item.ysnAvailableTM = 1
		OR item.strType = 'Service'
) product