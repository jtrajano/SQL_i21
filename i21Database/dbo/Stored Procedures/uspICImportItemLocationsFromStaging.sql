CREATE PROCEDURE uspICImportItemLocationsFromStaging @strIdentifier NVARCHAR(100), @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemLocation WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo, strLocation) AS RowNumber
   FROM tblICImportStagingItemLocation
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intLocationId INT NULL
	, intVendorId INT NULL
	, intSubLocationId INT NULL
	, intStorageLocationId INT NULL
	, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intFamilyId INT NULL
	, intClassId INT NULL
	, intProductCodeId INT NULL
	, strPassportFuelId1 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strPassportFuelId2 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strPassportFuelId3 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnTaxFlag1 BIT NULL
	, ysnTaxFlag2 BIT NULL
	, ysnTaxFlag3 BIT NULL
	, ysnTaxFlag4 BIT NULL
	, ysnPromotionalItem BIT NULL
	, ysnStorageUnitRequired BIT NULL
	, ysnDepositRequired BIT NULL
	, intBottleDepositNo INT NULL
	, ysnSaleable BIT NULL
	, ysnQuantityRequired BIT NULL
	, ysnScaleItem BIT NULL
	, ysnFoodStampable BIT NULL
	, ysnReturnable BIT NULL
	, ysnPrePriced BIT NULL
	, ysnOpenPricePLU BIT NULL
	, ysnLinkedItem BIT NULL
	, strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnIdRequiredLiquor BIT NULL
	, ysnIdRequiredCigarette BIT NULL
	, intMinimumAge INT NULL
	, ysnApplyBlueLaw1 BIT NULL
	, ysnApplyBlueLaw2 BIT NULL
	, ysnCarWash BIT NULL
	, intItemTypeSubCode INT NULL
	, dblReorderPoint NUMERIC(38, 20)
	, dblMinOrder NUMERIC(38, 20)
	, dblSuggestedQty NUMERIC(38, 20)
	, dblLeadTime NUMERIC(38, 20)
	, strCounted NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnCountedDaily BIT NULL
	, ysnCountBySINo BIT NULL
	, strSerialNoBegin NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strSerialNoEnd NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnAutoCalculateFreight BIT NULL
	, dblFreightRate NUMERIC(38, 20)
	, intCostingMethod INT NULL
	, intAllowNegativeInventory INT NULL
	, intReceiveUOMId INT NULL
	, intIssueUOMId INT NULL
	, intGrossUOMId INT NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

INSERT INTO #tmp (
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
	LEFT OUTER JOIN tblSTSubcategoryRegProd pc ON LOWER(pc.strRegProdCode) = LTRIM(RTRIM(LOWER(s.strProductCode)))
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
		AND ri.intItemId = i.intItemId
	LEFT OUTER JOIN tblICUnitMeasure iu ON LOWER(iu.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strSaleUOM)))
	LEFT OUTER JOIN tblICItemUOM rs ON rs.intUnitMeasureId = iu.intUnitMeasureId
		AND rs.intItemId = i.intItemId
	LEFT OUTER JOIN tblICUnitMeasure g ON LOWER(g.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strGrossNetUOM)))
	LEFT OUTER JOIN tblICItemUOM gs ON gs.intUnitMeasureId = g.intUnitMeasureId
		AND gs.intItemId = i.intItemId
WHERE s.strImportIdentifier = @strIdentifier
	
CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL)

;MERGE INTO tblICItemLocation AS target
USING
(
	SELECT
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
	FROM #tmp s
) AS source ON target.intItemId = source.intItemId
	AND target.intLocationId = source.intLocationId
