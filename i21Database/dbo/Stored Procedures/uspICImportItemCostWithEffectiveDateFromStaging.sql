CREATE PROCEDURE uspICImportItemCostWithEffectiveDateFromStaging 
	@strIdentifier NVARCHAR(100)
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemCostWithEffectiveDate WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, dtmEffectiveDate, dblCost ORDER BY strItemNo, strLocation, dtmEffectiveDate, dblCost) AS RowNumber
   FROM tblICImportStagingItemCostWithEffectiveDate
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intItemLocationId INT NULL
	, intCompanyLocationId INT NULL
	, dblCost NUMERIC(38, 20) NULL
	, dtmEffectiveDate DATETIME NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

INSERT INTO #tmp
(
	  intItemId				
	, intItemLocationId		
	, intCompanyLocationId
	, dblCost
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId	
)
SELECT
	  intItemId				 = i.intItemId
	, intItemLocationId		 = il.intItemLocationId
	, intCompanyLocationId	 = c.intCompanyLocationId
	, dblCost				 = s.dblCost 
	, dtmEffectiveDate		 = s.dtmEffectiveDate
	, dtmDateCreated		 = s.dtmDateCreated		
	, intCreatedByUserId	 = s.intCreatedByUserId	
FROM tblICImportStagingItemCostWithEffectiveDate s
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

;MERGE INTO tblICEffectiveItemCost AS target
USING
(
	SELECT
	  intItemId				
	, intItemLocationId	
	, intCompanyLocationId
	, dblCost 		
	, dtmEffectiveDate
	, dtmDateCreated		
	, intCreatedByUserId
	FROM #tmp s
) AS source 
	ON target.intItemId = source.intItemId
	AND target.intItemLocationId = source.intItemLocationId
	AND target.dtmEffectiveCostDate = source.dtmEffectiveDate
WHEN MATCHED THEN
	UPDATE SET
		  intItemId				 = source.intItemId
		, intItemLocationId		 = source.intItemLocationId
		, dblCost				 = source.dblCost
		, dtmEffectiveCostDate	 = source.dtmEffectiveDate
		, dtmDateModified		 = GETUTCDATE()
		, intModifiedByUserId    = source.intCreatedByUserId
		, intImportFlagInternal  = 1
WHEN NOT MATCHED THEN
	INSERT
	(
		  intItemId				
		, intItemLocationId		
		, dblCost		
		, dtmEffectiveCostDate
		, dtmDateCreated		
		, intCreatedByUserId
		, intDataSourceId
		, intImportFlagInternal
	)
	VALUES
	(
		intItemId				
		, intItemLocationId		
		, dblCost		
		, dtmEffectiveDate			
		, dtmDateCreated		
		, intCreatedByUserId
		, @intDataSourceId
		, 1
	)
	OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

--EXEC dbo.uspICUpdateItemImportedPricingLevel

-- Logs 
BEGIN 
	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
	)
	SELECT
		@strIdentifier
		,intRowsImported = (SELECT COUNT(*) FROM #output WHERE strAction = 'INSERT')
		,intRowsUpdated = (SELECT COUNT(*) FROM #output WHERE strAction = 'UPDATE')
END

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM [tblICImportStagingItemCostWithEffectiveDate] WHERE strImportIdentifier = @strIdentifier