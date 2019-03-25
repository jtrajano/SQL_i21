CREATE VIEW [dbo].[vyuICGetItemSpecialPricing]
AS
SELECT	intItemSpecialPricingId		= SpecialPricing.intItemSpecialPricingId
		,intItemId					= SpecialPricing.intItemId
		,strItemNo					= Item.strItemNo
		,strDescription				= Item.strDescription
		,strType					= Item.strType
		,strStatus					= Item.strStatus
		,intCommodityId				= Item.intCommodityId
		,strCommodity				= Commodity.strCommodityCode
		,intCategoryId				= Item.intCategoryId
		,strCategory				= Category.strCategoryCode
		,strLotTracking				= Item.strLotTracking			
		,intLocationId				= ItemLocation.intLocationId
		,strLocationName			= CompanyLocation.strLocationName
		,intItemUnitMeasureId		= SpecialPricing.intItemUnitMeasureId
		,strUnitMeasure				= um.strUnitMeasure
		,strUPC						= ItemUOM.strUpcCode
		,strPromotionType			= SpecialPricing.strPromotionType
		,dblUnit					= SpecialPricing.dblUnit
		,strDiscountBy				= SpecialPricing.strDiscountBy
		,dblDiscount				= SpecialPricing.dblDiscount
		,dblUnitAfterDiscount		= SpecialPricing.dblUnitAfterDiscount
		,intCurrencyId				= SpecialPricing.intCurrencyId
		,strCurrency				= Currency.strCurrency
		,dblDiscountedPrice			= CASE	
											WHEN SpecialPricing.strDiscountBy = 'Percent'
											THEN SpecialPricing.dblUnitAfterDiscount - (SpecialPricing.dblUnitAfterDiscount * SpecialPricing.dblDiscount / 100)
											ELSE
												CASE	WHEN SpecialPricing.strDiscountBy = 'Amount'
														THEN SpecialPricing.dblUnitAfterDiscount - SpecialPricing.dblDiscount
														ELSE 0
												END
									END
		,dtmBeginDate				= SpecialPricing.dtmBeginDate
		,dtmEndDate					= SpecialPricing.dtmEndDate
		,dblDiscountThruQty			= SpecialPricing.dblDiscountThruQty
		,dblDiscountThruAmount		= SpecialPricing.dblDiscountThruAmount
		,dblAccumulatedQty			= SpecialPricing.dblAccumulatedQty
		,dblAccumulatedAmount		= SpecialPricing.dblAccumulatedAmount
		,intConcurrencyId			= SpecialPricing.intConcurrencyId
FROM tblICItemSpecialPricing SpecialPricing
INNER JOIN tblICItem Item
	ON Item.intItemId = SpecialPricing.intItemId
LEFT JOIN tblICItemLocation ItemLocation
	ON ItemLocation.intItemLocationId = SpecialPricing.intItemLocationId
LEFT JOIN tblSMCompanyLocation CompanyLocation
	ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure um
			ON ItemUOM.intUnitMeasureId = um.intUnitMeasureId
	) ON ItemUOM.intItemUOMId = SpecialPricing.intItemUnitMeasureId
LEFT JOIN tblSMCurrency Currency
	ON Currency.intCurrencyID = SpecialPricing.intCurrencyId
LEFT JOIN tblICCategory Category
	ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = Item.intCommodityId
