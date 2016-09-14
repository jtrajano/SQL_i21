CREATE PROCEDURE [dbo].[uspTMBEExportPrice]
	@intEntityUserSecurityId INT
AS
DECLARE @intDefaultLocationId INT

SELECT @intDefaultLocationId = intCompanyLocationId
FROM tblSMUserSecurity
WHERE intEntityUserSecurityId = @intEntityUserSecurityId

SELECT DISTINCT
	* 
FROM (
SELECT
	ID = item.intItemId
	,name = item.strShortName
	,perUnit = CAST(ROUND(prices.dblPrice,4) AS NUMERIC (16,4))
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
UNION ALL
SELECT DISTINCT
	ID = (CASE WHEN C.intItemId IS NULL THEN B.intItemId ELSE C.intItemId END)
	,name = (CASE WHEN C.intItemId IS NULL THEN ISNULL(B.strShortName,'') ELSE ISNULL(C.strShortName,'') END)
	,perUnit = CAST(ROUND(dblPrice,4) AS NUMERIC (16,4))
FROM tblTMDispatch A
INNER JOIN tblICItem B
	ON A.intProductID = B.intItemId
LEFT JOIN tblICItem C
	ON A.intSubstituteProductID = C.intItemId
) Z

GO