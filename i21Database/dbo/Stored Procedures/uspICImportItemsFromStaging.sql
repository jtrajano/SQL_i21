CREATE PROCEDURE uspICImportItemsFromStaging 
	@strIdentifier NVARCHAR(100)
	, @ysnAllowOverwrite BIT = 0
	, @ysnVerboseLog BIT = 1
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItem WHERE strImportIdentifier <> @strIdentifier

CREATE TABLE #tmp_validRecords (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
	, strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intLifeTime INT NULL
	, strShortName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strLotTracking NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnLotWeightsRequired BIT NULL
	, ysnUseWeighScales BIT NULL
	, strBarcodePrint NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intManufacturerId INT NULL
	, intCommodityId INT NULL
	, intBrandId INT NULL
	, strModelNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intCategoryId INT NULL
	, ysnStockedItem BIT NULL
	, ysnDyedFuel BIT NULL
	, ysnMSDSRequired BIT NULL
	, strEPANumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnInboundTax BIT NULL
	, ysnRestrictedChemical BIT NULL
	, ysnFuelItem BIT NULL
	, ysnListBundleSeparately BIT NULL
	, dblDenaturantPercent NUMERIC(38, 20)
	, ysnTonnageTax BIT NULL
	, ysnLoadTracking BIT NULL
	, dblMixOrder NUMERIC(38, 20)
	, ysnHandAddIngredient BIT NULL
	, ysnExtendPickTicket BIT NULL
	, ysnExportEDI BIT NULL
	, ysnHazardMaterial BIT NULL
	, ysnMaterialFee BIT NULL
	, ysnAutoBlend BIT NULL
	, dblUserGroupFee NUMERIC(38, 20)
	, dblWeightTolerance NUMERIC(38, 20)
	, dblOverReceiveTolerance NUMERIC(38, 20)
	, ysnLandedCost BIT NULL
	, strLeadTime NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnTaxable BIT NULL
	, strKeywords NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, dblCaseQty NUMERIC(38, 20)
	, dtmDateShip DATETIME NULL
	, dblTaxExempt NUMERIC(38, 20)
	, ysnDropShip BIT NULL
	, ysnCommisionable BIT NULL
	, ysnSpecialCommission BIT NULL
	, ysnTankRequired BIT NULL
	, ysnAvailableTM BIT NULL
	, dblDefaultFull NUMERIC(38, 20)
	, dblMaintenanceRate NUMERIC(38, 20)
	, strNACSCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnReceiptCommentRequired BIT NULL
	, intPatronageCategoryDirectId INT NULL
	, intPatronageCategoryId INT NULL
	, intPhysicalItem INT NULL
	, strVolumeRebateGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intIngredientTag INT NULL
	, intMedicationTag INT NULL
	, intRINFuelTypeId INT NULL
	, strFuelInspectFee NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, [ysnSeparateStockForUOMs] BIT NULL DEFAULT ((0))
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

CREATE TABLE #tmp_lotTrackingChange (
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,intId INT 
)

CREATE TABLE #tmp_itemTypeChange (
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,intId INT 
)

CREATE TABLE #tmp_commodityChange (
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,intId INT 
)

