CREATE PROCEDURE uspICImportItemVendorXrefFromStaging @strIdentifier NVARCHAR(100), @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemVendorXref WHERE strImportIdentifier <> @strIdentifier

CREATE TABLE #tmp (
	intId INT IDENTITY(1, 1) PRIMARY KEY,
	[intItemId] INT,
	[intItemLocationId] INT NULL,
	[intVendorId] INT,
	[intVendorSetupId] INT NULL,
	[strVendorProduct] NVARCHAR NULL,
	[strProductDescription] NVARCHAR NULL,
	[dblConversionFactor] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[intItemUnitMeasureId] INT NULL,
	[intSort] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL
)

INSERT INTO #tmp (
	intItemId,
	intItemLocationId,
	intVendorId,
	intVendorSetupId,
	strVendorProduct,
	strProductDescription,
	dblConversionFactor,
	intItemUnitMeasureId,
	intSort,
	intConcurrencyId,
	dtmDateCreated,
	intCreatedByUserId
)
SELECT
	Item.intItemId,
	ItemLocation.intItemLocationId,
	Vendor.intEntityId,
	NULL,
	Staging.strVendorProduct,
	Staging.strProductDescription,
	Staging.dblConversionFactor,
	ItemUOM.intItemUOMId,
	NULL,
	Staging.intConcurrencyId,
	Staging.dtmDateCreated,
	Staging.intCreatedByUserId
FROM tblICImportStagingItemVendorXref Staging
	INNER JOIN vyuAPVendor Vendor ON Vendor.strName = Staging.strVendor
	INNER JOIN tblICItem Item ON Item.strItemNo = Staging.strItemNo
	INNER JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.strLocationName = Staging.strLocation AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN 
	(tblICUnitMeasure UOM INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId) 
	ON UOM.strUnitMeasure = Staging.strUnitOfMeasure
WHERE Staging.strImportIdentifier = @strIdentifier

CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL)

;MERGE INTO tblICItemVendorXref AS target
USING
(
	SELECT
		intItemId, 
		intItemLocationId, 
		intVendorId, 
		intVendorSetupId, 
		strVendorProduct, 
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		intSort,
		intConcurrencyId,
		dtmDateCreated,
		dtmDateModified,
		intCreatedByUserId,
		intModifiedByUserId,
		intDataSourceId
	FROM #tmp s
) AS source ON (target.intItemVendorXrefId = source.intImportStagingItemVendorXrefId AND target.intItemId = source.intItemId AND target.intVendorId = source.intVendorId)
WHEN MATCHED THEN
	UPDATE SET 
		intItemId = source.intItemId,
		intItemLocationId = source.intItemLocationId,
		intVendorId = source.intVendorId,
		intVendorSetupId = source.intVendorSetupId,
		strVendorProduct = source.strVendorProduct,
		strProductDescription = source.strProductDescription,
		dblConversionFactor = source.dblConversionFactor,
		intItemUnitMeasureId = source.intItemUnitMeasureId,
		intSort = source.intSort,
		intConcurrencyId = source.intConcurrencyId,
		dtmDateCreated = source.dtmDateCreated,
		dtmDateModified = GETUTCDATE(),
		intCreatedByUserId = source.intCreatedByUserId,
		intModifiedByUserId = source.intCreatedByUserId,
		intDataSourceId = source.intDataSourceId
WHEN NOT MATCHED THEN
	INSERT
	(
		intItemId, 
		intItemLocationId, 
		intVendorId, 
		intVendorSetupId, 
		strVendorProduct, 
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		intSort,
		intConcurrencyId,
		dtmDateCreated,
		intCreatedByUserId,
		intDataSourceId
	)
	VALUES
	(
		intItemId, 
		intItemLocationId, 
		intVendorId, 
		intVendorSetupId, 
		strVendorProduct, 
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		intSort,
		intConcurrencyId,
		dtmDateCreated,
		intCreatedByUserId,
		intDataSourceId
	)
	OUTPUT deleted.intCategoryId, $action, inserted.intCategoryId INTO #output;

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

DELETE FROM tblICImportStagingItemVendorXref WHERE strImportIdentifier = @strIdentifier