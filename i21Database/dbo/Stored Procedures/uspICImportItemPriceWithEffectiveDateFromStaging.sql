CREATE PROCEDURE uspICImportItemPriceWithEffectiveDateFromStaging 
	@strIdentifier NVARCHAR(100)
	, @ysnAllowOverwrite BIT = 0
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemPriceWithEffectiveDate WHERE strImportIdentifier <> @strIdentifier

DECLARE @tblEffectiveItemPricingLogs TABLE(intImportStagingItemPriceWithEffectiveDateId INT, strColumnName NVARCHAR(200), strColumnValue NVARCHAR(200), strLogType NVARCHAR(200), strLogStatus NVARCHAR(200), strLogMessage NVARCHAR(MAX))

INSERT INTO @tblEffectiveItemPricingLogs 
(
	intImportStagingItemPriceWithEffectiveDateId,
	strColumnName,
	strColumnValue,
	strLogType,
	strLogStatus,
	strLogMessage
)
SELECT
	ItemPriceWithEffectiveDate.intImportStagingItemPriceWithEffectiveDateId,
	'Item No',
	ItemPriceWithEffectiveDate.strItemNo,
	'Warning',
	'Skipped',
	'Effectivity Date on imported records should not conflict on the same Item Location: ' + ItemPriceWithEffectiveDate.strLocation + '. '
FROM
(
	SELECT
		intImportStagingItemPriceWithEffectiveDateId,
		strItemNo,
		strLocation,
		strUnitMeasure,
		ROW_NUMBER() OVER (PARTITION BY strItemNo, strLocation, strUnitMeasure, dtmEffectiveDate
							ORDER BY intImportStagingItemPriceWithEffectiveDateId) AS RowNumber 
	FROM 
		tblICImportStagingItemPriceWithEffectiveDate 
) AS ItemPriceWithEffectiveDate
WHERE ItemPriceWithEffectiveDate.RowNumber > 1
UNION
SELECT
	ItemPriceWithEffectiveDate.intImportStagingItemPriceWithEffectiveDateId,
	'Item No',
	ItemPriceWithEffectiveDate.strItemNo,
	'Warning',
	'Skipped',
	'Effectivity Date on imported and existing records should not conflict on the same Item Location: ' + ItemPriceWithEffectiveDate.strLocation + ' when overwrite is disabled. '
FROM 
	tblICImportStagingItemPriceWithEffectiveDate ItemPriceWithEffectiveDate
INNER JOIN
	vyuICGetEffectiveItemPrice EffectiveItemPrice
	ON
		EffectiveItemPrice.strItemNo = ItemPriceWithEffectiveDate.strItemNo
		AND
		EffectiveItemPrice.strLocationName = ItemPriceWithEffectiveDate.strLocation
		AND
		EffectiveItemPrice.strUnitMeasure = ItemPriceWithEffectiveDate.strUnitMeasure
		AND
		EffectiveItemPrice.dtmEffectiveRetailPriceDate = ItemPriceWithEffectiveDate.dtmEffectiveDate
		AND
		@ysnAllowOverwrite = 0

UNION
SELECT
	ItemPriceWithEffectiveDate.intImportStagingItemPriceWithEffectiveDateId,
	'Item No',
	ItemPriceWithEffectiveDate.strItemNo,
	'Error',
	'Failed',
	'Invalid Item: ' + ItemPriceWithEffectiveDate.strItemNo + ' imported.'
FROM
	tblICImportStagingItemPriceWithEffectiveDate ItemPriceWithEffectiveDate
LEFT JOIN
	tblICItem Item
	ON
		Item.strItemNo = ItemPriceWithEffectiveDate.strItemNo
WHERE
	Item.intItemId IS NULL
UNION
SELECT
	ItemPriceWithEffectiveDate.intImportStagingItemPriceWithEffectiveDateId,
	'Location',
	ItemPriceWithEffectiveDate.strLocation,
	'Error',
	'Failed',
	'Invalid Location: ' + ItemPriceWithEffectiveDate.strLocation + ' on Item: ' + ItemPriceWithEffectiveDate.strItemNo + ' imported.'
FROM
	tblICImportStagingItemPriceWithEffectiveDate ItemPriceWithEffectiveDate
LEFT JOIN
	vyuICGetItemLocation ItemLocation
	ON
		ItemLocation.strItemNo = ItemPriceWithEffectiveDate.strItemNo
		AND
		ItemLocation.strLocationName = ItemPriceWithEffectiveDate.strLocation
WHERE
	ItemLocation.intItemLocationId IS NULL
UNION
SELECT
	ItemPriceWithEffectiveDate.intImportStagingItemPriceWithEffectiveDateId,
	'UOM',
	ItemPriceWithEffectiveDate.strUnitMeasure,
	'Error',
	'Failed',
	'Invalid Unit of Measure: ' + ItemPriceWithEffectiveDate.strUnitMeasure + ' on Item: ' + ItemPriceWithEffectiveDate.strItemNo + ' imported.'
FROM
	tblICImportStagingItemPriceWithEffectiveDate ItemPriceWithEffectiveDate