-------------------------------------------------------------------------
-- BEGIN Validate records
-------------------------------------------------------------------------
BEGIN
	-- Check if lot tracking can be changed
	IF @ysnAllowOverwrite = 1
	BEGIN 
		INSERT INTO #tmp_lotTrackingChange (
			strItemNo
			,intId
		)
		SELECT
			s.strItemNo
			,intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemId)
		FROM 
			tblICImportStagingItem s INNER JOIN tblICItem i 
				ON s.strItemNo = i.strItemNo
		WHERE
			s.strImportIdentifier = @strIdentifier
			AND s.strLotTracking IS NOT NULL 		
			AND LOWER(i.strLotTracking) <> RTRIM(LTRIM(LOWER(ISNULL(s.strLotTracking, 'No'))))	
			AND dbo.fnAllowLotTrackingToChange(i.intItemId, i.strLotTracking) = 0
	END 

	-- Check if item type can be changed. 
	IF @ysnAllowOverwrite = 1
	BEGIN 
		INSERT INTO #tmp_itemTypeChange (
			strItemNo
			,intId
		)
		SELECT
			s.strItemNo
			,s.intId
		FROM 
			(
				SELECT 
					* 
					,intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemId)
				FROM 
					tblICImportStagingItem s 
				WHERE
					s.strImportIdentifier = @strIdentifier		
			) s
			INNER JOIN tblICItem i 
				ON s.strItemNo = i.strItemNo
		WHERE
			s.strType IS NOT NULL
			AND LOWER(i.strType) <> LTRIM(RTRIM(LOWER(ISNULL(s.strType, 'Inventory'))))
			AND dbo.fnAllowItemTypeChange(i.intItemId, i.strType) = 0
	END 

	-- Check if commodity can be changed. 
	IF @ysnAllowOverwrite = 1
	BEGIN 
		INSERT INTO #tmp_commodityChange (
			strItemNo
			,intId
		)
		SELECT
			s.strItemNo
			,s.intId 
		FROM 
			(
				SELECT 
					* 
					,intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemId)
				FROM 
					tblICImportStagingItem s 
				WHERE
					s.strImportIdentifier = @strIdentifier		
			) s			
			INNER JOIN tblICItem i 
				ON s.strItemNo = i.strItemNo
			INNER JOIN tblICCommodity cm
				ON cm.intCommodityId = i.intCommodityId
		WHERE
			s.strCommodity IS NOT NULL 		
			AND LOWER(cm.strCommodityCode) <> LTRIM(RTRIM(LOWER(s.strCommodity)))
			AND dbo.fnAllowCommodityToChange(i.intItemId, i.intCommodityId) = 0
	END

	-- Get the duplicate records
	DECLARE @tblDuplicateItemNo TABLE(
		strItemNo NVARCHAR(200)
		,intId INT 
	)
	INSERT INTO @tblDuplicateItemNo (
		strItemNo
		,intId 
	)
	SELECT 
		strItemNo
		, intId 
	FROM
	(
		SELECT 
			*
			,RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strItemNo) 
			,intId = ROW_NUMBER() OVER(ORDER BY intImportStagingItemId)
		FROM 
			tblICImportStagingItem
		WHERE 
			strImportIdentifier = @strIdentifier
	) AS DuplicateCounter
	WHERE RowNumber > 1
END 
-------------------------------------------------------------------------
-- END Validate records
-------------------------------------------------------------------------

-- Delete the duplicate records. 
DELETE DuplicateCounter
FROM
(
	SELECT 
		*
		, ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strItemNo) AS RowNumber
	FROM 
		tblICImportStagingItem
	WHERE 
		strImportIdentifier = @strIdentifier
) DuplicateCounter
WHERE RowNumber > 1

CREATE TABLE #output (
	  strItemNoDeleted NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strItemNoInserted NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL)

