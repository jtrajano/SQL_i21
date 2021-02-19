CREATE PROCEDURE uspICImportItemPriceWithEffectiveDateFromStaging 
	@strIdentifier NVARCHAR(100)
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemPriceWithEffectiveDate WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, dtmEffectiveDate, dblPrice ORDER BY strItemNo, strLocation, dtmEffectiveDate, dblPrice) AS RowNumber
   FROM tblICImportStagingItemPriceWithEffectiveDate
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intItemLocationId INT NULL
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
	, intCompanyLocationId
	, dblPrice
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId	
)
SELECT
	  intItemId				 = i.intItemId
	, intItemLocationId		 = il.intItemLocationId
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
WHERE s.strImportIdentifier = @strIdentifier

CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL
)

;MERGE INTO tblICEffectiveItemPrice AS target
USING
(
	SELECT
	  intItemId				
	, intItemLocationId	
	, intCompanyLocationId
	, dblPrice 		
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId
	FROM #tmp s
) AS source 
	ON target.intItemId = source.intItemId
	AND target.intItemLocationId = source.intItemLocationId
	AND target.dtmEffectiveRetailPriceDate = source.dtmEffectiveDate
WHEN MATCHED THEN
	UPDATE SET
		  intItemId				 = source.intItemId
		, intItemLocationId		 = source.intItemLocationId
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
		, dblPrice		
		, dtmEffectiveDate			
		, dtmDateCreated		
		, intCreatedByUserId
		, @intDataSourceId
		, 1
	)
	OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

--EXEC dbo.uspICUpdateItemImportedPricingLevel

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

---- Sync Pricing to Location to make sure all locations have corresponding price
--DECLARE @intItemId INT
--DECLARE @intUserId INT
--DECLARE cur CURSOR FOR
--SELECT DISTINCT intItemId, intCreatedByUserId FROM #tmp

--OPEN cur

--FETCH NEXT FROM cur INTO @intItemId, @intUserId

--WHILE @@FETCH_STATUS = 0
--BEGIN
--	EXEC dbo.uspICSyncItemLocationPricing @intItemId = @intItemId, @intUserId = @intUserId
--	FETCH NEXT FROM cur INTO @intItemId, @intUserId
--END

--CLOSE cur
--DEALLOCATE cur

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM [tblICImportStagingItemPriceWithEffectiveDate] WHERE strImportIdentifier = @strIdentifier