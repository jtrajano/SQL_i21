CREATE PROCEDURE uspICImportCategoryLocationsFromStaging 
	@strIdentifier NVARCHAR(100)
	, @ysnAllowOverwrite BIT = 0
	--, @intDataSourceId INT = 2
	, @ysnImportResultFailed BIT = 0 OUTPUT 
AS

DELETE FROM tblICImportStagingCategoryLocation WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strCategory, strLocationName ORDER BY strCategory, strLocationName) AS RowNumber
   FROM tblICImportStagingCategoryLocation
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

CREATE TABLE #tmp (
	intId INT IDENTITY(1, 1) PRIMARY KEY,
	[intCategoryId] INT,
	[intLocationId] INT,
	[intCashRegisterDepartment] INT NULL,
	[strCashRegisterDepartment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnUpdatePrices] BIT NULL DEFAULT ((0)),
	[ysnUseTaxFlag1] BIT NULL DEFAULT ((0)),
	[ysnUseTaxFlag2] BIT NULL DEFAULT ((0)),
	[ysnUseTaxFlag3] BIT NULL DEFAULT ((0)),
	[ysnUseTaxFlag4] BIT NULL DEFAULT ((0)),
	[ysnBlueLaw1] BIT NULL DEFAULT ((0)),
	[ysnBlueLaw2] BIT NULL DEFAULT ((0)),
	[intNucleusGroupId] INT NULL,
	[dblTargetGrossProfit] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblTargetInventoryCost] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblCostInventoryBOM] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[dblLowGrossMarginAlert] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblHighGrossMarginAlert] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dtmLastInventoryLevelEntry] DATETIME NULL,
	[ysnNonRetailUseDepartment] BIT NULL DEFAULT ((0)),
	[ysnReportNetGross] BIT NULL DEFAULT ((0)),
	[ysnDepartmentForPumps] BIT NULL DEFAULT ((0)),
	[ysnDeleteFromRegister] BIT NULL DEFAULT ((0)),
	[ysnDeptKeyTaxed] BIT NULL DEFAULT ((0)),
	[intProductCodeId] INT NULL,
	[intFamilyId] INT NULL,
	[intClassId] INT NULL,
	[ysnFoodStampable] BIT NULL DEFAULT ((0)),
	[ysnReturnable] BIT NULL DEFAULT ((0)),
	[ysnSaleable] BIT NULL DEFAULT ((0)),
	[ysnPrePriced] BIT NULL DEFAULT ((0)),
	[ysnIdRequiredLiquor] BIT NULL DEFAULT ((0)),
	[ysnIdRequiredCigarette] BIT NULL DEFAULT ((0)),
	[intMinimumAge] INT NULL DEFAULT ((0)),
	[intGeneralItemId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL
)

INSERT INTO #tmp (
	  intCategoryId
	, intLocationId
	, intCashRegisterDepartment
	, strCashRegisterDepartment
	, ysnUpdatePrices
	, ysnUseTaxFlag1
	, ysnUseTaxFlag2
	, ysnUseTaxFlag3
	, ysnUseTaxFlag4
	, ysnBlueLaw1
	, ysnBlueLaw2
	, intNucleusGroupId
	, dblTargetGrossProfit
	, dblTargetInventoryCost
	, dblCostInventoryBOM
	, dblLowGrossMarginAlert
	, dblHighGrossMarginAlert
	, dtmLastInventoryLevelEntry
	, ysnNonRetailUseDepartment
	, ysnReportNetGross
	, ysnDepartmentForPumps
	, ysnDeleteFromRegister
	, ysnDeptKeyTaxed
	, intProductCodeId
	, intFamilyId
	, intClassId
	, ysnFoodStampable
	, ysnReturnable
	, ysnSaleable
	, ysnPrePriced
	, ysnIdRequiredLiquor
	, ysnIdRequiredCigarette
	, intMinimumAge
	, intGeneralItemId
	, intConcurrencyId
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  c.intCategoryId
	, l.intCompanyLocationId
	, x.intCashRegisterDepartment
	, x.strCashRegisterDepartment
	, ISNULL(x.ysnUpdatePrices, 0)
	, x.ysnUseTaxFlag1
	, x.ysnUseTaxFlag2
	, x.ysnUseTaxFlag3
	, x.ysnUseTaxFlag4
	, x.ysnBlueLaw1
	, x.ysnBlueLaw2
	, x.intNucleusGroupId
	, x.dblTargetGrossProfit
	, x.dblTargetInventoryCost
	, x.dblCostInventoryBOM
	, x.dblLowGrossMarginAlert
	, x.dblHighGrossMarginAlert
	, x.dtmLastInventoryLevelEntry
	, x.ysnNonRetailUseDepartment
	, x.ysnReportNetGross
	, x.ysnDepartmentForPumps
	, x.ysnDeleteFromRegister
	, x.ysnDeptKeyTaxed
	, p.intRegProdId
	, f.intSubcategoryId
	, sc.intSubcategoryId
	, x.ysnFoodStampable
	, x.ysnReturnable
	, x.ysnSaleable
	, x.ysnPrePriced
	, x.ysnIdRequiredLiquor
	, x.ysnIdRequiredCigarette
	, x.intMinimumAge
	, i.intItemId
	, x.intConcurrencyId
	, x.dtmDateCreated
	, x.intCreatedByUserId