-- Get the valid records
INSERT INTO #tmp_validRecords(
	  strItemNo
	, strType
	, strDescription
	, strStatus
	, intLifeTime
	, strShortName
	, strLotTracking
	, ysnLotWeightsRequired
	, ysnUseWeighScales
	, strBarcodePrint
	, intManufacturerId
	, intCommodityId
	, intBrandId
	, strModelNo
	, intCategoryId
	, ysnStockedItem
	, ysnDyedFuel
	, ysnMSDSRequired
	, strEPANumber
	, ysnInboundTax
	, ysnRestrictedChemical
	, ysnFuelItem
	, ysnListBundleSeparately
	, dblDenaturantPercent
	, ysnTonnageTax
	, ysnLoadTracking
	, dblMixOrder
	, ysnHandAddIngredient
	, ysnExtendPickTicket
	, ysnExportEDI
	, ysnHazardMaterial
	, ysnMaterialFee
	, ysnAutoBlend
	, dblUserGroupFee
	, dblWeightTolerance
	, dblOverReceiveTolerance
	, ysnLandedCost
	, strLeadTime
	, ysnTaxable
	, strKeywords
	, dblCaseQty
	, dtmDateShip
	, dblTaxExempt
	, ysnDropShip
	, ysnCommisionable
	, ysnSpecialCommission
	, ysnTankRequired
	, ysnAvailableTM
	, dblDefaultFull
	, dblMaintenanceRate
	, strNACSCategory
	, ysnReceiptCommentRequired
	, intPatronageCategoryDirectId
	, intPatronageCategoryId
	, intPhysicalItem
	, strVolumeRebateGroup
	, intIngredientTag
	, intMedicationTag
	, intRINFuelTypeId
	, strFuelInspectFee
	, ysnSeparateStockForUOMs
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  strItemNo						= s.strItemNo
	, strType						= COALESCE(invTypes.strType, 'Inventory')
	, strDescription				= ISNULL(s.strDescription, s.strItemNo)
	, strStatus						= COALESCE(statuses.strStatus, 'Active')
	, intLifeTime					= 1
	, strShortName					= s.strShortName
	, strLotTracking				= COALESCE(lotTrackTypes.strLotTracking, 'No')
	, ysnLotWeightsRequired			= s.ysnLotWeightsRequired
	, ysnUseWeighScales				= s.ysnUseWeighScales
	, strBarcodePrint				= s.strBarcodePrint
	, intManufacturerId				= m.intManufacturerId
	, intCommodityId				= cm.intCommodityId
	, intBrandId					= b.intBrandId
	, strModelNo					= s.strModelNo
	, intCategoryId					= c.intCategoryId
	, ysnStockedItem				= s.ysnStockedItem
	, ysnDyedFuel					= s.ysnDyedFuel
	, ysnMSDSRequired				= s.ysnMSDSRequired
	, strEPANumber					= s.strEPANumber
	, ysnInboundTax					= s.ysnInboundTax
	, ysnRestrictedChemical			= s.ysnRestrictedChemical
	, ysnFuelItem					= s.ysnFuelItem
	, ysnListBundleSeparately		= s.ysnListBundleItemsSeparately
	, dblDenaturantPercent			= s.dblDefaultPercentageFull
	, ysnTonnageTax					= s.ysnTonnageTax
	, ysnLoadTracking				= s.ysnLoadTracking
	, dblMixOrder					= s.dblMixOrder
	, ysnHandAddIngredient			= s.ysnHandAddIngredients
	, ysnExtendPickTicket			= s.ysnExtendPickTicket
	, ysnExportEDI					= s.ysnExportEDI
	, ysnHazardMaterial				= s.ysnHazardMaterial
	, ysnMaterialFee				= s.ysnMaterialFee
	, ysnAutoBlend					= s.ysnAutoBlend
	, dblUserGroupFee				= s.dblUserGroupFeePercentage
	, dblWeightTolerance			= s.dblWgtTolerancePercentage
	, dblOverReceiveTolerance		= s.dblOverReceiveTolerancePercentage
	, ysnLandedCost					= ISNULL(s.ysnLandedCost, 0)
	, strLeadTime					= s.strLeadTime
	, ysnTaxable					= ISNULL(s.ysnTaxable, 0)
	, strKeywords					= s.strKeywords
	, dblCaseQty					= s.dblCaseQty
	, dtmDateShip					= s.dtmDateShip
	, dblTaxExempt					= s.dblTaxExempt
	, ysnDropShip					= ISNULL(s.ysnDropShip, 0)
	, ysnCommisionable				= ISNULL(s.ysnCommissionable, 0)
	, ysnSpecialCommission			= ISNULL(s.ysnSpecialCommission, 0)
	, ysnTankRequired				= s.ysnTankRequired
	, ysnAvailableTM				= s.ysnAvailableforTM
	, dblDefaultFull				= s.dblDefaultPercentageFull
	, dblMaintenanceRate			= s.dblRate
	, strNACSCategory				= s.strNACSCategory
	, ysnReceiptCommentRequired		= s.ysnReceiptCommentReq
	, intPatronageCategoryDirectId	= ds.intPatronageCategoryId
	, intPatronageCategoryId		= p.intPatronageCategoryId
	, intPhysicalItem				= ph.intItemId
	, strVolumeRebateGroup			= s.strVolumeRebateGroup
	, intIngredientTag				= ing.intTagId
	, intMedicationTag				= med.intTagId
	, intRINFuelTypeId				= rin.intRinFuelCategoryId
	, strFuelInspectFee				= s.strFuelInspectFee
	, ysnSeparateStockForUOMs		= s.ysnSeparateStockForUOMs
	, dtmDateCreated				= s.dtmDateCreated
	, intCreatedByUserId			= s.intCreatedByUserId
