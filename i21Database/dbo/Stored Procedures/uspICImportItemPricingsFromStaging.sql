CREATE PROCEDURE uspICImportItemPricingsFromStaging 
	@strIdentifier NVARCHAR(100)
	, @ysnAllowOverwrite BIT = 0
	, @ysnVerboseLog BIT = 1
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingItemPricing WHERE strImportIdentifier <> @strIdentifier

CREATE TABLE #tmpItemPricing (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intItemLocationId INT NULL
	, intCompanyLocationId INT NULL
	, dblAmountPercent NUMERIC(38, 20) NULL
	, dblSalePrice NUMERIC(38, 20) NULL
	, dblMSRPPrice NUMERIC(38, 20) NULL
	, strPricingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, dblLastCost NUMERIC(38, 20) NULL
	, dblStandardCost NUMERIC(38, 20) NULL
	, dblAverageCost NUMERIC(38, 20) NULL
	, dblDefaultGrossPrice NUMERIC(38, 20) NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

CREATE TABLE #tmp_invalidItems (
	intId INT 
	,strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

CREATE TABLE #tmp_invalidLocations (
	intId INT 
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

CREATE TABLE #tmp_invalidItemLocations (
	intId INT 
	,strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

-----------------------------------------------
-- Begin Validate records
-----------------------------------------------
BEGIN 
	-- Invalid items
	INSERT INTO #tmp_invalidItems (
		intId
		, strItemNo
	)
	SELECT 		
		s.intId 
		, s.strItemNo
	FROM 
		(
			SELECT 
				intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemPricingId) 
				,s.* 
			FROM 
				tblICImportStagingItemPricing s 
			WHERE
				s.strImportIdentifier = @strIdentifier		
		) s
		LEFT JOIN tblICItem i
			ON s.strItemNo = i.strItemNo
	WHERE	
		i.intItemId IS NULL 
	
	-- Invalid Locations
	INSERT INTO #tmp_invalidLocations (
		s.intId
		, strLocationName
	)
	SELECT 
		s.intId 
		, s.strLocation
	FROM 
		(
			SELECT 
				intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemPricingId) 
				,s.* 
			FROM 
				tblICImportStagingItemPricing s 
			WHERE
				s.strImportIdentifier = @strIdentifier		
		) s
		LEFT JOIN tblSMCompanyLocation cl
			ON s.strLocation = cl.strLocationName
	WHERE	
		cl.intCompanyLocationId IS NULL 

	-- Invalid Locations
	INSERT INTO #tmp_invalidItemLocations (
		intId
		, strItemNo
		, strLocationName
	)
	SELECT 
		s.intId 
		,s.strItemNo
		,s.strLocation
	FROM 
		(
			SELECT 
				intId = ROW_NUMBER() OVER(ORDER BY s.intImportStagingItemPricingId) 
				,s.* 
			FROM 
				tblICImportStagingItemPricing s 
			WHERE
				s.strImportIdentifier = @strIdentifier		
		) s
		INNER JOIN tblICItem i 
			ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo))) 
		INNER JOIN tblSMCompanyLocation c 
			ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))
			OR LOWER(c.strLocationNumber) = LTRIM(RTRIM(LOWER(s.strLocation)))
		LEFT JOIN tblICItemLocation il 
			ON il.intLocationId = c.intCompanyLocationId
			AND il.intItemId = i.intItemId
	WHERE 
		i.intItemId IS NOT NULL
		AND c.intCompanyLocationId IS NOT NULL 
		AND il.intItemLocationId IS NULL 

END 
-----------------------------------------------
-- End Validate records
-----------------------------------------------

-- Get the total rows. 
DECLARE @TotalRows AS INT 
SELECT @TotalRows = COUNT(1) FROM tblICImportStagingItemPricing s WHERE s.strImportIdentifier = @strIdentifier

DECLARE @tblDuplicateItemNo TABLE(
	intId INT 
	,strItemNo NVARCHAR(200)
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
);

-- Retrieve the duplicate records. 
INSERT INTO @tblDuplicateItemNo (
	intId 
	,strItemNo
	,strLocationName
)
SELECT 
	intId
	,strItemNo
	,strLocation 
