CREATE VIEW [dbo].[vyuSTCheckoutItemMovement]
AS
SELECT
	im.intItemMovementId,
    im.intCheckoutId,
	st.intStoreId,
	itemPricing.intItemPricingId,
	itemPricing.dblSalePrice,
    im.intItemUPCId,
	uom.intItemUOMId,
	um.strUnitMeasure,
    --im.strInvalidUPCCode,
	CASE
		WHEN (uom.intItemUOMId IS NOT NULL)
			THEN uom.strLongUPCCode
		ELSE im.strInvalidUPCCode
	END strLongUPCCode,

    --im.strDescription,
	CASE
		WHEN (item.intItemId IS NOT NULL)
			THEN item.strDescription
		ELSE NULL
	END strItemDescription,
	CASE
		WHEN (item.intItemId IS NOT NULL)
			THEN item.strItemNo
		ELSE NULL
	END strItemNo,

    --im.intVendorId,
	CASE
		WHEN (itemLoc.intItemLocationId IS NOT NULL)
			THEN itemLoc.intVendorId
		ELSE NULL
	END intVendorId,
	CASE
		WHEN (emVendor.intEntityId IS NOT NULL)
			THEN emVendor.strEntityNo
		ELSE NULL
	END strVendorId,
	CASE
		WHEN (category.intCategoryId IS NOT NULL)
			THEN category.strCategoryCode
		ELSE NULL
	END strCategoryCode,
	CASE
		WHEN (family.intSubcategoryId IS NOT NULL)
			THEN family.strSubcategoryId
		ELSE NULL
	END strFamily,
	CASE
		WHEN (class.intSubcategoryId IS NOT NULL)
			THEN class.strSubcategoryId
		ELSE NULL
	END strClass,
	CASE
		WHEN (uom.intItemUOMId IS NOT NULL)
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
	END ysnValid,

    im.intQtySold,
    im.dblCurrentPrice,
    im.dblDiscountAmount,
    im.dblGrossSales,
    im.dblTotalSales,
    im.dblItemStandardCost,
    --im.ysnLotteryItem,
	CASE
		WHEN (im.ysnLotteryItem IS NOT NULL)
			THEN im.ysnLotteryItem
		ELSE CAST(0 AS BIT)
	END ysnLotteryItem,
	im.intConcurrencyId
FROM tblSTCheckoutItemMovements im
INNER JOIN tblSTCheckoutHeader ch
	ON im.intCheckoutId = ch.intCheckoutId
INNER JOIN tblSTStore st
	ON ch.intStoreId = st.intStoreId
LEFT JOIN tblICItemUOM uom
	ON im.intItemUPCId = uom.intItemUOMId
LEFT JOIN tblICUnitMeasure um
	ON um.intUnitMeasureId = uom.intUnitMeasureId
LEFT JOIN tblICItem item
	ON uom.intItemId = item.intItemId
LEFT JOIN tblICCategory category
	ON item.intCategoryId = category.intCategoryId
LEFT JOIN dbo.tblICItemLocation itemLoc 
	ON itemLoc.intItemId = item.intItemId
	AND st.intCompanyLocationId = itemLoc.intLocationId
LEFT JOIN dbo.tblICItemPricing itemPricing 
	ON itemLoc.intItemLocationId = itemPricing.intItemLocationId 
	AND item.intItemId = itemPricing.intItemId
LEFT JOIN tblEMEntity emVendor
	ON itemLoc.intVendorId = emVendor.intEntityId
LEFT JOIN tblSTSubcategory family
	ON itemLoc.intFamilyId = family.intSubcategoryId
LEFT JOIN tblSTSubcategory class
	ON itemLoc.intClassId = class.intSubcategoryId