FROM tblICImportStagingItem s
	OUTER APPLY (
		SElECT strType
		FROM (
			SELECT 'Bundle' strType UNION
			SELECT 'Inventory' strType UNION
			SELECT 'Non-Inventory' strType UNION
			SELECT 'Kit' strType UNION
			SELECT 'Finished Good' strType UNION
			SELECT 'Other Charge' strType UNION
			SELECT 'Raw Material' strType UNION
			SELECT 'Service' strType UNION
			SELECT 'Software' strType UNION
			SELECT 'Comment' strType
		) x WHERE LOWER(x.strType) = LTRIM(RTRIM(LOWER(ISNULL(s.strType, 'Inventory'))))
	) invTypes
	OUTER APPLY (
		SELECT strStatus
		FROM (
			SELECT 'Active' strStatus UNION
			SELECT 'Phased Out' strStatus UNION
			SELECT 'Discontinued' strStatus
		) x WHERE LOWER(x.strStatus) = LTRIM(RTRIM(LOWER(ISNULL(s.strStatus, 'Active'))))
	) statuses
	OUTER APPLY (
		SELECT strLotTracking
		FROM (
			SELECT 'No' strLotTracking UNION
			SELECT 'Yes - Manual' strLotTracking UNION
			SELECT 'Yes - Serial Number' strLotTracking UNION
			SELECT 'Yes - Manual/Serial Number' strLotTracking
		) x WHERE LOWER(x.strLotTracking) = RTRIM(LTRIM(LOWER(ISNULL(s.strLotTracking, 'No'))))
	) lotTrackTypes
	LEFT OUTER JOIN tblICManufacturer m ON LOWER(m.strManufacturer) = LTRIM(RTRIM(LOWER(s.strManufacturer)))
	LEFT OUTER JOIN tblICCategory c 
		ON LOWER(c.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strCategory)))
		--AND c.strInventoryType = invTypes.strType
	LEFT OUTER JOIN tblICCommodity cm ON LOWER(cm.strCommodityCode) = LTRIM(RTRIM(LOWER(s.strCommodity)))
	LEFT OUTER JOIN tblICBrand b ON LOWER(b.strBrandCode) = LTRIM(RTRIM(LOWER(s.strBrand)))
	LEFT OUTER JOIN tblPATPatronageCategory p ON LOWER(p.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strPatronageCategory)))
	LEFT OUTER JOIN tblPATPatronageCategory ds ON LOWER(ds.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strDirectSale)))
	LEFT OUTER JOIN tblICItem ph ON LOWER(ph.strItemNo) = LTRIM(RTRIM(LOWER(s.strPhysicalItem)))
	LEFT OUTER JOIN tblICTag med ON med.strTagNumber = s.strMedicationTag AND med.strType = 'Medication Tag'
	LEFT OUTER JOIN tblICTag ing ON ing.strTagNumber = s.strIngredientTag AND ing.strType = 'Ingredient Tag'
	LEFT OUTER JOIN tblICRinFuelCategory rin ON rin.strRinFuelCategoryCode = LTRIM(RTRIM(LOWER(s.strFuelCategory)))
	LEFT JOIN #tmp_lotTrackingChange v1 ON v1.strItemNo = s.strItemNo
	LEFT JOIN #tmp_itemTypeChange v2 ON v2.strItemNo = s.strItemNo
	LEFT JOIN #tmp_commodityChange v3 ON v3.strItemNo = s.strItemNo
WHERE 
	s.strImportIdentifier = @strIdentifier
	AND (
		v1.strItemNo IS NULL 
		AND v2.strItemNo IS NULL 
		AND v3.strItemNo IS NULL 
	)