FROM tblICImportStagingCategoryLocation x
	INNER JOIN tblICCategory c ON LOWER(c.strCategoryCode) = LOWER(LTRIM(RTRIM(x.strCategory)))
		OR LOWER(c.strDescription) = LOWER(LTRIM(RTRIM(x.strCategory)))
	--INNER JOIN tblSMCompanyLocation l ON LOWER(l.strLocationName) = LOWER(LTRIM(RTRIM(x.strLocation)))
	INNER JOIN vyuSMGetCompanyLocationSearchList l 
		ON LOWER(l.strLocationName) = LOWER(LTRIM(RTRIM(x.strLocationName)))
		--OR LOWER(l.strLocationNumber) = LOWER(LTRIM(RTRIM(x.strLocationName)))
		--OR LOWER(l.strCode) = LOWER(LTRIM(RTRIM(x.strLocation)))
	LEFT OUTER JOIN tblSTSubcategoryRegProd p ON LOWER(p.strRegProdCode) = LOWER(LTRIM(RTRIM(x.strProductCode)))
		OR LOWER(p.strRegProdDesc) = LOWER(LTRIM(RTRIM(x.strProductCode)))
	LEFT OUTER JOIN tblSTSubcategory f ON (LOWER(f.strSubcategoryId) = LOWER(LTRIM(RTRIM(x.strFamily)))
		OR LOWER(f.strSubcategoryDesc) = LOWER(LTRIM(RTRIM(x.strFamily))))
		AND f.strSubcategoryType= 'F'
	LEFT OUTER JOIN tblSTSubcategory sc ON (LOWER(sc.strSubcategoryId) = LOWER(LTRIM(RTRIM(x.strClass)))
		OR LOWER(sc.strSubcategoryDesc) = LOWER(LTRIM(RTRIM(x.strClass))))
		AND sc.strSubcategoryType = 'C'
	LEFT OUTER JOIN tblICItem i ON (LOWER(i.strItemNo) = LOWER(LTRIM(RTRIM(x.strGeneralItemNo)))
		OR LOWER(i.strDescription) = LOWER(LTRIM(RTRIM(x.strGeneralItemNo))))
		AND i.intCategoryId = c.intCategoryId
WHERE x.strImportIdentifier = @strIdentifier

CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL)