FROM
	(
		SELECT 
			*
			, RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo, strLocation)
			, intId = ROW_NUMBER() OVER(ORDER BY intImportStagingItemPricingId) 
		FROM 
			tblICImportStagingItemPricing
		WHERE 
			strImportIdentifier = @strIdentifier
	) AS DuplicateCounter
WHERE 
	RowNumber > 1

-- Delete the duplicate records. 
;WITH cte AS
(
   SELECT 
		*
		, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo, strLocation) AS RowNumber
   FROM 
		tblICImportStagingItemPricing
   WHERE 
		strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

-- Get the valid records
INSERT INTO #tmpItemPricing
(
	  intItemId				
	, intItemLocationId		
	, intCompanyLocationId
	, dblAmountPercent		
	, dblSalePrice			
	, dblMSRPPrice			
	, strPricingMethod		
	, dblLastCost			
	, dblStandardCost		
	, dblAverageCost		
	, dblDefaultGrossPrice
	, dtmDateCreated		
	, intCreatedByUserId	
)
SELECT
	  intItemId				= i.intItemId
	, intItemLocationId		= il.intItemLocationId
	, intCompanyLocationId	= c.intCompanyLocationId
	, dblAmountPercent		= NULLIF(s.dblAmountPercent, 0)
	, dblSalePrice			= NULLIF(s.dblRetailPrice, 0)
	, dblMSRPPrice			= NULLIF(s.dblMSRP, 0)
	, strPricingMethod		= ISNULL(s.strPricingMethod, 'None')
	, dblLastCost			= NULLIF(s.dblLastCost, 0)
	, dblStandardCost		= NULLIF(s.dblStandardCost, 0)
	, dblAverageCost		= NULLIF(s.dblAverageCost, 0)
	, dblDefaultGrossPrice	= NULLIF(s.dblDefaultGrossPrice, 0)
	, dtmDateCreated		= s.dtmDateCreated		
	, intCreatedByUserId	= s.intCreatedByUserId	
FROM tblICImportStagingItemPricing s
	INNER JOIN tblICItem i ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo))) 
	INNER JOIN tblSMCompanyLocation c ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))
		OR LOWER(c.strLocationNumber) = LTRIM(RTRIM(LOWER(s.strLocation)))
	INNER JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
		AND il.intItemId = i.intItemId
WHERE s.strImportIdentifier = @strIdentifier

CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL)

;MERGE INTO tblICItemPricing AS [target]
USING
(
	SELECT
	  intItemId				
	, intItemLocationId	
	, intCompanyLocationId
	, dblAmountPercent		
	, dblSalePrice			
	, dblMSRPPrice			
	, strPricingMethod		
	, dblLastCost			
	, dblStandardCost		
	, dblAverageCost		
	, dblDefaultGrossPrice
	, dtmDateCreated		
	, intCreatedByUserId
	FROM #tmpItemPricing s
) AS 
	source ON [target].intItemId = source.intItemId
	AND [target].intItemLocationId = source.intItemLocationId
WHEN MATCHED THEN
	UPDATE SET
		  intItemId				= source.intItemId
		, intItemLocationId		= source.intItemLocationId
		, dblAmountPercent		= ISNULL(source.dblAmountPercent, [target].dblAmountPercent)
		, dblSalePrice			= ISNULL(source.dblSalePrice, [target].dblSalePrice)
		, dblMSRPPrice			= ISNULL(source.dblMSRPPrice, [target].dblMSRPPrice)
		, strPricingMethod		= ISNULL(source.strPricingMethod, 'None')
		, dblLastCost			= ISNULL(source.dblLastCost, [target].dblLastCost)
		, dblStandardCost		= ISNULL(source.dblStandardCost, [target].dblStandardCost)
		, dblAverageCost		= ISNULL(source.dblAverageCost, [target].dblAverageCost)
		, dblDefaultGrossPrice	= ISNULL(source.dblDefaultGrossPrice, [target].dblDefaultGrossPrice)
		, dtmDateModified = GETUTCDATE()
		, intModifiedByUserId = source.intCreatedByUserId
		, intImportFlagInternal = 1
