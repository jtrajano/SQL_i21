CREATE PROCEDURE uspICImportOpeningBalancesFromStaging 
	@strIdentifier NVARCHAR(100)
	, @intDataSourceId INT = 2
AS

DECLARE 
	@row_inserted AS INT 
	,@row_errors AS INT 
	,@row_warnings AS INT 
	,@LogId AS INT

SELECT TOP 1 
	@LogId = l.intImportLogId 
	,@row_warnings = l.intTotalWarnings
FROM 
	tblICImportLog l
WHERE 
	l.strUniqueId = @strIdentifier

DELETE 
FROM 
	tblICImportStagingOpeningBalance 
WHERE 
	strImportIdentifier <> @strIdentifier

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intLocationId INT NULL
	, dtmDate DATETIME NULL
	, intItemUOMId INT NULL
	, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intOwnershipTypeId INT NULL
	, dblQuantity NUMERIC(38, 20) NULL
	, dblUnitCost NUMERIC(38, 20) NULL
	, dblNetWeight NUMERIC(38, 20) NULL
	, intLotId INT NULL
	, intStorageLocationId INT NULL
	, intStorageUnitId INT NULL
	, intWeightUOMId INT NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

-- Validate the company location 
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid company locations
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Location No'
		,strValue = a.strLocationNo
		,strMessage = 'The company location no: ''' + a.strLocationNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		LEFT JOIN tblSMCompanyLocation c 
			ON c.strLocationNumber = a.strLocationNo 
			OR c.strLocationName = a.strLocationNo
	WHERE 
		c.intCompanyLocationId IS NULL 

	SET @row_errors = @@ROWCOUNT
END

-- Validate the item no. 
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid company locations
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Item No'
		,strValue = a.strLocationNo
		,strMessage = 'The item no: ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		LEFT JOIN tblICItem i
			ON a.strItemNo = i.strItemNo 
	WHERE 
		i.intItemId IS NULL

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

-- Validate the UOM
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid UOM
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'UOM'
		,strValue = a.strUOM
		,strMessage = 'The UOM for ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		OUTER APPLY (
			SELECT TOP 1
				i.intItemId
				,u.intUnitMeasureId
				,i.strItemNo
			FROM 
				tblICItem i	LEFT JOIN tblICItemUOM iu
					ON iu.intItemId = i.intItemId
				LEFT JOIN tblICUnitMeasure u
					ON u.intUnitMeasureId = iu.intUnitMeasureId					
			WHERE
				i.strItemNo = a.strItemNo 
				AND u.strUnitMeasure = a.strUOM
		) b	
	WHERE 
		b.intUnitMeasureId IS NULL 
		AND b.intItemId IS NOT NULL 	

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

-- Validate the Weight UOM
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid Weight UOM
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Weight UOM'
		,strValue = a.strWeightUOM
		,strMessage = 'The Weight UOM for ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		OUTER APPLY (
			SELECT TOP 1
				i.intItemId
				,u.intUnitMeasureId
				,i.strItemNo
			FROM 
				tblICItem i	LEFT JOIN tblICItemUOM iu
					ON iu.intItemId = i.intItemId
				LEFT JOIN tblICUnitMeasure u
					ON u.intUnitMeasureId = iu.intUnitMeasureId					
			WHERE
				i.strItemNo = a.strItemNo 
				AND u.strUnitMeasure = a.strWeightUOM
		) b	
	WHERE 
		b.intUnitMeasureId IS NULL 
		AND b.intItemId IS NOT NULL 	
		AND NULLIF(RTRIM(LTRIM(a.strWeightUOM)), '') IS NOT NULL 

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

IF ISNULL(@row_errors, 0) <> 0 GOTO _exit_with_error; 