;MERGE INTO tblICCategoryLocation AS target
USING
(
	SELECT
		  intCategoryId
		, intLocationId
		, intCashRegisterDepartment
		, strCashRegisterDepartment
		, ysnUpdatePrices
		, ysnUseTaxFlag1
		, ysnUseTaxFlag2
		, ysnUseTaxFlag3
		, ysnUseTaxFlag4
		, ysnBlueLaw1
		, ysnBlueLaw2
		, intNucleusGroupId
		, dblTargetGrossProfit
		, dblTargetInventoryCost
		, dblCostInventoryBOM
		, dblLowGrossMarginAlert
		, dblHighGrossMarginAlert
		, dtmLastInventoryLevelEntry
		, ysnNonRetailUseDepartment
		, ysnReportNetGross
		, ysnDepartmentForPumps
		, ysnDeleteFromRegister
		, ysnDeptKeyTaxed
		, intProductCodeId
		, intFamilyId
		, intClassId
		, ysnFoodStampable
		, ysnReturnable
		, ysnSaleable
		, ysnPrePriced
		, ysnIdRequiredLiquor
		, ysnIdRequiredCigarette
		, intMinimumAge
		, intGeneralItemId
		, dtmDateCreated
		, intCreatedByUserId
	FROM #tmp s
) AS source ON (target.intCategoryId = source.intCategoryId AND target.intLocationId = source.intLocationId)
WHEN MATCHED AND @ysnAllowOverwrite = 1 THEN
	UPDATE SET 
		intCategoryId = source.intCategoryId,
		intLocationId = source.intLocationId,
		intRegisterDepartmentId = source.intCashRegisterDepartment,
		strCashRegisterDepartment = source.strCashRegisterDepartment,
		ysnUpdatePrices = source.ysnUpdatePrices,
		ysnUseTaxFlag1 = source.ysnUseTaxFlag1,
		ysnUseTaxFlag2 = source.ysnUseTaxFlag2,
		ysnUseTaxFlag3 = source.ysnUseTaxFlag3,
		ysnUseTaxFlag4 = source.ysnUseTaxFlag4,
		ysnBlueLaw1 = source.ysnBlueLaw1,
		ysnBlueLaw2 = source.ysnBlueLaw2,
		intNucleusGroupId = source.intNucleusGroupId,
		dblTargetGrossProfit = source.dblTargetGrossProfit,
		dblTargetInventoryCost = source.dblTargetInventoryCost,
		dblCostInventoryBOM = source.dblCostInventoryBOM,
		dblLowGrossMarginAlert = source.dblLowGrossMarginAlert,
		dblHighGrossMarginAlert = source.dblHighGrossMarginAlert,
		dtmLastInventoryLevelEntry = source.dtmLastInventoryLevelEntry,
		ysnNonRetailUseDepartment = source.ysnNonRetailUseDepartment,
		ysnReportNetGross = source.ysnReportNetGross,
		ysnDepartmentForPumps = source.ysnDepartmentForPumps,
		ysnDeleteFromRegister = source.ysnDeleteFromRegister,
		ysnDeptKeyTaxed = source.ysnDeptKeyTaxed,
		intProductCodeId = source.intProductCodeId,
		intFamilyId = source.intFamilyId,
		intClassId = source.intClassId,
		ysnFoodStampable = source.ysnFoodStampable,
		ysnReturnable = source.ysnReturnable,
		ysnSaleable = source.ysnSaleable,
		ysnPrePriced = source.ysnPrePriced,
		ysnIdRequiredLiquor = source.ysnIdRequiredLiquor,
		ysnIdRequiredCigarette = source.ysnIdRequiredCigarette,
		intMinimumAge = source.intMinimumAge,
		intGeneralItemId = source.intGeneralItemId,
		dtmDateCreated = source.dtmDateCreated,
		dtmDateModified = GETUTCDATE(),
		intModifiedByUserId = source.intCreatedByUserId,
		intCreatedByUserId = source.intCreatedByUserId
WHEN NOT MATCHED THEN
	INSERT
	(
		  intCategoryId
		, intLocationId
		, intRegisterDepartmentId
		, strCashRegisterDepartment
		, ysnUpdatePrices
		, ysnUseTaxFlag1
		, ysnUseTaxFlag2
		, ysnUseTaxFlag3
		, ysnUseTaxFlag4
		, ysnBlueLaw1
		, ysnBlueLaw2
		, intNucleusGroupId
		, dblTargetGrossProfit
		, dblTargetInventoryCost
		, dblCostInventoryBOM
		, dblLowGrossMarginAlert
		, dblHighGrossMarginAlert
		, dtmLastInventoryLevelEntry
		, ysnNonRetailUseDepartment
		, ysnReportNetGross
		, ysnDepartmentForPumps
		, ysnDeleteFromRegister
		, ysnDeptKeyTaxed
		, intProductCodeId
		, intFamilyId
		, intClassId
		, ysnFoodStampable
		, ysnReturnable
		, ysnSaleable
		, ysnPrePriced
		, ysnIdRequiredLiquor
		, ysnIdRequiredCigarette
		, intMinimumAge
		, intGeneralItemId
		, dtmDateCreated
		, intCreatedByUserId
	)
	VALUES
	(
		  intCategoryId
		, intLocationId
		, intCashRegisterDepartment
		, strCashRegisterDepartment
		, ysnUpdatePrices
		, ysnUseTaxFlag1
		, ysnUseTaxFlag2
		, ysnUseTaxFlag3
		, ysnUseTaxFlag4
		, ysnBlueLaw1
		, ysnBlueLaw2
		, intNucleusGroupId
		, dblTargetGrossProfit
		, dblTargetInventoryCost
		, dblCostInventoryBOM
		, dblLowGrossMarginAlert
		, dblHighGrossMarginAlert
		, dtmLastInventoryLevelEntry
		, ysnNonRetailUseDepartment
		, ysnReportNetGross
		, ysnDepartmentForPumps
		, ysnDeleteFromRegister
		, ysnDeptKeyTaxed
		, intProductCodeId
		, intFamilyId
		, intClassId
		, ysnFoodStampable
		, ysnReturnable
		, ysnSaleable
		, ysnPrePriced
		, ysnIdRequiredLiquor
		, ysnIdRequiredCigarette
		, intMinimumAge
		, intGeneralItemId
		, dtmDateCreated
		, intCreatedByUserId
	)
	OUTPUT deleted.intCategoryId, $action, inserted.intCategoryId INTO #output;

