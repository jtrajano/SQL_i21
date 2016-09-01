CREATE VIEW [dbo].[vyuICExportProduct]
AS
SELECT
	CAST(item.strItemNo AS NVARCHAR(16)) code
	, CAST(item.strShortName AS NVARCHAR(35)) name
	, CAST(prices.dblPrice AS NVARCHAR(16)) priceID
	, CAST('' AS NVARCHAR(8)) taxCode
	, 0 aux1
	, 0 aux2
	, CAST(0 AS NVARCHAR(8)) fuelTypeCode
	, 0 preOp
	, 0 postOp
FROM tblICItem item
	LEFT OUTER JOIN (
		SELECT
			Item.intItemId,
			dblPrice = CAST(ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6))
		FROM vyuICGetItemStock Item
		LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = Item.intVendorId
		LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
		LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId
	) prices ON prices.intItemId = item.intItemId
WHERE item.ysnAvailableTM = 1
	OR item.strType = 'Service'
GROUP BY prices.dblPrice, item.strItemNo, item.strShortName