;MERGE INTO tblICItem AS target
USING
(
	SELECT
		  strItemNo
		, strType
		, strDescription
		, strStatus
		, intLifeTime
		, strShortName
		, strLotTracking
		, ysnLotWeightsRequired
		, ysnUseWeighScales
		, strBarcodePrint
		, intManufacturerId
		, intCommodityId
		, intBrandId
		, strModelNo
		, intCategoryId
		, ysnStockedItem
		, ysnDyedFuel
		, ysnMSDSRequired
		, strEPANumber
		, ysnInboundTax
		, ysnRestrictedChemical
		, ysnFuelItem
		, ysnListBundleSeparately
		, dblDenaturantPercent
		, ysnTonnageTax
		, ysnLoadTracking
		, dblMixOrder
		, ysnHandAddIngredient
		, ysnExtendPickTicket
		, ysnExportEDI
		, ysnHazardMaterial
		, ysnMaterialFee
		, ysnAutoBlend
		, dblUserGroupFee
		, dblWeightTolerance
		, dblOverReceiveTolerance
		, ysnLandedCost
		, strLeadTime
		, ysnTaxable
		, strKeywords
		, dblCaseQty
		, dtmDateShip
		, dblTaxExempt
		, ysnDropShip
		, ysnCommisionable
		, ysnSpecialCommission
		, ysnTankRequired
		, ysnAvailableTM
		, dblDefaultFull
		, dblMaintenanceRate
		, strNACSCategory
		, ysnReceiptCommentRequired
		, intPatronageCategoryDirectId
		, intPatronageCategoryId
		, intPhysicalItem
		, strVolumeRebateGroup
		, intIngredientTag
		, intMedicationTag
		, intRINFuelTypeId
		, strFuelInspectFee
		, ysnSeparateStockForUOMs
		, dtmDateCreated
		, intCreatedByUserId
	FROM #tmp_validRecords s
) AS source 
	ON LTRIM(RTRIM(target.strItemNo)) = LTRIM(RTRIM(source.strItemNo))

WHEN MATCHED AND @ysnAllowOverwrite = 1 THEN
	UPDATE SET
		  strItemNo = source.strItemNo
		
		, strInventoryTracking = 
			CASE WHEN ISNULL(source.strLotTracking, 'No') = 'No' THEN 
				CASE WHEN source.strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END 
			ELSE 'Lot Level' END
		, strDescription = source.strDescription
		, strStatus = source.strStatus
		, intLifeTime = source.intLifeTime
		, strShortName = source.strShortName
		, ysnLotWeightsRequired = source.ysnLotWeightsRequired
		, ysnUseWeighScales = source.ysnUseWeighScales
		, strBarcodePrint = source.strBarcodePrint
		, intManufacturerId = source.intManufacturerId		
		, intBrandId = source.intBrandId
		, strModelNo = source.strModelNo
		, intCategoryId = source.intCategoryId
		, ysnStockedItem = source.ysnStockedItem
		, ysnDyedFuel = source.ysnDyedFuel
		, ysnMSDSRequired = source.ysnMSDSRequired
		, strEPANumber = source.strEPANumber
		, ysnInboundTax = source.ysnInboundTax
		, ysnRestrictedChemical = source.ysnRestrictedChemical
		, ysnFuelItem = source.ysnFuelItem
		, ysnListBundleSeparately = source.ysnListBundleSeparately
		, dblDenaturantPercent = source.dblDenaturantPercent
		, ysnTonnageTax = source.ysnTonnageTax
		, ysnLoadTracking = source.ysnLoadTracking
		, dblMixOrder = source.dblMixOrder
		, ysnHandAddIngredient = source.ysnHandAddIngredient
		, ysnExtendPickTicket = source.ysnExtendPickTicket
		, ysnExportEDI = source.ysnExportEDI
		, ysnHazardMaterial = source.ysnHazardMaterial
		, ysnMaterialFee = source.ysnMaterialFee
		, ysnAutoBlend = source.ysnAutoBlend
		, dblUserGroupFee = source.dblUserGroupFee
		, dblWeightTolerance = source.dblWeightTolerance
		, dblOverReceiveTolerance = source.dblOverReceiveTolerance
		, ysnLandedCost = source.ysnLandedCost
		, strLeadTime = source.strLeadTime
		, ysnTaxable = source.ysnTaxable
		, strKeywords = source.strKeywords
		, dblCaseQty = source.dblCaseQty
		, dtmDateShip = source.dtmDateShip
		, dblTaxExempt = source.dblTaxExempt
		, ysnDropShip = source.ysnDropShip
		, ysnCommisionable = source.ysnCommisionable
		, ysnSpecialCommission = source.ysnSpecialCommission
		, ysnTankRequired = source.ysnTankRequired
		, ysnAvailableTM = source.ysnAvailableTM
		, dblDefaultFull = source.dblDefaultFull
		, dblMaintenanceRate = source.dblMaintenanceRate
		, strNACSCategory = source.strNACSCategory
		, ysnReceiptCommentRequired = source.ysnReceiptCommentRequired
		, intPatronageCategoryDirectId = source.intPatronageCategoryDirectId
		, intPatronageCategoryId = source.intPatronageCategoryId
		, intPhysicalItem = source.intPhysicalItem
		, strVolumeRebateGroup = source.strVolumeRebateGroup
		, intIngredientTag = source.intIngredientTag
		, intMedicationTag = source.intMedicationTag
		, intRINFuelTypeId = source.intRINFuelTypeId
		, strFuelInspectFee = source.strFuelInspectFee
		, ysnSeparateStockForUOMs = source.ysnSeparateStockForUOMs
		, dtmDateModified = GETUTCDATE()
		, intModifiedByUserId = source.intCreatedByUserId
