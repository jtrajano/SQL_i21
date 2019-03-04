CREATE PROCEDURE [dbo].[uspICExportItemsToStaging]
	@dtmDate DATETIME,
	@ysnIncludeDetails BIT = 1
AS

DECLARE @Items TABLE(
	intItemId INT, 
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS,
	strType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBundleType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strInventoryTracking NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strLotTracking NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strCostType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strCostMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strModelNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnUseWeighScales BIT NULL,
	ysnLotWeightsRequired BIT NULL,
	strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBrandCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strManufacturer NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmDateCreated DATETIME NULL,
	dtmDateModified DATETIME NULL,
	dtmDate DATETIME
)

INSERT INTO @Items
SELECT
	  item.intItemId
	, item.strItemNo
	, item.strDescription
	, item.strType
	, item.strBundleType
	, item.strStatus
	, item.strInventoryTracking
	, item.strLotTracking
	, item.strCostType
	, item.strCostMethod
	, item.strModelNo
	, item.ysnUseWeighScales
	, item.ysnLotWeightsRequired
	, commodity.strCommodityCode
	, category.strCategoryCode
	, brand.strBrandCode
	, manufacturer.strManufacturer
	, item.dtmDateCreated
	, item.dtmDateModified
	, dtmDate = ISNULL(item.dtmDateModified, item.dtmDateCreated) -- Use this for filtering the date modified/created
FROM tblICItem item
	LEFT OUTER JOIN tblICCommodity commodity ON commodity.intCommodityId = item.intCommodityId
	LEFT OUTER JOIN tblICCategory category ON category.intCategoryId = item.intCategoryId
	LEFT OUTER JOIN tblICBrand brand ON brand.intBrandId = item.intBrandId
	LEFT OUTER JOIN tblICManufacturer manufacturer ON manufacturer.intManufacturerId = item.intManufacturerId
WHERE dbo.fnDateGreaterThanEquals(ISNULL(item.dtmDateModified, item.dtmDateCreated), @dtmDate) = 1 OR @dtmDate IS NULL

/* Header */
INSERT INTO tblICStagingItem(intItemId, strItemNo, strDescription, strType, strBundleType, strStatus
	, strInventoryTracking, strLotTracking, strCostType, strCostMethod, strModelNo, ysnUseWeighScales
	, ysnLotWeightsRequired, strCommodityCode, strCategoryCode, strBrandCode, strManufacturer)
SELECT intItemId, strItemNo, strDescription, strType, strBundleType, strStatus
	, strInventoryTracking, strLotTracking, strCostType, strCostMethod, strModelNo, ysnUseWeighScales
	, ysnLotWeightsRequired, strCommodityCode, strCategoryCode, strBrandCode, strManufacturer
FROM @Items	

/* Details */
IF @ysnIncludeDetails = 1
BEGIN

	/* Units of Measurement */
	INSERT INTO tblICStagingItemUom(intItemId, intItemUomId, intUnitMeasureId, strUnit, dblUnitQty
		, strShortUpc, strUpc, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, dblMaxQty)
	SELECT i.intItemId, m.intItemUOMId, u.intUnitMeasureId, u.strUnitMeasure, m.dblUnitQty
		, m.strUpcCode, m.strLongUPCCode, m.ysnStockUnit, m.ysnAllowPurchase, m.ysnAllowSale, m.dblMaxQty
	FROM @Items i
		LEFT OUTER JOIN tblICItemUOM m ON m.intItemId = i.intItemId
		LEFT OUTER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = m.intUnitMeasureId

	/* Item Locations */
	INSERT INTO tblICStagingItemLocation(intItemId, intItemLocationId, intLocationId, strLocationName
		, strCostingMethod, ysnAllowNegativeInventory, ysnRequireStorageUnit, strDefaultVendorNo
		, strDefaultStorageLocation, strDefaultStorageUnit, strDefaultSaleUom, strDefaultPurchaseUom
		, strDefaultGrossUom, strInventoryCountGroup)
	SELECT i.intItemId, il.intItemLocationId, il.intLocationId, c.strLocationName
		, CASE il.intCostingMethod WHEN 1 THEN 'AVG' WHEN 2 THEN 'FIFO' WHEN 3 THEN 'LIFO' ELSE 'CATEGORY' END AS strCostingMethod
		, il.intAllowNegativeInventory, il.ysnStorageUnitRequired, e.strName AS strDefaultVendorNo
		, sl.strSubLocationName AS strDefaultStorageLocation, su.strName AS strDefaultStorageUnit
		, us.strUnitMeasure AS strDefaultSaleUom, up.strUnitMeasure AS strDefaultPurchaseUom
		, ug.strUnitMeasure AS strDefaultGrossUom, cg.strCountGroup AS strInventoryCountGroup
	FROM @Items i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
		INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
		LEFT OUTER JOIN tblEMEntity e ON e.intEntityId = il.intVendorId
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = il.intSubLocationId
		LEFT OUTER JOIN tblICStorageLocation su ON su.intStorageLocationId = il.intStorageLocationId
		LEFT OUTER JOIN tblICItemUOM ds ON ds.intItemUOMId = il.intIssueUOMId
		LEFT OUTER JOIN tblICItemUOM ps ON ps.intItemUOMId = il.intReceiveUOMId
		LEFT OUTER JOIN tblICItemUOM gs ON gs.intItemUOMId = il.intGrossUOMId
		LEFT OUTER JOIN tblICUnitMeasure us ON us.intUnitMeasureId = ds.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure up ON up.intUnitMeasureId = ps.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure ug ON ug.intUnitMeasureId = gs.intUnitMeasureId
		LEFT OUTER JOIN tblICCountGroup cg ON cg.intCountGroupId = il.intCountGroupId

	/* Item Pricings */
	INSERT INTO tblICStagingItemPricing(intItemId, intItemPricingId, intItemLocationId, intLocationId
		, strLocationName, dblStandardCost, strPricingMethod, dblRetailPrice, dblAmountPercentage)
	SELECT il.intItemId, p.intItemPricingId, il.intItemLocationId, il.intLocationId, c.strLocationName
		, p.dblStandardCost, p.strPricingMethod, p.dblSalePrice, p.dblAmountPercent
	FROM @Items i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
		INNER JOIN tblICItemPricing p ON p.intItemId = i.intItemId
			AND p.intItemLocationId = il.intItemLocationId
		INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
END