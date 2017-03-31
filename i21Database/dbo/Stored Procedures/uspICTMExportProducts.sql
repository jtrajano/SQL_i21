CREATE PROCEDURE [dbo].[uspICTMExportProducts]
	@intEntityUserSecurityId INT
AS
DECLARE @intDefaultLocationId INT

SELECT @intDefaultLocationId = intCompanyLocationId
FROM tblSMUserSecurity
WHERE [intEntityId] = @intEntityUserSecurityId

SELECT
	CAST(item.strItemNo AS NVARCHAR(16)) code
	, CAST(item.strShortName AS NVARCHAR(35)) name
	, CAST(MAX(prices.dblPrice) AS NVARCHAR(16)) priceID
	, CAST('' AS NVARCHAR(8)) taxCode
	, 0 aux1
	, 0 aux2
	, CAST(0 AS NVARCHAR(8)) fuelTypeCode
	, 0 preOp
	, 0 postOp
FROM tblICItem item
	OUTER APPLY (
		SELECT TOP 1
			Item.intItemId intItemId,
			dblPrice = CAST(ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6)),
			ItemLocation.intLocationId intLocationId
		FROM vyuICGetItemStock Item
			LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = Item.intVendorId
			LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
			LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
				AND ItemLocation.intItemId = Item.intItemId
		WHERE item.intItemId = Item.intItemId
			AND (ItemLocation.intLocationId = @intDefaultLocationId OR @intDefaultLocationId IS NULL)
			AND ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) > 0
		ORDER BY ysnStockUnit DESC, ItemLocation.intLocationId DESC
	) prices
WHERE item.ysnAvailableTM = 1
	OR item.strType = 'Service'
GROUP BY item.strItemNo, item.strShortName, prices.intLocationId
ORDER BY prices.intLocationId DESC