WHEN NOT MATCHED THEN
	INSERT
	(
		  strItemNo
		, strType
		, strInventoryTracking
		, strDescription
		, strStatus
		, intLifeTime
		, strShortName
		, strLotTracking
		, ysnLotWeightsRequired
		, ysnUseWeighScales
		, strBarcodePrint
		, intManufacturerId
		, intCommodityId
		, intBrandId
		, strModelNo
		, intCategoryId
		, ysnStockedItem
		, ysnDyedFuel
		, ysnMSDSRequired
		, strEPANumber
		, ysnInboundTax
		, ysnRestrictedChemical
		, ysnFuelItem
		, ysnListBundleSeparately
		, dblDenaturantPercent
		, ysnTonnageTax
		, ysnLoadTracking
		, dblMixOrder
		, ysnHandAddIngredient
		, ysnExtendPickTicket
		, ysnExportEDI
		, ysnHazardMaterial
		, ysnMaterialFee
		, ysnAutoBlend
		, dblUserGroupFee
		, dblWeightTolerance
		, dblOverReceiveTolerance
		, ysnLandedCost
		, strLeadTime
		, ysnTaxable
		, strKeywords
		, dblCaseQty
		, dtmDateShip
		, dblTaxExempt
		, ysnDropShip
		, ysnCommisionable
		, ysnSpecialCommission
		, ysnTankRequired
		, ysnAvailableTM
		, dblDefaultFull
		, dblMaintenanceRate
		, strNACSCategory
		, ysnReceiptCommentRequired
		, intPatronageCategoryDirectId
		, intPatronageCategoryId
		, intPhysicalItem
		, strVolumeRebateGroup
		, intIngredientTag
		, intMedicationTag
		, intRINFuelTypeId
		, strFuelInspectFee
		, ysnSeparateStockForUOMs
		, dtmDateCreated
		, intDataSourceId
	)
	VALUES
	(
		  strItemNo
		, strType
		, CASE WHEN ISNULL(strLotTracking, 'No') = 'No' THEN
				CASE WHEN strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END
			ELSE 'Lot Level' END
		, strDescription
		, strStatus
		, intLifeTime
		, strShortName
		, strLotTracking
		, ysnLotWeightsRequired
		, ysnUseWeighScales
		, strBarcodePrint
		, intManufacturerId
		, intCommodityId
		, intBrandId
		, strModelNo
		, intCategoryId
		, ysnStockedItem
		, ysnDyedFuel
		, ysnMSDSRequired
		, strEPANumber
		, ysnInboundTax
		, ysnRestrictedChemical
		, ysnFuelItem
		, ysnListBundleSeparately
		, dblDenaturantPercent
		, ysnTonnageTax
		, ysnLoadTracking
		, dblMixOrder
		, ysnHandAddIngredient
		, ysnExtendPickTicket
		, ysnExportEDI
		, ysnHazardMaterial
		, ysnMaterialFee
		, ysnAutoBlend
		, dblUserGroupFee
		, dblWeightTolerance
		, dblOverReceiveTolerance
		, ysnLandedCost
		, strLeadTime
		, ysnTaxable
		, strKeywords
		, dblCaseQty
		, dtmDateShip
		, dblTaxExempt
		, ysnDropShip
		, ysnCommisionable
		, ysnSpecialCommission
		, ysnTankRequired
		, ysnAvailableTM
		, dblDefaultFull
		, dblMaintenanceRate
		, strNACSCategory
		, ysnReceiptCommentRequired
		, intPatronageCategoryDirectId
		, intPatronageCategoryId
		, intPhysicalItem
		, strVolumeRebateGroup
		, intIngredientTag
		, intMedicationTag
		, intRINFuelTypeId
		, strFuelInspectFee
		, ysnSeparateStockForUOMs
		, dtmDateCreated
		, @intDataSourceId
	)
	OUTPUT deleted.strItemNo, $action, inserted.strItemNo INTO #output;