LEFT JOIN
	vyuICItemUOM ItemUOM
	ON
		ItemUOM.strItemNo = ItemPriceWithEffectiveDate.strItemNo
		AND
		ItemUOM.strUnitMeasure = ItemPriceWithEffectiveDate.strUnitMeasure
WHERE
	ItemUOM.intItemUOMId IS NULL

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intItemLocationId INT NULL
	, intItemUOMId INT NULL
	, intCompanyLocationId INT NULL
	, dblPrice NUMERIC(38, 20) NULL
	, dtmEffectiveDate DATETIME NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

INSERT INTO #tmp
(
	  intItemId				
	, intItemLocationId	
	, intItemUOMId	
	, intCompanyLocationId
	, dblPrice
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId	
)
SELECT
	  intItemId				 = i.intItemId
	, intItemLocationId		 = il.intItemLocationId
	, intItemUOMId			 = iu.intItemUOMId
	, intCompanyLocationId	 = c.intCompanyLocationId
	, dblPrice				 = s.dblPrice 
	, dtmEffectiveDate		 = s.dtmEffectiveDate
	, dtmDateCreated		 = s.dtmDateCreated		
	, intCreatedByUserId	 = s.intCreatedByUserId	
FROM tblICImportStagingItemPriceWithEffectiveDate s
	INNER JOIN tblICItem i ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo))) 
	INNER JOIN tblSMCompanyLocation c ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))
	INNER JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
		AND il.intItemId = i.intItemId
	INNER JOIN vyuICGetItemUOM iu ON i.intItemId = iu.intItemId AND LOWER(iu.strUnitMeasure) = LTRIM(RTRIM(LOWER(s.strUnitMeasure)))
	LEFT JOIN @tblEffectiveItemPricingLogs logs ON s.intImportStagingItemPriceWithEffectiveDateId = logs.intImportStagingItemPriceWithEffectiveDateId
WHERE 
	s.strImportIdentifier = @strIdentifier
	AND
	logs.strLogStatus NOT IN ('Failed', 'Skipped')
	OR
	logs.strLogStatus IS NULL

DECLARE @tblOutput TABLE(strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL)

;MERGE INTO tblICEffectiveItemPrice AS target
USING
(
	SELECT
	  intItemId				
	, intItemLocationId
	, intItemUOMId	
	, intCompanyLocationId
	, dblPrice 		
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId
	FROM #tmp s
) AS source 
	ON target.intItemId = source.intItemId
	AND target.intItemLocationId = source.intItemLocationId
	AND target.intItemUOMId = source.intItemUOMId
	AND target.dtmEffectiveRetailPriceDate = source.dtmEffectiveDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 THEN
	UPDATE SET
		  intItemId				 = source.intItemId
		, intItemLocationId		 = source.intItemLocationId
		, intItemUOMId			 = source.intItemUOMId
		, dblRetailPrice				 = source.dblPrice
		, dtmEffectiveRetailPriceDate	 = source.dtmEffectiveDate
		, dtmDateModified		 = GETUTCDATE()
		, intModifiedByUserId    = source.intCreatedByUserId
		, intImportFlagInternal  = 1
WHEN NOT MATCHED THEN
	INSERT
	(
		  intItemId				
		, intItemLocationId	
		, intItemUOMId	
		, dblRetailPrice		
		, dtmEffectiveRetailPriceDate
		, dtmDateCreated		
		, intCreatedByUserId
		, intDataSourceId
		, intImportFlagInternal
	)
	VALUES
	(
		intItemId				
		, intItemLocationId	
		, intItemUOMId	
		, dblPrice		
		, dtmEffectiveDate			
		, dtmDateCreated		
		, intCreatedByUserId
		, @intDataSourceId
		, 1
	)
	OUTPUT $action INTO @tblOutput;

--EXEC dbo.uspICUpdateItemImportedPricingLevel

-- Logs 
BEGIN 

	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
		,[intTotalWarnings]
		,[intTotalErrors]
	)
	SELECT
		@strIdentifier,
		intRowsImported = (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'INSERT'),
		intRowsUpdated = (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'UPDATE'),
		intRowsSkipped = (SELECT COUNT(*) - (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'INSERT') - 
			(SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'UPDATE') 
			FROM tblICImportStagingItemPriceWithEffectiveDate WHERE strImportIdentifier = @strIdentifier),
		intTotalWarnings = (SELECT COUNT(*) FROM @tblEffectiveItemPricingLogs WHERE strLogType = 'Warning'),
		intTotalErrors = (SELECT COUNT(*) FROM @tblEffectiveItemPricingLogs WHERE strLogType = 'Error')

	INSERT INTO tblICImportLogDetailFromStaging(
		strUniqueId,
		strField,
		strAction,
		strValue,
		strMessage,
		strStatus,
		strType,
		intConcurrencyId
	)
	SELECT 
		@strIdentifier,
		strColumnName,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Import Failed.'
			ELSE 'Import Skipped'
		END,
		strColumnValue,
		strLogMessage,
		strLogStatus,
		strLogType,
		1
	FROM 
		@tblEffectiveItemPricingLogs
END

DROP TABLE #tmp

DELETE FROM [tblICImportStagingItemPriceWithEffectiveDate] WHERE strImportIdentifier = @strIdentifier