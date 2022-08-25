CREATE PROCEDURE uspApiSchemaTransformItemLocation 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS


-- Retrieve Properties
DECLARE @OverwriteExisting BIT = 1

SELECT
    @OverwriteExisting = ISNULL(CAST(Overwrite AS BIT), 0)
FROM (
	SELECT tp.strPropertyName, tp.varPropertyValue
	FROM tblApiSchemaTransformProperty tp
	WHERE tp.guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		Overwrite
	)
) AS PivotTable

-- Remove duplicate item numbers from file
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo, sr.strLocation ORDER BY sr.strItemNo, sr.strLocation) AS RowNumber
   FROM tblApiSchemaTransformItemLocation sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND @OverwriteExisting = 0
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location'
    , strValue = sr.strLocation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The location ' + sr.strLocation + ' for the item "' + sr.strItemNo + '" in the file has duplicates.'
    , strAction = 'Skipped'
FROM cte sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND sr.RowNumber > 1
  AND @OverwriteExisting = 0

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo, sr.strLocation ORDER BY sr.strItemNo, sr.strLocation) AS RowNumber
   FROM tblApiSchemaTransformItemLocation sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND @OverwriteExisting = 0
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1
  AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Item No'
	, strValue = sr.strItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The item "' + sr.strItemNo + '" does not exist.'
	, strAction = 'Critical'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblICItem i ON sr.strItemNo = i.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Location'
	, strValue = sr.strLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The company location "' + sr.strLocation + '" does not exist.'
	, strAction = 'Critical'
FROM tblApiSchemaTransformItemLocation sr
LEFT OUTER JOIN tblSMCompanyLocation c ON c.strLocationNumber = sr.strLocation
	OR c.strLocationName = sr.strLocation
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND c.intCompanyLocationId IS NULL
	
-- Validate if inserting duplicate item location
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Location'
	, strValue = sr.strLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The company location "' + sr.strLocation + '" for the item "' + i.strItemNo + '" already exists.'
FROM tblApiSchemaTransformItemLocation sr
JOIN tblICItem i ON sr.strItemNo = i.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Gross UOM'
	, strValue = sr.strGrossUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Gross UOM "' + sr.strGrossUOM + '" for the item "' + sr.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN vyuICItemUOM u ON u.strItemNo = sr.strItemNo
	AND u.strUnitMeasure = sr.strGrossUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND u.intItemUOMId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strGrossUOM)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Purchase UOM'
	, strValue = sr.strReceiveUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Purchase UOM "' + sr.strReceiveUOM + '" for the item "' + sr.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN vyuICItemUOM u ON u.strItemNo = sr.strItemNo
	AND u.strUnitMeasure = sr.strReceiveUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND u.intItemUOMId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strReceiveUOM)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Sale UOM'
	, strValue = sr.strReceiveUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Sale UOM "' + sr.strIssueUOM + '" for the item "' + sr.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN vyuICItemUOM u ON u.strItemNo = sr.strItemNo
	AND u.strUnitMeasure = sr.strIssueUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND u.intItemUOMId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strIssueUOM)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Count Group'
	, strValue = sr.strCountGroup
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Count Group "' + sr.strCountGroup + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblICCountGroup c ON c.strCountGroup = sr.strCountGroup
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND c.intCountGroupId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strCountGroup)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Freight Term'
	, strValue = sr.strFreightTerm
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Freight Term "' + sr.strFreightTerm + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN vyuSMFreightTerms f ON f.strFreightTerm = sr.strFreightTerm
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND f.intFreightTermId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strFreightTerm)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Ship Via'
	, strValue = sr.strShipVia
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Ship Via "' + sr.strShipVia + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN vyuEMSearchShipVia f ON f.strShipVia = sr.strShipVia
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND f.intEntityId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strShipVia)), '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Costing Method'
	, strValue = sr.strCostingMethod
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Costing Method "' + sr.strCostingMethod + '" is invalid. Defaulted to "AVG".'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND UPPER(sr.strCostingMethod) NOT IN ('AVG', 'FIFO', 'LIFO', 'CATEGORY')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Allow Negative Inventory'
	, strValue = sr.strAllowNegativeInventory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Allow Negative Inventory "' + sr.strAllowNegativeInventory + '" is invalid. Defaulted to "Yes".'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND UPPER(sr.strAllowNegativeInventory) NOT IN ('YES', 'NO')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Allow Zero Cost'
	, strValue = sr.strAllowZeroCost
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Allow Zero Cost "' + sr.strAllowZeroCost + '" is invalid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND UPPER(sr.strAllowZeroCost) NOT IN ('NO', 'YES', 'YES, WITH WARNING MESSAGE', 'YES ON PRODUCE')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Product Code'
	, strValue = sr.strProductCode
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Product Code "' + sr.strProductCode + '" is invalid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblSTSubcategoryRegProd r ON r.strRegProdCode = sr.strProductCode
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND r.intRegProdId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strProductCode)), '') IS NOT NULL 

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Family'
	, strValue = sr.strFamily
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Family "' + sr.strFamily + '" is invalid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblSTSubcategory r ON r.strSubcategoryId = sr.strFamily
	AND r.strSubcategoryType = 'F'
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND r.intSubcategoryId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strFamily)), '') IS NOT NULL 

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Class'
	, strValue = sr.strClass
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Class "' + sr.strClass + '" is invalid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblSTSubcategory r ON r.strSubcategoryId = sr.strClass
	AND r.strSubcategoryType = 'C'
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND r.intSubcategoryId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strClass)), '') IS NOT NULL 

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Storage Location'
	, strValue = sr.strStorageLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Storage Location "' + sr.strStorageLocation + '" is not valid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblSMCompanyLocation c ON c.strLocationName = sr.strLocation OR c.strLocationNumber = sr.strLocation
