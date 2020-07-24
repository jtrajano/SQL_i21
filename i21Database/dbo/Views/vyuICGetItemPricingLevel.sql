CREATE VIEW [dbo].[vyuICGetItemPricingLevel]
AS
SELECT	intItemPricingLevelId	= PricingLevel.intItemPricingLevelId
		,col.intCompanyLocationPricingLevelId
		,intItemId				= PricingLevel.intItemId
		,strItemNo				= Item.strItemNo
		,strDescription			= Item.strDescription
		,strType				= Item.strType
		,strStatus				= Item.strStatus
		,intCommodityId			= Item.intCommodityId
		,strCommodity			= Commodity.strCommodityCode
		,intCategoryId			= Item.intCategoryId
		,strCategory			= Category.strCategoryCode
		,strLotTracking			= Item.strLotTracking			
		,intLocationId			= ItemLocation.intLocationId
		,strLocationName		= CompanyLocation.strLocationName
		,strPriceLevel			= col.strPricingLevelName
		,intItemUnitMeasureId	= PricingLevel.intItemUnitMeasureId
		,strUnitMeasure			= um.strUnitMeasure
		,strUPC					= ItemUOM.strUpcCode
		,dblMin					= PricingLevel.dblMin
		,dblMax					= PricingLevel.dblMax
		,strPricingMethod		= PricingLevel.strPricingMethod
		,dblUnit				= PricingLevel.dblUnit
		,dtmEffectiveDate		= PricingLevel.dtmEffectiveDate
		,dblAmountRate			= PricingLevel.dblAmountRate
		,dblUnitPrice			= PricingLevel.dblUnitPrice
		,strCommissionOn		= PricingLevel.strCommissionOn
		,dblCommissionRate		= PricingLevel.dblCommissionRate
		,intCurrencyId			= PricingLevel.intCurrencyId
		,strCurrency			= Currency.strCurrency
		,intSort				= PricingLevel.intSort
		,dtmDateChanged			= PricingLevel.dtmDateChanged
		,intConcurrencyId		= PricingLevel.intConcurrencyId
FROM tblICItemPricingLevel PricingLevel
INNER JOIN tblICItem Item
	ON Item.intItemId = PricingLevel.intItemId
INNER JOIN tblICItemLocation ItemLocation
	ON ItemLocation.intItemLocationId = PricingLevel.intItemLocationId
INNER JOIN tblSMCompanyLocation CompanyLocation
	ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
INNER JOIN tblSMCompanyLocationPricingLevel col 
	ON col.intCompanyLocationPricingLevelId = PricingLevel.intCompanyLocationPricingLevelId
		AND col.intCompanyLocationId = CompanyLocation.intCompanyLocationId
	--ON col.intCompanyLocationId =  CompanyLocation.intCompanyLocationId
	--AND LOWER(PricingLevel.strPriceLevel) = LOWER(col.strPricingLevelName)
LEFT JOIN tblSMCurrency Currency
	ON Currency.intCurrencyID = PricingLevel.intCurrencyId
LEFT JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure um
			ON ItemUOM.intUnitMeasureId = um.intUnitMeasureId
	) ON ItemUOM.intItemUOMId = PricingLevel.intItemUnitMeasureId
LEFT JOIN tblICCategory Category
	ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = Item.intCommodityId