WHEN NOT MATCHED THEN
	INSERT
	(
		  intItemId				
		, intItemLocationId		
		, dblAmountPercent		
		, dblSalePrice			
		, dblMSRPPrice			
		, strPricingMethod		
		, dblLastCost			
		, dblStandardCost		
		, dblAverageCost		
		, dblDefaultGrossPrice
		, dtmDateCreated		
		, intCreatedByUserId
		, intDataSourceId
		, intImportFlagInternal
	)
	VALUES
	(
		intItemId				
		, intItemLocationId		
		, dblAmountPercent		
		, dblSalePrice			
		, dblMSRPPrice			
		, strPricingMethod		
		, dblLastCost			
		, dblStandardCost		
		, dblAverageCost		
		, dblDefaultGrossPrice
		, dtmDateCreated		
		, intCreatedByUserId
		, @intDataSourceId
		, 1
	)
	OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

EXEC dbo.uspICUpdateItemImportedPricingLevel

-- Sync Pricing to Location to make sure all locations have corresponding price
DECLARE @intItemId INT
DECLARE @intUserId INT
DECLARE cur CURSOR FOR
SELECT DISTINCT intItemId, intCreatedByUserId FROM #tmpItemPricing

OPEN cur

FETCH NEXT FROM cur INTO @intItemId, @intUserId

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspICSyncItemLocationPricing @intItemId = @intItemId, @intUserId = @intUserId
	FETCH NEXT FROM cur INTO @intItemId, @intUserId
END

CLOSE cur
DEALLOCATE cur

-- Logs 
BEGIN 
	DECLARE 
		@intRowsImported AS INT 
		,@intRowsUpdated AS INT
		,@intRowsSkipped AS INT	

	SELECT @intRowsImported = COUNT(*) FROM #output WHERE strAction = 'INSERT'
	SELECT @intRowsUpdated = COUNT(*) FROM #output WHERE strAction = 'UPDATE'
	
	SELECT 
		@intRowsSkipped = ISNULL(@TotalRows, 0) - ISNULL(@intRowsImported, 0) - ISNULL(@intRowsUpdated, 0)
	FROM 
		tblICImportStagingItemPricing s
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
		,intRowsImported = @intRowsImported
		,intRowsUpdated = @intRowsUpdated
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)

	IF @ysnVerboseLog = 1
	BEGIN 
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
			, 'Item No'
			, 'Import Failed.'
			, strItemNo
			, 'Item "' + strItemNo + '" is not found.'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_invalidItems

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
			, 'Location'
			, 'Import Failed.'
			, strLocationName
			, 'Location "' + strLocationName + '" is not found.'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_invalidLocations

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
			, 'Item Location'
			, 'Import Failed.'
			, strItemNo
			, 'Location "' + strLocationName + '" is not configured for Item "' + strItemNo + '".'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			#tmp_invalidItemLocations

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
			, 'Item No'
			, 'Import Failed.'
			, strItemNo
			, 'Duplicate Item No "' + strItemNo + '" and Location "' + strLocationName + '"'
			, 'Failed'
			, 'Error'
			, 1
		FROM 
			@tblDuplicateItemNo
	END 
	ELSE 
	BEGIN 
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
			, 'Item No'
			, 'Import Failed.'
			, NULL
			, dbo.fnFormatMessage(
				'There are %i Item(s) not found'
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
			#tmp_invalidItems
		HAVING 
			COUNT(1) > 0

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
			, 'Location'
			, 'Import Failed.'
			, NULL
			, dbo.fnFormatMessage(
				'There are %i Location(s) not found.'
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
			#tmp_invalidLocations
		HAVING 
			COUNT(1) > 0

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
			, 'Item Location'
			, 'Import Failed.'
			, NULL 
			, dbo.fnFormatMessage(
				'There are %i Location(s) missing in the Item setup.'
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
			#tmp_invalidItemLocations
		HAVING 
			COUNT(1) > 0

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
			, 'Item No'
			, 'Import Failed.'
			, NULL 
			--, 'Duplicate Item No "' + strItemNo + '" and Location "' + strLocationName + '"'
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

DROP TABLE #tmpItemPricing
DROP TABLE #output
DROP TABLE #tmp_invalidItems
DROP TABLE #tmp_invalidLocations
DROP TABLE #tmp_invalidItemLocations

DELETE FROM [tblICImportStagingItemPricing] WHERE strImportIdentifier = @strIdentifier