LEFT JOIN tblSMCompanyLocationSubLocation r ON r.strSubLocationName = sr.strStorageLocation
	AND r.intCompanyLocationId = c.intCompanyLocationId
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND r.intCompanyLocationSubLocationId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strStorageLocation)), '') IS NOT NULL 

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Storage Unit'
	, strValue = sr.strStorageUnit
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = sr.intRowNumber
	, strMessage = 'The Storage Unit "' + sr.strStorageUnit + '" is not valid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblSMCompanyLocation c ON c.strLocationName = sr.strLocation OR c.strLocationNumber = sr.strLocation
LEFT JOIN tblSMCompanyLocationSubLocation r ON r.strSubLocationName = sr.strStorageLocation
	AND r.intCompanyLocationId = c.intCompanyLocationId
LEFT JOIN tblICStorageLocation u ON u.strName = sr.strStorageUnit
	AND u.intSubLocationId = r.intCompanyLocationSubLocationId
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND u.intStorageLocationId IS NULL
	AND NULLIF(LTRIM(RTRIM(sr.strStorageUnit)), '') IS NOT NULL 

INSERT INTO tblICItemLocation (
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
	, ysnActive
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
	, intItemTypeCode
	, intItemTypeSubCode
	, dblReorderPoint
	, dblMinOrder
	, dblSuggestedQty
	, dblLeadTime
	, strCounted
	, intCountGroupId
	, ysnCountedDaily
	, ysnCountBySINo
	, strSerialNoBegin
	, strSerialNoEnd
	, ysnAutoCalculateFreight
	, dblFreightRate
	, intFreightMethodId
	, intCostingMethod
	, intAllowNegativeInventory
	, intDepositPLUId
	, intShipViaId
	, intAllowZeroCostTypeId
	, strStorageUnitNo
	, intCostAdjustmentType
	, intReceiveUOMId
	, intIssueUOMId
	, intGrossUOMId
	, dtmDateCreated
	, intRowNumber
	, guiApiUniqueId)