-- Logs 
BEGIN 
	DECLARE 
		@intRowsImported AS INT 
		,@intRowsUpdated AS INT
		,@intRowsSkipped AS INT
		,@intRowDuplicates AS INT

	SELECT @intRowsImported = COUNT(*) FROM #output WHERE strAction = 'INSERT'
	SELECT @intRowsUpdated = COUNT(*) FROM #output WHERE strAction = 'UPDATE'
	SELECT @intRowDuplicates = COUNT(*) FROM @tblDuplicateItemNo
	SELECT 
		@intRowsSkipped = ISNULL(@intRowDuplicates, 0) + (COUNT(1) - ISNULL(@intRowsImported, 0) - ISNULL(@intRowsUpdated, 0))
	FROM 
		tblICImportStagingItem s
	WHERE
		s.strImportIdentifier = @strIdentifier

	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@intRowsImported, 0)
		,intRowsUpdated = ISNULL(@intRowsUpdated, 0) 
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)


	IF @ysnVerboseLog = 1
	BEGIN 
		-- Validate Incompatible inventory types of items vs. categories
		INSERT INTO tblICImportLogDetailFromStaging(
			strUniqueId
			, intRecordNo
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@strIdentifier
			, intId
			, 'Lot Tracking'
			, 'Import Failed.'
			, strItemNo
			, 'Lot Tracking change is not allowed for item "' + strItemNo + '"'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_lotTrackingChange

		UNION ALL 
		SELECT 
			@strIdentifier
			, intId
			, 'Item Type'
			, 'Import Failed.'
			, strItemNo
			, 'Item Type change is not allowed for item "' + strItemNo + '"'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_itemTypeChange

		UNION ALL 
		SELECT 
			@strIdentifier
			, intId
			, 'Commodity'
			, 'Import Failed.'
			, strItemNo
			, 'Commodity change is not allowed for item "' + strItemNo + '"'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_commodityChange

		UNION ALL
		SELECT 
			@strIdentifier
			, intId
			, 'Item No'
			, 'Import Failed.'
			, strItemNo
			, 'Duplicate Item No "' + strItemNo + '"'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			@tblDuplicateItemNo
	END 
	ELSE 
	BEGIN 
		-- Validate Incompatible inventory types of items vs. categories
		INSERT INTO tblICImportLogDetailFromStaging(
			strUniqueId
			, intRecordNo
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@strIdentifier
			, 1
			, 'Lot Tracking'
			, 'Import Failed.'
			, NULL
			--, 'Lot Tracking change is not allowed for item "' + strItemNo + '"'
			, dbo.fnFormatMessage(
				'Lot Tracking change is not allowed for %i item(s).'
				,COUNT(1) 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_lotTrackingChange
		HAVING 
			COUNT(1) > 0

		UNION ALL 
		SELECT 
			@strIdentifier
			, 1
			, 'Item Type'
			, 'Import Failed.'
			, NULL
			--, 'Item Type change is not allowed for item "' + strItemNo + '"'
			, dbo.fnFormatMessage(
				'Item Type change is not allowed for %i item(s).'
				,COUNT(1) 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)

			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_itemTypeChange
		HAVING 
			COUNT(1) > 0

		UNION ALL 
		SELECT 
			@strIdentifier
			, 1
			, 'Commodity'
			, 'Import Failed.'
			, NULL
			--, 'Commodity change is not allowed for item "' + strItemNo + '"'
			, dbo.fnFormatMessage(
				'Commodity change is not allowed for %i item(s).'
				,COUNT(1) 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)

			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_commodityChange
		HAVING 
			COUNT(1) > 0

		UNION ALL
		SELECT 
			@strIdentifier
			, 1
			, 'Item No'
			, 'Import Failed.'
			, NULL
			--, 'Duplicate Item No "' + strItemNo + '"'
			, dbo.fnFormatMessage(
				'There are %i duplicate record(s) found.'
				,COUNT(1) 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			@tblDuplicateItemNo
		HAVING 
			COUNT(1) > 0
	END 
END

DROP TABLE #tmp_validRecords
DROP TABLE #output
DROP TABLE #tmp_lotTrackingChange 
DROP TABLE #tmp_itemTypeChange 
DROP TABLE #tmp_commodityChange 

DELETE FROM tblICImportStagingItem WHERE strImportIdentifier = @strIdentifier