;WITH cte AS
(
	SELECT 
		*
		, ROW_NUMBER() OVER(PARTITION BY strLocationNo, dtmDate, strItemNo ORDER BY strLocationNo, dtmDate, strItemNo) AS RowNumber
	FROM 
		tblICImportStagingOpeningBalance
	WHERE 
		strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

INSERT INTO #tmp (
	  intItemId
	, intLocationId
	, dtmDate
	, intItemUOMId
	, strDescription
	, intOwnershipTypeId
	, dblQuantity
	, dblUnitCost
	, dblNetWeight
	, intLotId
	, intStorageLocationId
	, intStorageUnitId
	, intWeightUOMId
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  i.intItemId
	, il.intLocationId
	, x.dtmDate
	, iu.intItemUOMId
	, x.strDescription
	, CASE WHEN ISNULL(x.strOwnershipType, 'Own') = 'Own' THEN 1 ELSE 2 END
	, ISNULL(x.dblQuantity, 0)
	, ISNULL(x.dblUnitCost, 0)
	, ISNULL(x.dblNetWeight, 0)
	, lot.intLotId
	, sl.intCompanyLocationSubLocationId
	, su.intStorageLocationId
	, iuw.intItemUOMId
	, x.dtmDateCreated
	, x.intCreatedByUserId
FROM 
	tblICImportStagingOpeningBalance x INNER JOIN tblICItem i 
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strItemNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICUnitMeasure u 
		ON RTRIM(LTRIM(u.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strUOM)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemUOM iu 
		ON iu.intItemId = i.intItemId AND iu.intUnitMeasureId = u.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure uw 
		ON RTRIM(LTRIM(uw.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strWeightUOM)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICItemUOM iuw 
		ON iuw.intItemId = i.intItemId AND iuw.intUnitMeasureId = uw.intUnitMeasureId
	INNER JOIN tblSMCompanyLocation c 
		ON RTRIM(LTRIM(c.strLocationNumber)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
		OR RTRIM(LTRIM(c.strLocationName)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId 
		AND il.intLocationId = c.intCompanyLocationId
	LEFT JOIN tblICLot lot 
		ON lot.strLotNumber COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLotNumber)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMCompanyLocationSubLocation sl 
		ON sl.strSubLocationName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageLocation)) COLLATE Latin1_General_CI_AS
		AND sl.intCompanyLocationId = c.intCompanyLocationId
	LEFT JOIN tblICStorageLocation su 
		ON 
		su.intSubLocationId = sl.intCompanyLocationSubLocationId
		AND (
			su.strName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
			OR su.strDescription COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
		)
WHERE 
	x.strImportIdentifier = @strIdentifier

DECLARE @Adjustments TABLE(
	intId INT
	, intLocationId INT
	, dtmDate DATETIME
	, strDescription NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
	, intUserId INT
	, dtmDateCreated DATETIME
)

-- Create the possible number of header records. 
BEGIN 
	;WITH headers (intId)
	AS
	(
		SELECT MIN(intId) intId
		FROM #tmp
		GROUP BY intLocationId, dtmDate
	)
	INSERT INTO @Adjustments (
		intId
		, intLocationId
		, dtmDate
		, strDescription
		, intUserId
		, dtmDateCreated
	)
	SELECT 
		h.intId
		, t.intLocationId
		, t.dtmDate
		, t.strDescription
		, t.intCreatedByUserId
		, t.dtmDateCreated
	FROM 
		#tmp t INNER JOIN headers h 
			ON h.intId = t.intId
END 


DECLARE @intId INT
DECLARE @intLocationId INT
DECLARE @dtmDate DATETIME
DECLARE @strDescription NVARCHAR(1000)
DECLARE @intUserId INT
DECLARE @dtmDateCreated DATETIME

DECLARE @intAdjustmentId INT
DECLARE @strAdjustmentNo NVARCHAR(100)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT intId, intLocationId, dtmDate, strDescription, intUserId, dtmDateCreated FROM @Adjustments
OPEN cur
FETCH NEXT FROM cur INTO 
	@intId
	, @intLocationId
	, @dtmDate
	, @strDescription
	, @intUserId
	, @dtmDateCreated

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 30, @strAdjustmentNo OUTPUT, @intLocationId
	
	INSERT INTO tblICInventoryAdjustment(
		strAdjustmentNo
		, intLocationId
		, intAdjustmentType
		, dtmAdjustmentDate
		, strDescription
		, intCreatedByUserId
		, dtmDateCreated
		, strDataSource
	)
	VALUES(
		@strAdjustmentNo
		, @intLocationId
		, 10 /*Opening Inventory*/
		, @dtmDate
		, @strDescription
		, @intUserId
		, @dtmDateCreated
		, 'Import CSV'
	)
	
	SET @intAdjustmentId = SCOPE_IDENTITY()

	INSERT INTO tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentId 
		,intItemId
		,dblNewQuantity
		,intNewItemUOMId
		,dblNewCost
		,intNewWeightUOMId
		,dblNewWeight
		,intNewLotId
		,intOwnershipType
		,intNewSubLocationId
		,intNewStorageLocationId
		,intCreatedByUserId 
		,dtmDateCreated
	)
	SELECT
		@intAdjustmentId
		,t.intItemId
		,t.dblQuantity
		,t.intItemUOMId
		,t.dblUnitCost
		,t.intWeightUOMId
		,t.dblNetWeight
		,t.intLotId
		,t.intOwnershipTypeId
		,t.intStorageLocationId
		,t.intStorageUnitId
		,@intUserId
		,@dtmDateCreated
	FROM 
		#tmp t
	WHERE 
		t.dtmDate = @dtmDate
		AND t.intLocationId = @intLocationId

	SET @row_inserted = ISNULL(@row_inserted, 0) + @@ROWCOUNT

	FETCH NEXT FROM cur INTO 
		@intId
		, @intLocationId
		, @dtmDate
		, @strDescription
		, @intUserId
		, @dtmDateCreated
END

CLOSE cur
DEALLOCATE cur

_exit_with_error:
_clean_up: 

DELETE 
FROM 
	tblICImportStagingOpeningBalance 
WHERE 
	strImportIdentifier = @strIdentifier
	
-- Logs 
BEGIN 
	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intTotalErrors]
		,[intTotalWarnings]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@row_inserted, 0)
		,intTotalErrors = ISNULL(@row_errors, 0) 
		,intTotalWarnings = ISNULL(@row_warnings, 0)
END