SELECT
	  i.intItemId
	, c.intCompanyLocationId
	, v.intEntityId
	, sb.intCompanyLocationSubLocationId
	, st.intStorageLocationId
	, sr.strDescription
	, fam.intSubcategoryId
	, cls.intSubcategoryId
	, prd.intRegProdId
	, sr.strPassportFuelId1
	, sr.strPassportFuelId2
	, sr.strPassportFuelId3
	, sr.ysnTaxFlag1
	, sr.ysnTaxFlag2
	, sr.ysnTaxFlag3
	, sr.ysnTaxFlag4
	, sr.ysnPromotionalItem
	, sr.ysnStorageUnitRequired
	, sr.ysnDepositRequired
	, sr.ysnActive
	, sr.intBottleDepositNo
	, sr.ysnSaleable
	, sr.ysnQuantityRequired
	, sr.ysnScaleItem
	, sr.ysnFoodStampable
	, sr.ysnReturnable
	, sr.ysnPrePriced
	, sr.ysnOpenPricePLU
	, sr.ysnLinkedItem
	, sr.strVendorCategory
	, sr.ysnIdRequiredLiquor
	, sr.ysnIdRequiredCigarette
	, sr.intMinimumAge
	, sr.ysnApplyBlueLaw1
	, sr.ysnApplyBlueLaw2
	, sr.ysnCarWash
	, tc.intRadiantItemTypeCodeId
	, sr.intItemTypeSubCode
	, sr.dblReorderPoint
	, sr.dblMinOrder
	, sr.dblSuggestedQty
	, sr.dblLeadTime
	, sr.strCounted
	, cg.intCountGroupId
	, sr.ysnCountedDaily
	, sr.ysnCountBySINo
	, sr.strSerialNoBegin
	, sr.strSerialNoEnd
	, sr.ysnAutoCalculateFreight
	, sr.dblFreightRate
	, ft.intFreightTermId
	, ISNULL(cm.intCostingMethod, 1)
	, ISNULL(ni.intNegativeInventoryId, 1)
	, dp.intItemUOMId
	, sv.intEntityId
	, zc.intAllowZeroCostTypeId
	, sr.strStorageUnitNo
	, cat.intCostAdjustmentType
	, rv.intItemUOMId
	, iss.intItemUOMId
	, gr.intItemUOMId
	, GETUTCDATE()
	, sr.intRowNumber
	, @guiApiUniqueId
FROM tblApiSchemaTransformItemLocation sr
LEFT JOIN tblICItem i ON i.strItemNo = sr.strItemNo
LEFT JOIN tblSMCompanyLocation c ON c.strLocationNumber = sr.strLocation
	OR c.strLocationName = sr.strLocation
