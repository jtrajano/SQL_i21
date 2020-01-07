CREATE PROCEDURE uspICImportItemLocationsFromStaging @strIdentifier NVARCHAR(100)
AS

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo, strLocation) AS RowNumber
   FROM tblICImportStagingItemLocation
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;


INSERT INTO tblICItemLocation(
	  intItemId
	, intLocationId
	, intVendorId
	, intSubLocationId
	, intStorageLocationId
	, strDescription
	, intFamilyId
	, intClassId
	, intProductCodeId
	, strPassportFuelId1
	, strPassportFuelId2
	, strPassportFuelId3
	, ysnTaxFlag1
	, ysnTaxFlag2
	, ysnTaxFlag3
	, ysnTaxFlag4
	, ysnPromotionalItem
	, ysnStorageUnitRequired
	, ysnDepositRequired
	, intBottleDepositNo
	, ysnSaleable
	, ysnQuantityRequired
	, ysnScaleItem
	, ysnFoodStampable
	, ysnReturnable
	, ysnPrePriced
	, ysnOpenPricePLU
	, ysnLinkedItem
	, strVendorCategory
	, ysnIdRequiredLiquor
	, ysnIdRequiredCigarette
	, intMinimumAge
	, ysnApplyBlueLaw1
	, ysnApplyBlueLaw2
	, ysnCarWash
	, intItemTypeSubCode
	, dblReorderPoint
	, dblMinOrder
	, dblSuggestedQty
	, dblLeadTime
	, strCounted
	, ysnCountedDaily
	, ysnCountBySINo
	, strSerialNoBegin
	, strSerialNoEnd
	, ysnAutoCalculateFreight
	, dblFreightRate
	, intCostingMethod
    , intAllowNegativeInventory
	, intReceiveUOMId
	, intIssueUOMId
	, intGrossUOMId
	, dtmDateCreated
	, intCreatedByUserId
)
SElECT 
	  intItemId					= i.intItemId
	, intLocationId				= c.intCompanyLocationId
	, intVendorId				= v.intEntityId
	, intSubLocationId			= sl.intCompanyLocationSubLocationId
	, intStorageLocationId		= su.intStorageLocationId
	, strDescription			= s.strPOSDescription
	, intFamilyId				= family.intSubcategoryId
	, intClassId				= class.intSubcategoryId
	, intProductCodeId			= pc.intRegProdId
	, strPassportFuelId1		= s.strPassportFuelID1
	, strPassportFuelId2		= s.strPassportFuelID2
	, strPassportFuelId3		= s.strPassportFuelID3
	, ysnTaxFlag1				= s.ysnTaxFlag1
	, ysnTaxFlag2				= s.ysnTaxFlag2
	, ysnTaxFlag3				= s.ysnTaxFlag3
	, ysnTaxFlag4				= s.ysnTaxFlag4
	, ysnPromotionalItem		= s.ysnPromotionalItem
	, ysnStorageUnitRequired	= s.ysnStorageUnitRequired
	, ysnDepositRequired        = s.ysnDepositRequired
	, intBottleDepositNo        = s.intBottleDepositNo
	, ysnSaleable               = s.ysnSaleable
	, ysnQuantityRequired       = s.ysnQuantityRequired
	, ysnScaleItem              = s.ysnScaleItem
	, ysnFoodStampable          = s.ysnFoodStampable
	, ysnReturnable             = s.ysnReturnable
	, ysnPrePriced              = s.ysnPrePriced
	, ysnOpenPricePLU           = s.ysnOpenPricedPLU
	, ysnLinkedItem             = s.ysnLinkedItem
	, strVendorCategory         = s.strVendorCategory
	, ysnIdRequiredLiquor       = s.ysnIDRequiredLiquor
	, ysnIdRequiredCigarette    = s.ysnIDRequiredCigarrettes
	, intMinimumAge             = s.intMinimumAge
	, ysnApplyBlueLaw1          = s.ysnApplyBlueLaw1
	, ysnApplyBlueLaw2          = s.ysnApplyBlueLaw2
	, ysnCarWash                = s.ysnCarWash
	, intItemTypeSubCode        = s.intItemTypeSubcode
	, dblReorderPoint           = s.dblReorderPoint
	, dblMinOrder               = s.dblMinOrder
	, dblSuggestedQty           = s.dblSuggestedQty
	, dblLeadTime               = s.dblLeadTime
	, strCounted                = s.strCounted
	, ysnCountedDaily           = s.ysnCountedDaily
	, ysnCountBySINo            = s.ysnCountbySerialNumber
	, strSerialNoBegin          = s.strSerialNumberBegin
	, strSerialNoEnd            = s.strSerialNumberEnd
	, ysnAutoCalculateFreight   = s.ysnAutoCalculateFreight
	, dblFreightRate            = s.dblFreightRate
    , intCostingMethod          = ISNULL(cm.intCostingMethod, 1)
    , intAllowNegativeInventory = CASE WHEN s.ysnAllowNegativeInventory = 1 THEN 1 ELSE 3 END
	, intReceiveUOMId			= rs.intItemUOMId
	, intIssueUOMId				= rs.intItemUOMId
	, intGrossUOMId				= gs.intItemUOMId
	, dtmDateCreated			= s.dtmDateCreated
	, intCreatedByUserId		= s.intCreatedByUserId