-- Logs
BEGIN 
	DECLARE 
		@intRowsImported AS INT 
		,@intRowsUpdated AS INT
		,@intRowsSkipped AS INT

	SELECT @intRowsImported = COUNT(*) FROM #output WHERE strAction = 'INSERT'
	SELECT @intRowsUpdated = COUNT(*) FROM #output WHERE strAction = 'UPDATE'

	SELECT 
		@intRowsSkipped = COUNT(1) - ISNULL(@intRowsImported, 0) - ISNULL(@intRowsUpdated, 0) 
	FROM 
		tblICImportStagingCategoryLocation s
	WHERE
		s.strImportIdentifier = @strIdentifier

	DECLARE @isExisting AS INT 
		,@intImportLogId AS INT 

	SELECT @intImportLogId = intImportLogId
	FROM tblICImportLog l
	WHERE l.strUniqueId = @strIdentifier

	UPDATE l
	SET 
		l.intRowsImported = ISNULL(@intRowsImported, 0)
		,l.intRowsUpdated = ISNULL(@intRowsUpdated, 0) 
		,l.intRowsSkipped = ISNULL(@intRowsSkipped, 0)
		,@intImportLogId = l.intImportLogId
	FROM tblICImportLog l
	WHERE
		l.intImportLogId = @intImportLogId

	IF @intImportLogId IS NOT NULL 
	BEGIN 
		-- Log Detail for missing location
		INSERT INTO tblICImportLogDetail(
			intImportLogId
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@intImportLogId
			, 'Location Name.'
			, 'Import Failed.'
			, x.strLocationName
			, dbo.fnFormatMessage(
				'Unable to find company location %s for category %s.'
				,x.strLocationName
				,x.strCategory
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
			tblICImportStagingCategoryLocation x
			INNER JOIN tblICCategory c ON LOWER(c.strCategoryCode) = LOWER(LTRIM(RTRIM(x.strCategory)))
				OR LOWER(c.strDescription) = LOWER(LTRIM(RTRIM(x.strCategory)))
			LEFT JOIN vyuSMGetCompanyLocationSearchList l 
				ON LOWER(l.strLocationName) = LOWER(LTRIM(RTRIM(x.strLocationName)))
		WHERE
			l.intCompanyLocationId IS NULL 

		-- Log Detail for missing category
		INSERT INTO tblICImportLogDetail(
			intImportLogId
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@intImportLogId
			, 'Category.'
			, 'Import Failed.'
			, x.strCategory
			, 'Unable to find the category'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			tblICImportStagingCategoryLocation x
			LEFT JOIN tblICCategory c 
				ON LOWER(c.strCategoryCode) = LOWER(LTRIM(RTRIM(x.strCategory)))
				OR LOWER(c.strDescription) = LOWER(LTRIM(RTRIM(x.strCategory)))
		WHERE
			c.intCategoryId IS NULL 
	END

	SET @ysnImportResultFailed = 0 
	IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail WHERE intImportLogId = @intImportLogId AND strStatus <> 'Success')
	BEGIN
		DECLARE @intErrors AS INT 
		SELECT	@intErrors = COUNT(1) 
		FROM	tblICImportLogDetail 
		WHERE	intImportLogId = @intImportLogId
				AND strStatus <> 'Success'

		UPDATE tblICImportLog
		SET strDescription = 'Import Failed'
			,intTotalErrors = @intErrors
		WHERE intImportLogId = @intImportLogId

		SET @ysnImportResultFailed = 1
	END 
END 

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM tblICImportStagingCategoryLocation WHERE strImportIdentifier = @strIdentifier