LEFT JOIN tblAPVendor v ON v.strVendorId = sr.strVendor
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strReceiveUOM
) rv
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strIssueUOM
) iss
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strGrossUOM
) gr
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationSubLocationId
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationId = c.intCompanyLocationId
		AND strSubLocationName = sr.strStorageLocation
) sb
OUTER APPLY (
	SELECT TOP 1 intStorageLocationId
	FROM tblICStorageLocation
	WHERE intSubLocationId = sb.intCompanyLocationSubLocationId
		AND strName = sr.strStorageUnit
) st
OUTER APPLY (
	SELECT intCostAdjustmentType
	FROM (
		SELECT 'Detailed' strDescription, 1 intCostAdjustmentType UNION
		SELECT 'Summarized' strDescription, 2 intCostAdjustmentType
	) CostAdjustmentType WHERE LOWER(CostAdjustmentType.strDescription) = LOWER(sr.strCostAdjustmentType)
) cat
OUTER APPLY (
	SELECT TOP 1 intSubcategoryId
	FROM tblSTSubcategory
	WHERE strSubcategoryId = sr.strFamily
	AND strSubcategoryType = 'F'
) fam
OUTER APPLY (
	SELECT TOP 1 intSubcategoryId
	FROM tblSTSubcategory
	WHERE strSubcategoryId = sr.strClass
	AND strSubcategoryType = 'C'
) cls
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICSearchItemUPC
	WHERE strLongUPCCode = sr.strDepositPLU
		AND strLocationName = sr.strLocation
) dp
OUTER APPLY (
	SELECT TOP 1 intRegProdId
	FROM tblSTSubcategoryRegProd
	WHERE strRegProdCode = sr.strProductCode
) prd
OUTER APPLY (
	SELECT intAllowZeroCostTypeId
	FROM (
		SELECT 'No' strDescription, 1 intAllowZeroCostTypeId UNION
		SELECT 'Yes' strDescription, 2 intAllowZeroCostTypeId UNION
		SELECT 'Yes, with warning message' strDescription, 3 intAllowZeroCostTypeId UNION
		SELECT 'Yes on Produce' strDescription, 4 intAllowZeroCostTypeId
	) ZeroCost WHERE LOWER(ZeroCost.strDescription) = LOWER(sr.strAllowZeroCost)
) zc
OUTER APPLY (
	SELECT TOP 1 intRadiantItemTypeCodeId
	FROM tblSTRadiantItemTypeCode
	WHERE strItemTypeCode = sr.strItemTypeCode
) tc
OUTER APPLY (
	SELECT TOP 1 intCountGroupId
	FROM tblICCountGroup
	WHERE strCountGroup = sr.strCountGroup
) cg
OUTER APPLY (
	SELECT TOP 1 intFreightTermId
	FROM vyuSMFreightTerms
	WHERE strFreightTerm = sr.strFreightTerm
) ft
OUTER APPLY (
	SELECT TOP 1 intEntityId
	FROM vyuEMSearchShipVia
	WHERE strShipVia = sr.strShipVia
) sv
OUTER APPLY (
	SELECT intCostingMethod
	FROM (
		SELECT 'AVG' strCostingMethod, 1 intCostingMethod UNION
		SELECT 'FIFO' strCostingMethod, 2 intCostingMethod UNION
		SELECT 'LIFO' strCostingMethod, 3 intCostingMethod UNION
		SELECT 'CATEGORY' strCostingMethod, 6 intCostingMethod
	) CostingMethod WHERE LOWER(CostingMethod.strCostingMethod) = LOWER(sr.strCostingMethod)
) cm
OUTER APPLY (
	SELECT intNegativeInventoryId
	FROM (
		SELECT 'Yes' strDescription, 1 intNegativeInventoryId UNION
		SELECT 'No' strDescription, 3 intNegativeInventoryId
	) NegativeInventory WHERE LOWER(NegativeInventory.strDescription) = LOWER(sr.strAllowNegativeInventory)
) ni
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NOT EXISTS (
    SELECT TOP 1 1
    FROM tblApiImportLogDetail d
    WHERE d.guiApiImportLogId = @guiLogId
      AND d.intRowNo = sr.intRowNumber
      AND d.strLogLevel = 'Error'
  )
  AND NOT EXISTS(
    SELECT TOP 1 1 
    FROM tblICItem xi
	JOIN tblICItemLocation xl ON xl.intItemId = xi.intItemId
	JOIN tblSMCompanyLocation xc ON xc.intCompanyLocationId = xl.intLocationId
    WHERE xi.strItemNo = sr.strItemNo
		AND (xc.strLocationNumber = sr.strLocation OR xc.strLocationName = sr.strLocation)
  )

-- Flag items for modifications
DECLARE @ForUpdates TABLE (intItemId INT, intLocationId INT, intRowNumber INT NULL)
INSERT INTO @ForUpdates
SELECT i.intItemId, c.intCompanyLocationId, sr.intRowNumber
FROM tblApiSchemaTransformItemLocation sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
JOIN tblSMCompanyLocation c ON c.strLocationNumber = sr.strLocation
	OR c.strLocationName = sr.strLocation
JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	AND il.intLocationId = c.intCompanyLocationId
WHERE sr.guiApiUniqueId = @guiApiUniqueId