FROM tblICImportStagingItemLocation s
	INNER JOIN tblICItem i ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo))) 
	INNER JOIN tblSMCompanyLocation c ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))
	LEFT OUTER JOIN vyuAPVendor v ON LOWER(v.strName) = LTRIM(RTRIM(LOWER(s.strVendorId)))
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sl ON LOWER(sl.strSubLocationName) = LTRIM(RTRIM(LOWER(s.strStorageLocation)))
	LEFT OUTER JOIN tblICStorageLocation su ON LOWER(su.strName) = LTRIM(RTRIM(LOWER(s.strStorageUnit)))
	LEFT OUTER JOIN tblSTSubcategory family ON LOWER(family.strSubcategoryId) = LTRIM(RTRIM(LOWER(s.strFamily))) AND family.strSubcategoryType = 'F'
	LEFT OUTER JOIN tblSTSubcategory class ON LOWER(class.strSubcategoryId) = LTRIM(RTRIM(LOWER(s.strClass))) AND class.strSubcategoryType = 'C'
	LEFT OUTER JOIN tblSTSubcategoryRegProd pc ON LOWER(pc.strRegProdCode) = LTRIM(RTRIM(LOWER(s.strProductCode))) AND pc.intStoreId <> 0
    OUTER APPLY (
		SELECT intCostingMethod
		FROM (
			SELECT 'AVG' strCostingMethod, 1 intCostingMethod UNION
			SELECT 'FIFO' strCostingMethod, 2 intCostingMethod UNION
			SELECT 'LIFO' strCostingMethod, 3 intCostingMethod
		) x WHERE LOWER(x.strCostingMethod) = LTRIM(RTRIM(LOWER(s.strCostingMethod)))
	) cm
	LEFT OUTER JOIN tblICUnitMeasure ru ON LOWER(ru.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strPurchaseUOM)))
	LEFT OUTER JOIN tblICItemUOM ri ON ri.intUnitMeasureId = ru.intUnitMeasureId
	LEFT OUTER JOIN tblICUnitMeasure iu ON LOWER(iu.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strSaleUOM)))
	LEFT OUTER JOIN tblICItemUOM rs ON rs.intUnitMeasureId = iu.intUnitMeasureId
	LEFT OUTER JOIN tblICUnitMeasure g ON LOWER(g.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strGrossNetUOM)))
	LEFT OUTER JOIN tblICItemUOM gs ON gs.intUnitMeasureId = g.intUnitMeasureId
WHERE s.strImportIdentifier = @strIdentifier
	AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICItemLocation
		WHERE intItemId = i.intItemId
			AND intLocationId = c.intCompanyLocationId
	)


UPDATE l
SET l.intRowsImported = @@ROWCOUNT
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DELETE FROM [tblICImportStagingItemLocation] WHERE strImportIdentifier = @strIdentifier

UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1