WHEN MATCHED THEN
UPDATE SET
	  intItemId = source.intItemId
	, intLocationId = source.intLocationId
	, intVendorId = source.intVendorId
	, intSubLocationId = source.intSubLocationId
	, intStorageLocationId = source.intStorageLocationId
	, strDescription = source.strDescription
	, intFamilyId = source.intFamilyId
	, intClassId = source.intClassId
	, intProductCodeId = source.intProductCodeId
	, strPassportFuelId1 = source.strPassportFuelId1
	, strPassportFuelId2 = source.strPassportFuelId2
	, strPassportFuelId3 = source.strPassportFuelId3
	, ysnTaxFlag1 = source.ysnTaxFlag1
	, ysnTaxFlag2 = source.ysnTaxFlag2
	, ysnTaxFlag3 = source.ysnTaxFlag3
	, ysnTaxFlag4 = source.ysnTaxFlag4
	, ysnPromotionalItem = source.ysnPromotionalItem
	, ysnStorageUnitRequired = source.ysnStorageUnitRequired
	, ysnDepositRequired = source.ysnDepositRequired
	, intBottleDepositNo = source.intBottleDepositNo
	, ysnSaleable = source.ysnSaleable
	, ysnQuantityRequired = source.ysnQuantityRequired
	, ysnScaleItem = source.ysnScaleItem
	, ysnFoodStampable = source.ysnFoodStampable
	, ysnReturnable = source.ysnReturnable
	, ysnPrePriced = source.ysnPrePriced
	, ysnOpenPricePLU = source.ysnOpenPricePLU
	, ysnLinkedItem = source.ysnLinkedItem
	, strVendorCategory = source.strVendorCategory
	, ysnIdRequiredLiquor = source.ysnIdRequiredLiquor
	, ysnIdRequiredCigarette = source.ysnIdRequiredCigarette
	, intMinimumAge = source.intMinimumAge
	, ysnApplyBlueLaw1 = source.ysnApplyBlueLaw1
	, ysnApplyBlueLaw2 = source.ysnApplyBlueLaw2
	, ysnCarWash = source.ysnCarWash
	, intItemTypeSubCode = source.intItemTypeSubCode
	, dblReorderPoint = source.dblReorderPoint
	, dblMinOrder = source.dblMinOrder
	, dblSuggestedQty = source.dblSuggestedQty
	, dblLeadTime = source.dblLeadTime
	, strCounted = source.strCounted
	, ysnCountedDaily = source.ysnCountedDaily
	, ysnCountBySINo = source.ysnCountBySINo
	, strSerialNoBegin = source.strSerialNoBegin
	, strSerialNoEnd = source.strSerialNoEnd
	, ysnAutoCalculateFreight = source.ysnAutoCalculateFreight
	, dblFreightRate = source.dblFreightRate
	, intCostingMethod = source.intCostingMethod
	, intAllowNegativeInventory = source.intAllowNegativeInventory
	, intReceiveUOMId = source.intReceiveUOMId
	, intIssueUOMId = source.intIssueUOMId
	, intGrossUOMId = source.intGrossUOMId
	, dtmDateModified = GETUTCDATE()
	, intModifiedByUserId = source.intCreatedByUserId
WHEN NOT MATCHED THEN
INSERT
(
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
	, intDataSourceId
)
VALUES
(
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
	, @intDataSourceId
)
OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

UPDATE l
SET l.intRowsImported = (SELECT COUNT(*) FROM #output WHERE strAction = 'INSERT')
	, l.intRowsUpdated = (SELECT COUNT(*) FROM #output WHERE strAction = 'UPDATE')
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DECLARE @TotalImported INT
DECLARE @LogId INT

SELECT @LogId = intImportLogId, @TotalImported = ISNULL(intRowsImported, 0) + ISNULL(intRowsUpdated, 0) 
FROM tblICImportLog 
WHERE strUniqueId = @strIdentifier

IF @TotalImported = 0 AND @LogId IS NOT NULL
BEGIN
	INSERT INTO tblICImportLogDetail(intImportLogId, intRecordNo, strAction, strValue, strMessage, strStatus, strType, intConcurrencyId)
	SELECT @LogId, 0, 'Import finished.', ' ', 'Nothing was imported', 'Success', 'Warning', 1
END

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM [tblICImportStagingItemLocation] WHERE strImportIdentifier = @strIdentifier

UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1