UPDATE il
SET
	  il.intVendorId = COALESCE(v.intEntityId, il.intVendorId)
	, il.intSubLocationId = COALESCE(sb.intCompanyLocationSubLocationId, il.intSubLocationId)
	, il.intStorageLocationId = COALESCE(st.intStorageLocationId, il.intStorageLocationId)
	, il.strDescription = COALESCE(sr.strDescription, il.strDescription)
	, il.intFamilyId = COALESCE(fam.intSubcategoryId, il.intFamilyId)
	, il.intClassId = COALESCE(cls.intSubcategoryId, il.intClassId)
	, il.intProductCodeId = COALESCE(prd.intRegProdId, il.intProductCodeId)
	, il.strPassportFuelId1 = COALESCE(sr.strPassportFuelId1, il.strPassportFuelId1)
	, il.strPassportFuelId2 = COALESCE(sr.strPassportFuelId2, il.strPassportFuelId2)
	, il.strPassportFuelId3 = COALESCE(sr.strPassportFuelId3, il.strPassportFuelId3)
	, il.ysnTaxFlag1 = COALESCE(sr.ysnTaxFlag1, il.ysnTaxFlag1)
	, il.ysnTaxFlag2 = COALESCE(sr.ysnTaxFlag2, il.ysnTaxFlag2)
	, il.ysnTaxFlag3 = COALESCE(sr.ysnTaxFlag3, il.ysnTaxFlag3)
	, il.ysnTaxFlag4 = COALESCE(sr.ysnTaxFlag4, il.ysnTaxFlag4)
	, il.ysnPromotionalItem = COALESCE(sr.ysnPromotionalItem, il.ysnPromotionalItem)
	, il.ysnStorageUnitRequired = COALESCE(sr.ysnStorageUnitRequired, il.ysnStorageUnitRequired)
	, il.ysnDepositRequired = COALESCE(sr.ysnDepositRequired, il.ysnDepositRequired)
	, il.ysnActive = COALESCE(sr.ysnActive, il.ysnActive)
	, il.intBottleDepositNo = COALESCE(sr.intBottleDepositNo, il.intBottleDepositNo)
	, il.ysnSaleable = COALESCE(sr.ysnSaleable, il.ysnSaleable)
	, il.ysnQuantityRequired = COALESCE(sr.ysnQuantityRequired, il.ysnQuantityRequired)
	, il.ysnScaleItem = COALESCE(sr.ysnScaleItem, il.ysnScaleItem)
	, il.ysnFoodStampable = COALESCE(sr.ysnFoodStampable, il.ysnFoodStampable)
	, il.ysnReturnable = COALESCE(sr.ysnReturnable, il.ysnReturnable)
	, il.ysnPrePriced = COALESCE(sr.ysnPrePriced, il.ysnPrePriced)
	, il.ysnOpenPricePLU = COALESCE(sr.ysnOpenPricePLU, il.ysnOpenPricePLU)
	, il.ysnLinkedItem = COALESCE(sr.ysnLinkedItem, il.ysnLinkedItem)
	, il.strVendorCategory = COALESCE(sr.strVendorCategory, il.strVendorCategory)
	, il.ysnIdRequiredLiquor = COALESCE(sr.ysnIdRequiredLiquor, il.ysnIdRequiredLiquor)
	, il.ysnIdRequiredCigarette = COALESCE(sr.ysnIdRequiredCigarette, il.ysnIdRequiredCigarette)
	, il.intMinimumAge = COALESCE(sr.intMinimumAge, il.intMinimumAge)
	, il.ysnApplyBlueLaw1 = COALESCE(sr.ysnApplyBlueLaw1, il.ysnApplyBlueLaw1)
	, il.ysnApplyBlueLaw2 = COALESCE(sr.ysnApplyBlueLaw2, il.ysnApplyBlueLaw2)
	, il.ysnCarWash = COALESCE(sr.ysnCarWash, il.ysnCarWash)
	, il.intItemTypeCode = COALESCE(tc.intRadiantItemTypeCodeId, il.intItemTypeCode)
	, il.intItemTypeSubCode = COALESCE(sr.intItemTypeSubCode, il.intItemTypeSubCode)
	, il.dblReorderPoint = COALESCE(sr.dblReorderPoint, il.dblReorderPoint)
	, il.dblMinOrder = COALESCE(sr.dblMinOrder, il.dblMinOrder)
	, il.dblSuggestedQty = COALESCE(sr.dblSuggestedQty, il.dblSuggestedQty)
	, il.dblLeadTime = COALESCE(sr.dblLeadTime, il.dblLeadTime)
	, il.strCounted = COALESCE(sr.strCounted, il.strCounted)
	, il.intCountGroupId = COALESCE(cg.intCountGroupId, il.intCountGroupId)
	, il.ysnCountedDaily = COALESCE(sr.ysnCountedDaily, il.ysnCountedDaily)
	, il.ysnCountBySINo = COALESCE(sr.ysnCountBySINo, il.ysnCountBySINo)
	, il.strSerialNoBegin = COALESCE(sr.strSerialNoBegin, il.strSerialNoBegin)
	, il.strSerialNoEnd = COALESCE(sr.strSerialNoEnd, il.strSerialNoEnd)
	, il.ysnAutoCalculateFreight = COALESCE(sr.ysnAutoCalculateFreight, il.ysnAutoCalculateFreight)
	, il.dblFreightRate = COALESCE(sr.dblFreightRate, il.dblFreightRate)
	, il.intFreightMethodId = COALESCE(ft.intFreightTermId, il.intFreightMethodId)
	, il.intCostingMethod = ISNULL(cm.intCostingMethod, 1)
	, il.intAllowNegativeInventory = ISNULL(ni.intNegativeInventoryId, 1)
	, il.intDepositPLUId = COALESCE(dp.intItemUOMId, il.intDepositPLUId)
	, il.intShipViaId = COALESCE(sv.intEntityId, il.intShipViaId)
	, il.intAllowZeroCostTypeId = COALESCE(zc.intAllowZeroCostTypeId, il.intAllowZeroCostTypeId)
	, il.strStorageUnitNo = COALESCE(sr.strStorageUnitNo, il.strStorageUnitNo)
	, il.intCostAdjustmentType = COALESCE(cat.intCostAdjustmentType, il.intCostAdjustmentType)
	, il.intReceiveUOMId = COALESCE(rv.intItemUOMId, il.intReceiveUOMId)
	, il.intIssueUOMId = COALESCE(iss.intItemUOMId, il.intIssueUOMId)
	, il.intGrossUOMId = COALESCE(gr.intItemUOMId, il.intGrossUOMId)
	, il.dtmDateCreated = GETUTCDATE()
	, il.intRowNumber = sr.intRowNumber
	, il.guiApiUniqueId = @guiApiUniqueId
