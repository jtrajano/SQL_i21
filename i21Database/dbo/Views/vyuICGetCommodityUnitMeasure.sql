CREATE VIEW [dbo].[vyuICGetCommodityUnitMeasure]
AS
SELECT
	CommodityUnitMeasure.intCommodityUnitMeasureId,
	CommodityUnitMeasure.intCommodityId,
	Commodity.strCommodityCode,
	Commodity.strDescription,
	CommodityUnitMeasure.intUnitMeasureId,
	UnitMeasure.strUnitMeasure,
	CommodityUnitMeasure.dblUnitQty,
	CommodityUnitMeasure.ysnStockUnit,
	CommodityUnitMeasure.ysnDefault,
	CommodityUnitMeasure.ysnStockUOM,
	CommodityUnitMeasure.dblPremiumDiscount,
	CommodityUnitMeasure.intCurrencyId,
	Currency.strCurrency,
	CommodityUnitMeasure.intPriceUnitMeasureId,
	PriceUnitMeasure.strUnitMeasure AS strPriceUnitMeasure,
	CommodityUnitMeasure.intSort
FROM
	tblICCommodityUnitMeasure CommodityUnitMeasure
INNER JOIN
	tblICCommodity Commodity
	ON
		CommodityUnitMeasure.intCommodityId = Commodity.intCommodityId
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		CommodityUnitMeasure.intUnitMeasureId = UnitMeasure.intUnitMeasureId
LEFT JOIN
	tblICUnitMeasure PriceUnitMeasure
	ON
		CommodityUnitMeasure.intPriceUnitMeasureId = PriceUnitMeasure.intUnitMeasureId
LEFT JOIN
	tblSMCurrency Currency
	ON
		CommodityUnitMeasure.intCurrencyId = Currency.intCurrencyID

