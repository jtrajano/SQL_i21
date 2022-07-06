CREATE PROCEDURE uspApiSchemaTransformItemLocation 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--Check overwrite settings

DECLARE @ysnAllowOverwrite BIT = 0

SELECT @ysnAllowOverwrite = CAST(varPropertyValue AS BIT)
FROM tblApiSchemaTransformProperty
WHERE 
guiApiUniqueId = @guiApiUniqueId
AND
strPropertyName = 'Overwrite'

--Filter Item Location imported

DECLARE @tblFilteredItemLocation TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strStorageLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strStorageUnit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strFamily NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strProductCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPassportFuelId1 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPassportFuelId2 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPassportFuelId3 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnTaxFlag1 BIT NULL,
	ysnTaxFlag2 BIT NULL,
	ysnTaxFlag3 BIT NULL,
	ysnTaxFlag4 BIT NULL,
	ysnPromotionalItem BIT NULL,
	ysnStorageUnitRequired BIT NULL,
	ysnDepositRequired BIT NULL,
	ysnActive BIT NULL,
	intBottleDepositNo INT NULL,
	ysnSaleable BIT NULL,
	ysnQuantityRequired BIT NULL,
	ysnScaleItem BIT NULL,
	ysnFoodStampable BIT NULL,
	ysnReturnable BIT NULL,
	ysnPrePriced BIT NULL,
	ysnOpenPricePLU BIT NULL,
	ysnLinkedItem BIT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnIdRequiredLiquor BIT NULL,
	ysnIdRequiredCigarette BIT NULL,
	intMinimumAge INT NULL,
	ysnApplyBlueLaw1 BIT NULL,
	ysnApplyBlueLaw2 BIT NULL,
	ysnCarWash BIT NULL,
	strItemTypeCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	intItemTypeSubCode INT NULL,
	dblReorderPoint NUMERIC(38, 20),
	dblMinOrder NUMERIC(38, 20),
	dblSuggestedQty NUMERIC(38, 20),
	dblLeadTime NUMERIC(38, 20),
	strCounted NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCountGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnCountedDaily BIT NULL,
	ysnCountBySINo BIT NULL,
	strSerialNoBegin NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strSerialNoEnd NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnAutoCalculateFreight BIT NULL,
	dblFreightRate NUMERIC(38, 20),
	strFreightTerm NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCostingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAllowNegativeInventory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strReceiveUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strIssueUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strGrossUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDepositPLU NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strShipVia NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAllowZeroCost NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strStorageUnitNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCostAdjustmentType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredItemLocation
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strStorageLocation,
	strStorageUnit,
	strDescription,
	strFamily,
	strClass,
	strProductCode,
	strPassportFuelId1,
	strPassportFuelId2,
	strPassportFuelId3,
	ysnTaxFlag1,
	ysnTaxFlag2,
	ysnTaxFlag3,
	ysnTaxFlag4,
	ysnPromotionalItem,
	ysnStorageUnitRequired,
	ysnDepositRequired,
	ysnActive,
	intBottleDepositNo,
	ysnSaleable,
	ysnQuantityRequired,
	ysnScaleItem,
	ysnFoodStampable,
	ysnReturnable,
	ysnPrePriced,
	ysnOpenPricePLU,
	ysnLinkedItem,
	strVendor,
	strVendorCategory,
	ysnIdRequiredLiquor,
	ysnIdRequiredCigarette,
	intMinimumAge,
	ysnApplyBlueLaw1,
	ysnApplyBlueLaw2,
	ysnCarWash,
	strItemTypeCode,
	intItemTypeSubCode,
	dblReorderPoint,
	dblMinOrder,
	dblSuggestedQty,
	dblLeadTime,
	strCounted,
	strCountGroup,
	ysnCountedDaily,
	ysnCountBySINo,
	strSerialNoBegin,
	strSerialNoEnd,
	ysnAutoCalculateFreight,
	dblFreightRate,
	strFreightTerm,
	strCostingMethod,
	strAllowNegativeInventory,
	strReceiveUOM,
	strIssueUOM,
	strGrossUOM,
	strDepositPLU,
	strShipVia,
	strAllowZeroCost,
	strStorageUnitNo,
	strCostAdjustmentType
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strStorageLocation,
	strStorageUnit,
	strDescription,
	strFamily,
	strClass,
	strProductCode,
	strPassportFuelId1,
	strPassportFuelId2,
	strPassportFuelId3,
	ysnTaxFlag1,
	ysnTaxFlag2,
	ysnTaxFlag3,
	ysnTaxFlag4,
	ysnPromotionalItem,
	ysnStorageUnitRequired,
	ysnDepositRequired,
	ysnActive,
	intBottleDepositNo,
	ysnSaleable,
	ysnQuantityRequired,
	ysnScaleItem,
	ysnFoodStampable,
	ysnReturnable,
	ysnPrePriced,
	ysnOpenPricePLU,
	ysnLinkedItem,
	strVendor,
	strVendorCategory,
	ysnIdRequiredLiquor,
	ysnIdRequiredCigarette,
	intMinimumAge,
	ysnApplyBlueLaw1,
	ysnApplyBlueLaw2,
	ysnCarWash,
	strItemTypeCode,
	intItemTypeSubCode,
	dblReorderPoint,
	dblMinOrder,
	dblSuggestedQty,
	dblLeadTime,
	strCounted,
	strCountGroup,
	ysnCountedDaily,
	ysnCountBySINo,
	strSerialNoBegin,
	strSerialNoEnd,
	ysnAutoCalculateFreight,
	dblFreightRate,
	strFreightTerm,
	strCostingMethod,
	strAllowNegativeInventory,
	strReceiveUOM,
	strIssueUOM,
	strGrossUOM,
	strDepositPLU,
	strShipVia,
	strAllowZeroCost,
	strStorageUnitNo,
	strCostAdjustmentType
FROM
tblApiSchemaTransformItemLocation
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemLocation TABLE(
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Item Location
-- 2 - Existing Item Location
-- 3 - Invalid Item
-- 4 - Invalid Location
-- 5 - Invalid Storage Location
-- 6 - Invalid Storage Unit
-- 7 - Invalid Vendor
-- 8 - Invalid Costing Method
-- 9 - Invalid Gross/Net Unit of Measure
-- 10 - Invalid Sale Unit of Measure
-- 11 - Invalid Purchase Unit of Measure
-- 12 - Invalid Family
-- 13 - Invalid Class
-- 14 - Invalid Product Code
-- 15 - Invalid Deposit PLU
-- 16 - Invalid Item Type Code
-- 17 - Invalid Cost Adjustment Type
-- 18 - Invalid Negative Inventory
-- 19 - Invalid Allow Zero Cost
-- 20 - Invalid Inventory Count Group
-- 21 - Invalid Counted
-- 22 - Invalid Freight Term
-- 23 - Invalid Ship Via

--Validate Records

INSERT INTO @tblErrorItemLocation
(
	strItemNo,
	strLocation,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Item Location
	strItemNo = DuplicateImportItemLocation.strItemNo,
	strLocation = DuplicateImportItemLocation.strLocation,
	strFieldValue = DuplicateImportItemLocation.strLocation,
	intRowNumber = DuplicateImportItemLocation.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strLocation,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY intRowNumber)
	FROM 
		@tblFilteredItemLocation
) AS DuplicateImportItemLocation
WHERE RowNumber > 1
UNION
SELECT -- Existing Item Location
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strLocation,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredItemLocation FilteredItemLocation
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemLocation.strItemNo = ItemLocation.strItemNo
AND
FilteredItemLocation.strLocation = ItemLocation.strLocationName
AND @ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Item
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strItemNo,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
tblICItem Item
ON
FilteredItemLocation.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strLocation,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredItemLocation.strLocation = CompanyLocation.strLocationName
WHERE
CompanyLocation.intCompanyLocationId IS NULL
UNION
SELECT -- Invalid Storage Location
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strStorageLocation,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuSMCompanyLocationSubLocation StorageLocation
ON
FilteredItemLocation.strLocation = StorageLocation.strLocationName
AND
FilteredItemLocation.strStorageLocation = StorageLocation.strSubLocationName
WHERE
StorageLocation.intCompanyLocationSubLocationId IS NULL
AND
FilteredItemLocation.strStorageLocation IS NOT NULL
UNION
SELECT -- Invalid Storage Unit
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strStorageUnit,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 6
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuICGetStorageLocation StorageUnit
ON
FilteredItemLocation.strLocation = StorageUnit.strLocationName
AND
FilteredItemLocation.strStorageLocation = StorageUnit.strSubLocationName
AND
FilteredItemLocation.strStorageUnit = StorageUnit.strName
WHERE
StorageUnit.intStorageLocationId IS NULL
AND
FilteredItemLocation.strStorageUnit IS NOT NULL
UNION
SELECT -- Invalid Vendor
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strVendor,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 7
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuAPVendor Vendor
ON
FilteredItemLocation.strVendor = Vendor.strName
WHERE
Vendor.intEntityId IS NULL
AND
FilteredItemLocation.strVendor IS NOT NULL
UNION
SELECT -- Invalid Costing Method
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strCostingMethod,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 8
FROM
@tblFilteredItemLocation FilteredItemLocation
WHERE
FilteredItemLocation.strCostingMethod NOT IN('AVG', 'FIFO', 'LIFO', 'CATEGORY')
AND
FilteredItemLocation.strCostingMethod IS NOT NULL
UNION
SELECT -- Invalid Gross/Net Unit of Measure
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strGrossUOM,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 9
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemLocation.strItemNo = ItemUOM.strItemNo
AND
FilteredItemLocation.strGrossUOM = ItemUOM.strUnitMeasure
LEFT JOIN
tblICUnitMeasure UnitMeasure
ON
FilteredItemLocation.strGrossUOM = UnitMeasure.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
AND
UnitMeasure.strUnitType IN('Volume', 'Weight')
AND
FilteredItemLocation.strGrossUOM IS NOT NULL
UNION
SELECT -- Invalid Sale Unit of Measure
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strIssueUOM,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 10
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemLocation.strItemNo = ItemUOM.strItemNo
AND
FilteredItemLocation.strIssueUOM = ItemUOM.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
AND
ItemUOM.ysnAllowSale = 1
AND
FilteredItemLocation.strIssueUOM IS NOT NULL
UNION
SELECT -- Invalid Purchase Unit of Measure
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strReceiveUOM,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 11
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemLocation.strItemNo = ItemUOM.strItemNo
AND
FilteredItemLocation.strReceiveUOM = ItemUOM.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
AND
ItemUOM.ysnAllowPurchase = 1
AND
FilteredItemLocation.strIssueUOM IS NOT NULL
UNION
SELECT -- Invalid Family
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strFamily,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 12
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN tblSTSubcategory SubCategory
ON
FilteredItemLocation.strFamily = SubCategory.strSubcategoryId
AND
SubCategory.strSubcategoryType = 'F'
WHERE
SubCategory.intSubcategoryId IS NULL
AND
FilteredItemLocation.strFamily IS NOT NULL
UNION
SELECT -- Invalid Class
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strClass,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 13
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN tblSTSubcategory SubCategory
ON
FilteredItemLocation.strClass = SubCategory.strSubcategoryId
AND
SubCategory.strSubcategoryType = 'C'
WHERE
SubCategory.intSubcategoryId IS NULL
AND
FilteredItemLocation.strClass IS NOT NULL
UNION
SELECT -- Invalid Product Code
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strProductCode,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 14
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN tblSTSubcategoryRegProd SubcategoryRegProd
ON
FilteredItemLocation.strProductCode = SubcategoryRegProd.strRegProdCode
WHERE
SubcategoryRegProd.intRegProdId IS NULL
AND
FilteredItemLocation.strProductCode IS NOT NULL
UNION
SELECT -- Invalid Deposit PLU
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strDepositPLU,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 15
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN vyuICSearchItemUPC ItemUPC
ON
FilteredItemLocation.strDepositPLU = ItemUPC.strLongUPCCode
AND
FilteredItemLocation.strLocation = ItemUPC.strLocationName
WHERE
ItemUPC.intItemUOMId IS NULL
AND
FilteredItemLocation.strDepositPLU IS NOT NULL
UNION
SELECT -- Invalid Item Type Code
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strItemTypeCode,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 16
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN tblSTRadiantItemTypeCode ItemTypeCode
ON
FilteredItemLocation.strItemTypeCode = ItemTypeCode.strDescription
WHERE
ItemTypeCode.intRadiantItemTypeCodeId IS NULL
AND
FilteredItemLocation.strItemTypeCode IS NOT NULL
UNION
SELECT -- Invalid Cost Adjustment Type
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strCostAdjustmentType,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 17
FROM
@tblFilteredItemLocation FilteredItemLocation
WHERE
FilteredItemLocation.strCostAdjustmentType NOT IN('Detailed', 'Summarized')
AND
FilteredItemLocation.strCostAdjustmentType IS NOT NULL
UNION
SELECT -- Invalid Negative Inventory
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strAllowNegativeInventory,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 18
FROM
@tblFilteredItemLocation FilteredItemLocation
WHERE
FilteredItemLocation.strAllowNegativeInventory NOT IN('Yes', 'No')
AND
FilteredItemLocation.strAllowNegativeInventory IS NOT NULL
UNION
SELECT -- Invalid Allow Zero Cost
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strAllowZeroCost,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 19
FROM
@tblFilteredItemLocation FilteredItemLocation
WHERE
FilteredItemLocation.strAllowZeroCost NOT IN('Yes, with warning message', 'Yes on Produce', 'Yes', 'No')
AND
FilteredItemLocation.strAllowZeroCost IS NOT NULL
UNION
SELECT -- Invalid Inventory Count Group
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strCountGroup,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 20
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN tblICCountGroup CountGroup
ON
FilteredItemLocation.strCountGroup = CountGroup.strCountGroup
WHERE
CountGroup.intCountGroupId IS NULL
AND
FilteredItemLocation.strCountGroup IS NOT NULL
UNION
SELECT -- Invalid Counted
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strCounted,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 21
FROM
@tblFilteredItemLocation FilteredItemLocation
WHERE
FilteredItemLocation.strCounted NOT IN('Counted', 'Not Counted', 'Obsolete', 'Blended', 'Automatic Blend', 'Special Order')
AND
FilteredItemLocation.strCounted IS NOT NULL
UNION
SELECT -- Invalid Freight Term
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strFreightTerm,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 22
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN vyuSMFreightTerms FreightTerms
ON
FilteredItemLocation.strFreightTerm = FreightTerms.strFreightTerm
WHERE
FreightTerms.intFreightTermId IS NULL
AND
FilteredItemLocation.strFreightTerm IS NOT NULL
UNION
SELECT -- Invalid Ship Via
	strItemNo = FilteredItemLocation.strItemNo,
	strLocation = FilteredItemLocation.strLocation,
	strFieldValue = FilteredItemLocation.strShipVia,
	intRowNumber = FilteredItemLocation.intRowNumber,
	intErrorType = 23
FROM
@tblFilteredItemLocation FilteredItemLocation
LEFT JOIN vyuEMSearchShipVia ShipVia
ON
FilteredItemLocation.strShipVia = ShipVia.strShipVia
WHERE
ShipVia.intEntityId IS NULL
AND
FilteredItemLocation.strShipVia IS NOT NULL

INSERT INTO tblApiImportLogDetail 
(
	guiApiImportLogDetailId,
	guiApiImportLogId,
	strField,
	strValue,
	strLogLevel,
	strStatus,
	intRowNo,
	strMessage
)
SELECT
	guiApiImportLogDetailId = NEWID(),
	guiApiImportLogId = @guiLogId,
	strField = CASE
		WHEN ErrorItemLocation.intErrorType IN (1, 2, 4)
		THEN 'Location'
		WHEN ErrorItemLocation.intErrorType = 3
		THEN 'Item No'
		WHEN ErrorItemLocation.intErrorType = 5
		THEN 'Storage Location'
		WHEN ErrorItemLocation.intErrorType = 6
		THEN 'Storage Unit'
		WHEN ErrorItemLocation.intErrorType = 7
		THEN 'Vendor'
		WHEN ErrorItemLocation.intErrorType = 8
		THEN 'Costing Method'
		WHEN ErrorItemLocation.intErrorType = 9
		THEN 'Gross/Net UOM'
		WHEN ErrorItemLocation.intErrorType = 10
		THEN 'Sale UOM'
		WHEN ErrorItemLocation.intErrorType = 11
		THEN 'Purchase UOM'
		WHEN ErrorItemLocation.intErrorType = 12
		THEN 'Family'
		WHEN ErrorItemLocation.intErrorType = 13
		THEN 'Class'
		WHEN ErrorItemLocation.intErrorType = 14
		THEN 'Product Code'
		WHEN ErrorItemLocation.intErrorType = 15
		THEN 'Deposit PLU'
		WHEN ErrorItemLocation.intErrorType = 16
		THEN 'Item Type Code'
		WHEN ErrorItemLocation.intErrorType = 17
		THEN 'Cost Adjustment Type'
		WHEN ErrorItemLocation.intErrorType = 18
		THEN 'Allow Negative Inventory'
		WHEN ErrorItemLocation.intErrorType = 19
		THEN 'Allow Zero Cost'
		WHEN ErrorItemLocation.intErrorType = 20
		THEN 'Inventory Count Group'
		WHEN ErrorItemLocation.intErrorType = 21
		THEN 'Counted'
		WHEN ErrorItemLocation.intErrorType = 22
		THEN 'Freight Term'
		ELSE 'Ship Via'
	END,
	strValue = ErrorItemLocation.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorItemLocation.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorItemLocation.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorItemLocation.intRowNumber,
	strMessage = CASE
		WHEN ErrorItemLocation.intErrorType = 1
		THEN 'Duplicate imported location: ' + ErrorItemLocation.strLocation + ' on item: ' + ErrorItemLocation.strItemNo + '.' 
		WHEN ErrorItemLocation.intErrorType = 2
		THEN 'Location: ' + ErrorItemLocation.strLocation + ' on item: ' + ErrorItemLocation.strItemNo + ' already exists and overwrite is not enabled.'
		WHEN ErrorItemLocation.intErrorType = 3
		THEN 'Invalid item: ' + ErrorItemLocation.strItemNo + '.'
		WHEN ErrorItemLocation.intErrorType = 4
		THEN 'Invalid location: ' + ErrorItemLocation.strLocation + '.'
		WHEN ErrorItemLocation.intErrorType = 5
		THEN 'Invalid storage location: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 6
		THEN 'Invalid storage unit: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 7
		THEN 'Invalid storage vendor: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 8
		THEN 'Invalid costing method: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 9
		THEN 'Invalid gross/net unit of measure: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 10
		THEN 'Invalid sale unit of measure: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 11
		THEN 'Invalid purchase unit of measure: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 12
		THEN 'Invalid family: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 13
		THEN 'Invalid class: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 14
		THEN 'Invalid product code: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 15
		THEN 'Invalid deposit PLU: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 16
		THEN 'Invalid item type code: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 17
		THEN 'Invalid cost adjustment type: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 18
		THEN 'Invalid allow negative inventory: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 19
		THEN 'Invalid allow zero cost: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 20
		THEN 'Invalid inventory count group: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 21
		THEN 'Invalid counted: ' + ErrorItemLocation.strFieldValue + '.'
		WHEN ErrorItemLocation.intErrorType = 22
		THEN 'Invalid freight term: ' + ErrorItemLocation.strFieldValue + '.'
		ELSE 'Invalid ship via: ' + ErrorItemLocation.strFieldValue + '.'
	END
FROM @tblErrorItemLocation ErrorItemLocation
WHERE ErrorItemLocation.intErrorType BETWEEN 1 AND 23

--Filter Item Location to be removed

DELETE 
FilteredItemLocation
FROM 
	@tblFilteredItemLocation FilteredItemLocation
	INNER JOIN @tblErrorItemLocation ErrorItemLocation
		ON FilteredItemLocation.intRowNumber = ErrorItemLocation.intRowNumber
WHERE ErrorItemLocation.intErrorType BETWEEN 1 AND 23

--Transform and Insert statement

;MERGE INTO tblICItemLocation AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItemLocation.guiApiUniqueId,
		intItemId = Item.intItemId,
		intLocationId = CompanyLocation.intCompanyLocationId,
		intVendorId = Vendor.intEntityId,
		intSubLocationId = StorageLocation.intCompanyLocationSubLocationId,
		intStorageLocationId = StorageUnit.intStorageLocationId,
		strDescription = FilteredItemLocation.strDescription,
		intFamilyId = Family.intSubcategoryId,
		intClassId = Class.intSubcategoryId,
		intProductCodeId = ProductCode.intRegProdId,
		strPassportFuelId1 = FilteredItemLocation.strPassportFuelId1,
		strPassportFuelId2 = FilteredItemLocation.strPassportFuelId2,
		strPassportFuelId3 = FilteredItemLocation.strPassportFuelId3,
		ysnTaxFlag1	= FilteredItemLocation.ysnTaxFlag1,
		ysnTaxFlag2	= FilteredItemLocation.ysnTaxFlag2,
		ysnTaxFlag3	= FilteredItemLocation.ysnTaxFlag3,
		ysnTaxFlag4	= FilteredItemLocation.ysnTaxFlag4,
		ysnPromotionalItem = FilteredItemLocation.ysnPromotionalItem,
		ysnStorageUnitRequired = FilteredItemLocation.ysnStorageUnitRequired,
		ysnDepositRequired = FilteredItemLocation.ysnDepositRequired,
		ysnActive = FilteredItemLocation.ysnActive,
		intBottleDepositNo = FilteredItemLocation.intBottleDepositNo,
		ysnSaleable = FilteredItemLocation.ysnSaleable,
		ysnQuantityRequired = FilteredItemLocation.ysnQuantityRequired,
		ysnScaleItem = FilteredItemLocation.ysnScaleItem,
		ysnFoodStampable = FilteredItemLocation.ysnFoodStampable,
		ysnReturnable = FilteredItemLocation.ysnReturnable,
		ysnPrePriced = FilteredItemLocation.ysnPrePriced,
		ysnOpenPricePLU = FilteredItemLocation.ysnOpenPricePLU,
		ysnLinkedItem = FilteredItemLocation.ysnLinkedItem,
		strVendorCategory = FilteredItemLocation.strVendorCategory,
		ysnIdRequiredLiquor = FilteredItemLocation.ysnIdRequiredLiquor,
		ysnIdRequiredCigarette = FilteredItemLocation.ysnIdRequiredCigarette,
		intMinimumAge = FilteredItemLocation.intMinimumAge,
		ysnApplyBlueLaw1 = FilteredItemLocation.ysnApplyBlueLaw1,
		ysnApplyBlueLaw2 = FilteredItemLocation.ysnApplyBlueLaw2,
		ysnCarWash = FilteredItemLocation.ysnCarWash,
		intItemTypeCode = ItemTypeCode.intRadiantItemTypeCodeId,
		intItemTypeSubCode = FilteredItemLocation.intItemTypeSubCode,
		dblReorderPoint = FilteredItemLocation.dblReorderPoint,
		dblMinOrder = FilteredItemLocation.dblMinOrder,
		dblSuggestedQty = FilteredItemLocation.dblSuggestedQty,
		dblLeadTime = FilteredItemLocation.dblLeadTime,
		strCounted = FilteredItemLocation.strCounted,
		intCountGroupId = CountGroup.intCountGroupId,
		ysnCountedDaily = FilteredItemLocation.ysnCountedDaily,
		ysnCountBySINo = FilteredItemLocation.ysnCountBySINo,
		strSerialNoBegin = FilteredItemLocation.strSerialNoBegin,
		strSerialNoEnd = FilteredItemLocation.strSerialNoEnd,
		ysnAutoCalculateFreight = FilteredItemLocation.ysnAutoCalculateFreight,
		dblFreightRate = FilteredItemLocation.dblFreightRate,
		intFreightMethodId = FreightTerms.intFreightTermId,
		intCostingMethod = ISNULL(CostingMethod.intCostingMethod, 1),
		intAllowNegativeInventory = ISNULL(NegativeInventory.intNegativeInventoryId, 1),
		intDepositPLUId = DepositPLU.intItemUOMId,
		intShipViaId = ShipVia.intEntityId,
		intAllowZeroCostTypeId = ZeroCost.intAllowZeroCostTypeId,
		strStorageUnitNo = FilteredItemLocation.strStorageUnitNo,
		intCostAdjustmentType = CostAdjustmentType.intCostAdjustmentType,
		intReceiveUOMId = ReceiveUOM.intItemUOMId,
		intIssueUOMId = IssueUOM.intItemUOMId,
		intGrossUOMId = GrossUOM.intItemUOMId
	FROM @tblFilteredItemLocation FilteredItemLocation
	INNER JOIN
	tblICItem Item
		ON
		FilteredItemLocation.strItemNo = Item.strItemNo
	INNER JOIN
	tblSMCompanyLocation CompanyLocation
		ON
		FilteredItemLocation.strLocation = CompanyLocation.strLocationName
	LEFT JOIN
	vyuSMCompanyLocationSubLocation StorageLocation
		ON
		FilteredItemLocation.strLocation = StorageLocation.strLocationName
		AND
		FilteredItemLocation.strStorageLocation = StorageLocation.strSubLocationName
	LEFT JOIN
	vyuICGetStorageLocation StorageUnit
		ON
		FilteredItemLocation.strLocation = StorageUnit.strLocationName
		AND
		FilteredItemLocation.strStorageLocation = StorageUnit.strSubLocationName
		AND
		FilteredItemLocation.strStorageUnit = StorageUnit.strName
	LEFT JOIN
	vyuAPVendor Vendor
		ON
		FilteredItemLocation.strVendor = Vendor.strName
	OUTER APPLY (
		SELECT intCostingMethod
		FROM (
			SELECT 'AVG' strCostingMethod, 1 intCostingMethod UNION
			SELECT 'FIFO' strCostingMethod, 2 intCostingMethod UNION
			SELECT 'LIFO' strCostingMethod, 3 intCostingMethod UNION
			SELECT 'CATEGORY' strCostingMethod, 6 intCostingMethod
		) CostingMethod WHERE LOWER(CostingMethod.strCostingMethod) = LOWER(FilteredItemLocation.strCostingMethod)
	) CostingMethod
	LEFT JOIN
	vyuICItemUOM GrossUOM
		ON
		FilteredItemLocation.strItemNo = GrossUOM.strItemNo
		AND
		FilteredItemLocation.strGrossUOM = GrossUOM.strUnitMeasure
	LEFT JOIN
	vyuICItemUOM IssueUOM
		ON
		FilteredItemLocation.strItemNo = IssueUOM.strItemNo
		AND
		FilteredItemLocation.strIssueUOM = IssueUOM.strUnitMeasure
	LEFT JOIN
	vyuICItemUOM ReceiveUOM
		ON
		FilteredItemLocation.strItemNo = ReceiveUOM.strItemNo
		AND
		FilteredItemLocation.strReceiveUOM = ReceiveUOM.strUnitMeasure
	LEFT JOIN 
	tblSTSubcategory Family
		ON
		FilteredItemLocation.strFamily = Family.strSubcategoryId
		AND
		Family.strSubcategoryType = 'F'
	LEFT JOIN 
	tblSTSubcategory Class
		ON
		FilteredItemLocation.strClass = Class.strSubcategoryId
		AND
		Class.strSubcategoryType = 'C'
	LEFT JOIN 
	tblSTSubcategoryRegProd ProductCode
		ON
		FilteredItemLocation.strProductCode = ProductCode.strRegProdCode
	LEFT JOIN 
	vyuICSearchItemUPC DepositPLU
		ON
		FilteredItemLocation.strDepositPLU = DepositPLU.strLongUPCCode
		AND
		FilteredItemLocation.strLocation = DepositPLU.strLocationName
	LEFT JOIN 
	tblSTRadiantItemTypeCode ItemTypeCode
		ON
		FilteredItemLocation.strItemTypeCode = ItemTypeCode.strDescription
	OUTER APPLY (
		SELECT intCostAdjustmentType
		FROM (
			SELECT 'Detailed' strDescription, 1 intCostAdjustmentType UNION
			SELECT 'Summarized' strDescription, 2 intCostAdjustmentType
		) CostAdjustmentType WHERE LOWER(CostAdjustmentType.strDescription) = LOWER(FilteredItemLocation.strCostAdjustmentType)
	) CostAdjustmentType
	OUTER APPLY (
		SELECT intNegativeInventoryId
		FROM (
			SELECT 'Yes' strDescription, 1 intNegativeInventoryId UNION
			SELECT 'No' strDescription, 3 intNegativeInventoryId
		) NegativeInventory WHERE LOWER(NegativeInventory.strDescription) = LOWER(FilteredItemLocation.strAllowNegativeInventory)
	) NegativeInventory
	OUTER APPLY (
		SELECT intAllowZeroCostTypeId
		FROM (
			SELECT 'No' strDescription, 1 intAllowZeroCostTypeId UNION
			SELECT 'Yes' strDescription, 2 intAllowZeroCostTypeId UNION
			SELECT 'Yes, with warning message' strDescription, 3 intAllowZeroCostTypeId UNION
			SELECT 'Yes on Produce' strDescription, 4 intAllowZeroCostTypeId
		) ZeroCost WHERE LOWER(ZeroCost.strDescription) = LOWER(FilteredItemLocation.strAllowZeroCost)
	) ZeroCost
	LEFT JOIN 
	tblICCountGroup CountGroup
		ON
		FilteredItemLocation.strCountGroup = CountGroup.strCountGroup
	LEFT JOIN 
	vyuSMFreightTerms FreightTerms
		ON
		FilteredItemLocation.strFreightTerm = FreightTerms.strFreightTerm
	LEFT JOIN 
	vyuEMSearchShipVia ShipVia
		ON
		FilteredItemLocation.strShipVia = ShipVia.strShipVia
) AS SOURCE
ON TARGET.intItemId = SOURCE.intItemId AND TARGET.intLocationId = SOURCE.intLocationId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intLocationId = SOURCE.intLocationId,
		intVendorId = SOURCE.intVendorId,
		intSubLocationId = SOURCE.intSubLocationId,
		intStorageLocationId = SOURCE.intStorageLocationId,
		strDescription = SOURCE.strDescription,
		intFamilyId = SOURCE.intFamilyId,
		intClassId = SOURCE.intClassId,
		intProductCodeId = SOURCE.intProductCodeId,
		strPassportFuelId1 = SOURCE.strPassportFuelId1,
		strPassportFuelId2 = SOURCE.strPassportFuelId2,
		strPassportFuelId3 = SOURCE.strPassportFuelId3,
		ysnTaxFlag1	= SOURCE.ysnTaxFlag1,
		ysnTaxFlag2	= SOURCE.ysnTaxFlag2,
		ysnTaxFlag3	= SOURCE.ysnTaxFlag3,
		ysnTaxFlag4	= SOURCE.ysnTaxFlag4,
		ysnPromotionalItem = SOURCE.ysnPromotionalItem,
		ysnStorageUnitRequired = SOURCE.ysnStorageUnitRequired,
		ysnDepositRequired = SOURCE.ysnDepositRequired,
		ysnActive = SOURCE.ysnActive,
		intBottleDepositNo = SOURCE.intBottleDepositNo,
		ysnSaleable = SOURCE.ysnSaleable,
		ysnQuantityRequired = SOURCE.ysnQuantityRequired,
		ysnScaleItem = SOURCE.ysnScaleItem,
		ysnFoodStampable = SOURCE.ysnFoodStampable,
		ysnReturnable = SOURCE.ysnReturnable,
		ysnPrePriced = SOURCE.ysnPrePriced,
		ysnOpenPricePLU = SOURCE.ysnOpenPricePLU,
		ysnLinkedItem = SOURCE.ysnLinkedItem,
		strVendorCategory = SOURCE.strVendorCategory,
		ysnIdRequiredLiquor = SOURCE.ysnIdRequiredLiquor,
		ysnIdRequiredCigarette = SOURCE.ysnIdRequiredCigarette,
		intMinimumAge = SOURCE.intMinimumAge,
		ysnApplyBlueLaw1 = SOURCE.ysnApplyBlueLaw1,
		ysnApplyBlueLaw2 = SOURCE.ysnApplyBlueLaw2,
		ysnCarWash = SOURCE.ysnCarWash,
		intItemTypeCode = SOURCE.intItemTypeCode,
		intItemTypeSubCode = SOURCE.intItemTypeSubCode,
		dblReorderPoint = SOURCE.dblReorderPoint,
		dblMinOrder = SOURCE.dblMinOrder,
		dblSuggestedQty = SOURCE.dblSuggestedQty,
		dblLeadTime = SOURCE.dblLeadTime,
		strCounted = SOURCE.strCounted,
		intCountGroupId = SOURCE.intCountGroupId,
		ysnCountedDaily = SOURCE.ysnCountedDaily,
		ysnCountBySINo = SOURCE.ysnCountBySINo,
		strSerialNoBegin = SOURCE.strSerialNoBegin,
		strSerialNoEnd = SOURCE.strSerialNoEnd,
		ysnAutoCalculateFreight = SOURCE.ysnAutoCalculateFreight,
		dblFreightRate = SOURCE.dblFreightRate,
		intFreightMethodId = SOURCE.intFreightMethodId,
		intCostingMethod = SOURCE.intCostingMethod,
		intAllowNegativeInventory = SOURCE.intAllowNegativeInventory,
		intDepositPLUId = SOURCE.intDepositPLUId,
		intShipViaId = SOURCE.intShipViaId,
		intAllowZeroCostTypeId = SOURCE.intAllowZeroCostTypeId,
		strStorageUnitNo = SOURCE.strStorageUnitNo,
		intCostAdjustmentType = SOURCE.intCostAdjustmentType,
		intReceiveUOMId = SOURCE.intReceiveUOMId,
		intIssueUOMId = SOURCE.intIssueUOMId,
		intGrossUOMId = SOURCE.intGrossUOMId
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intLocationId,
		intVendorId,
		intSubLocationId,
		intStorageLocationId,
		strDescription,
		intFamilyId,
		intClassId,
		intProductCodeId,
		strPassportFuelId1,
		strPassportFuelId2,
		strPassportFuelId3,
		ysnTaxFlag1,
		ysnTaxFlag2,
		ysnTaxFlag3,
		ysnTaxFlag4,
		ysnPromotionalItem,
		ysnStorageUnitRequired,
		ysnDepositRequired,
		ysnActive,
		intBottleDepositNo,
		ysnSaleable,
		ysnQuantityRequired,
		ysnScaleItem,
		ysnFoodStampable,
		ysnReturnable,
		ysnPrePriced,
		ysnOpenPricePLU,
		ysnLinkedItem,
		strVendorCategory,
		ysnIdRequiredLiquor,
		ysnIdRequiredCigarette,
		intMinimumAge,
		ysnApplyBlueLaw1,
		ysnApplyBlueLaw2,
		ysnCarWash,
		intItemTypeCode,
		intItemTypeSubCode,
		dblReorderPoint,
		dblMinOrder,
		dblSuggestedQty,
		dblLeadTime,
		strCounted,
		intCountGroupId,
		ysnCountedDaily,
		ysnCountBySINo,
		strSerialNoBegin,
		strSerialNoEnd,
		ysnAutoCalculateFreight,
		dblFreightRate,
		intFreightMethodId,
		intCostingMethod,
		intAllowNegativeInventory,
		intDepositPLUId,
		intShipViaId,
		intAllowZeroCostTypeId,
		strStorageUnitNo,
		intCostAdjustmentType,
		intReceiveUOMId,
		intIssueUOMId,
		intGrossUOMId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intLocationId,
		intVendorId,
		intSubLocationId,
		intStorageLocationId,
		strDescription,
		intFamilyId,
		intClassId,
		intProductCodeId,
		strPassportFuelId1,
		strPassportFuelId2,
		strPassportFuelId3,
		ysnTaxFlag1,
		ysnTaxFlag2,
		ysnTaxFlag3,
		ysnTaxFlag4,
		ysnPromotionalItem,
		ysnStorageUnitRequired,
		ysnDepositRequired,
		ysnActive,
		intBottleDepositNo,
		ysnSaleable,
		ysnQuantityRequired,
		ysnScaleItem,
		ysnFoodStampable,
		ysnReturnable,
		ysnPrePriced,
		ysnOpenPricePLU,
		ysnLinkedItem,
		strVendorCategory,
		ysnIdRequiredLiquor,
		ysnIdRequiredCigarette,
		intMinimumAge,
		ysnApplyBlueLaw1,
		ysnApplyBlueLaw2,
		ysnCarWash,
		intItemTypeCode,
		intItemTypeSubCode,
		dblReorderPoint,
		dblMinOrder,
		dblSuggestedQty,
		dblLeadTime,
		strCounted,
		intCountGroupId,
		ysnCountedDaily,
		ysnCountBySINo,
		strSerialNoBegin,
		strSerialNoEnd,
		ysnAutoCalculateFreight,
		dblFreightRate,
		intFreightMethodId,
		intCostingMethod,
		intAllowNegativeInventory,
		intDepositPLUId,
		intShipViaId,
		intAllowZeroCostTypeId,
		strStorageUnitNo,
		intCostAdjustmentType,
		intReceiveUOMId,
		intIssueUOMId,
		intGrossUOMId,
		GETUTCDATE()
	);