FROM tblICItemLocation il
JOIN @ForUpdates fu ON fu.intItemId = il.intItemId
	AND fu.intLocationId = il.intLocationId
JOIN tblICItem i ON i.intItemId = il.intItemId
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
JOIN tblApiSchemaTransformItemLocation sr ON sr.strItemNo = i.strItemNo
	AND sr.strLocation = c.strLocationNumber OR c.strLocationName = sr.strLocation
LEFT JOIN tblAPVendor v ON v.strVendorId = sr.strVendor
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strItemNo
		AND strUnitMeasure = sr.strReceiveUOM
) rv
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strItemNo
		AND strUnitMeasure = sr.strIssueUOM
) iss
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICItemUOM
	WHERE strItemNo = sr.strItemNo
		AND strUnitMeasure = sr.strGrossUOM
) gr
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationSubLocationId
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationId = c.intCompanyLocationId
		AND strSubLocationName = sr.strStorageLocation
) sb
OUTER APPLY (
	SELECT TOP 1 intStorageLocationId
	FROM tblICStorageLocation
	WHERE intSubLocationId = sb.intCompanyLocationSubLocationId
		AND strName = sr.strStorageUnit
) st
OUTER APPLY (
	SELECT intCostAdjustmentType
	FROM (
		SELECT 'Detailed' strDescription, 1 intCostAdjustmentType UNION
		SELECT 'Summarized' strDescription, 2 intCostAdjustmentType
	) CostAdjustmentType WHERE LOWER(CostAdjustmentType.strDescription) = LOWER(sr.strCostAdjustmentType)
) cat
OUTER APPLY (
	SELECT TOP 1 intSubcategoryId
	FROM tblSTSubcategory
	WHERE strSubcategoryId = sr.strFamily
	AND strSubcategoryType = 'F'
) fam
OUTER APPLY (
	SELECT TOP 1 intSubcategoryId
	FROM tblSTSubcategory
	WHERE strSubcategoryId = sr.strClass
	AND strSubcategoryType = 'C'
) cls
OUTER APPLY (
	SELECT TOP 1 intItemUOMId
	FROM vyuICSearchItemUPC
	WHERE strLongUPCCode = sr.strDepositPLU
		AND strLocationName = sr.strLocation
) dp
OUTER APPLY (
	SELECT TOP 1 intRegProdId
	FROM tblSTSubcategoryRegProd
	WHERE strRegProdCode = sr.strProductCode
) prd
OUTER APPLY (
	SELECT intAllowZeroCostTypeId
	FROM (
		SELECT 'No' strDescription, 1 intAllowZeroCostTypeId UNION
		SELECT 'Yes' strDescription, 2 intAllowZeroCostTypeId UNION
		SELECT 'Yes, with warning message' strDescription, 3 intAllowZeroCostTypeId UNION
		SELECT 'Yes on Produce' strDescription, 4 intAllowZeroCostTypeId
	) ZeroCost WHERE LOWER(ZeroCost.strDescription) = LOWER(sr.strAllowZeroCost)
) zc
OUTER APPLY (
	SELECT TOP 1 intRadiantItemTypeCodeId
	FROM tblSTRadiantItemTypeCode
	WHERE strItemTypeCode = sr.strItemTypeCode
) tc
OUTER APPLY (
	SELECT TOP 1 intCountGroupId
	FROM tblICCountGroup
	WHERE strCountGroup = sr.strCountGroup
) cg
OUTER APPLY (
	SELECT TOP 1 intFreightTermId
	FROM vyuSMFreightTerms
	WHERE strFreightTerm = sr.strFreightTerm
) ft
OUTER APPLY (
	SELECT TOP 1 intEntityId
	FROM vyuEMSearchShipVia
	WHERE strShipVia = sr.strShipVia
) sv
OUTER APPLY (
	SELECT intCostingMethod
	FROM (
		SELECT 'AVG' strCostingMethod, 1 intCostingMethod UNION
		SELECT 'FIFO' strCostingMethod, 2 intCostingMethod UNION
		SELECT 'LIFO' strCostingMethod, 3 intCostingMethod UNION
		SELECT 'CATEGORY' strCostingMethod, 6 intCostingMethod
	) CostingMethod WHERE LOWER(CostingMethod.strCostingMethod) = LOWER(sr.strCostingMethod)
) cm
OUTER APPLY (
	SELECT intNegativeInventoryId
	FROM (
		SELECT 'Yes' strDescription, 1 intNegativeInventoryId UNION
		SELECT 'No' strDescription, 3 intNegativeInventoryId
	) NegativeInventory WHERE LOWER(NegativeInventory.strDescription) = LOWER(sr.strAllowNegativeInventory)
) ni
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = sr.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND @OverwriteExisting = 1

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item Location'
    , strValue = c.strLocationName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = il.intRowNumber
    , strMessage = 'The item location ' + c.strLocationName + ' was imported successfully.'
    , strAction = 'Create'
FROM tblICItemLocation il
JOIN tblICItem i ON i.intItemId = il.intItemId
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
WHERE il.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS(SELECT TOP 1 1 FROM @ForUpdates u WHERE u.intRowNumber = il.intRowNumber)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item Location'
    , strValue = c.strLocationName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = il.intRowNumber
    , strMessage = 'The item location ' + c.strLocationName + ' was updated successfully.'
    , strAction = 'Update'
FROM tblICItemLocation il
LEFT JOIN tblICItem i ON i.intItemId = il.intItemId
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
JOIN @ForUpdates u ON u.intItemId = i.intItemId
	AND c.intCompanyLocationId = u.intLocationId
WHERE il.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICItemLocation
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId