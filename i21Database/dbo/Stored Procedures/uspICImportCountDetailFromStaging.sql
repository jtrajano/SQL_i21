CREATE PROCEDURE uspICImportCountDetailFromStaging 
	@strIdentifier NVARCHAR(100)
	, @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingCountDetail WHERE strImportIdentifier <> @strIdentifier
DECLARE @tblErrors TABLE(intStagingId INT, strErrorColumn NVARCHAR(200), strErrorValue NVARCHAR(200), strErrorMessage NVARCHAR(200))
DECLARE @tblWarnings TABLE(intStagingId INT, strWarningColumn NVARCHAR(200), strWarningValue NVARCHAR(200), strWarningMessage NVARCHAR(200))

--Begin Transaction
BEGIN TRAN TransactionImportCount
SAVE TRAN TransactionImportCount

BEGIN TRY

--Validate Records

--Check missing Items

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Item No',
	s.strItemNo,
	'Missing Item: ' + s.strItemNo
FROM 
	tblICImportStagingCountDetail s	LEFT JOIN tblICItem i 
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS	
WHERE
	s.strImportIdentifier = @strIdentifier
	AND i.intItemId IS NULL	

--Check missing locations

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Location',
	s.strLocationName,
	'Missing Location: ' + s.strLocationName + ' on Item: ' + s.strItemNo
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN vyuICGetItemLocation v 
		ON RTRIM(LTRIM(v.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(v.strLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strLocationName) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND v.strLocationName IS NULL	

--Check missing UOMs

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'UOM',
	s.strUnitMeasure,
	'Missing Unit of Measure: ' + s.strUnitMeasure + ' on Item: ' + s.strItemNo
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN tblICItem i
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
	LEFT JOIN vyuICGetItemUOM v 
		ON 
		v.intItemId = i.intItemId
		AND
		RTRIM(LTRIM(v.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(s.strUnitMeasure) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND v.strUnitMeasure IS NULL	

--Check invalid item lot trackings

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Lot No',
	s.strLotNo,
	CASE
		WHEN i.strLotTracking <> 'No'
		THEN 'Item: ' + s.strItemNo +  ' is lot-tracked. Lot No is required.'
		ELSE CASE
			WHEN s.strLotNo IS NOT NULL
			THEN 'Item: ' + s.strItemNo +  ' is non lotted item. Lot No: ' + s.strItemNo + ' is not allowed.'
			WHEN s.ysnCountByLots = 1 
			THEN 'Item: ' + s.strItemNo +  ' is non lotted item. Count by Lots is not allowed.'
			END
	END
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN tblICItem i
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND (
		i.strLotTracking <> 'No' AND s.strLotNo IS NULL
		OR
		i.strLotTracking = 'No' AND s.strLotNo IS NOT NULL
		OR
		i.strLotTracking = 'No' AND s.ysnCountByLots = 1
	)


--Check Auto Created Lot Numbers
INSERT INTO @tblWarnings (
	intStagingId, 
	strWarningColumn,
	strWarningValue,
	strWarningMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Lot No',
	s.strLotNo,
	'Lot: ' + s.strLotNo + ' will be auto-created because it does not exists.'
FROM 
	tblICImportStagingCountDetail s
	LEFT JOIN tblICItem i
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
	LEFT JOIN vyuICGetStorageLocation su
		ON 
		RTRIM(LTRIM(su.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strStorageLocation) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICLot l
	ON
		l.strLotNumber = s.strLotNo
		AND
		l.intItemId = i.intItemId
		AND
		l.intStorageLocationId = su.intStorageLocationId
		AND
		l.intSubLocationId = su.intSubLocationId
WHERE
	s.strImportIdentifier = @strIdentifier
	AND
	l.intLotId IS NULL
	AND 
	(
		s.strLotNo IS NOT NULL
		AND
		i.strLotTracking <> 'No'
	)

--Check invalid item sub location

INSERT INTO @tblWarnings (
	intStagingId, 
	strWarningColumn,
	strWarningValue,
	strWarningMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Storage Location',
	s.strSubLocationName,
	'Missing Storage Location: ' + s.strSubLocationName + ' on Item: ' + s.strItemNo + ' setting it to NULL.'
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN vyuICGetItemSubLocation v 
		ON RTRIM(LTRIM(v.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(v.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND v.strSubLocationName IS NULL
	AND s.strSubLocationName IS NOT NULL

--Check invalid item storage location

INSERT INTO @tblWarnings (
	intStagingId, 
	strWarningColumn,
	strWarningValue,
	strWarningMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Storage Unit',
	s.strStorageLocation,
	'Missing Storage Unit: ' + s.strStorageLocation + ' on Item: ' + s.strItemNo + ' setting it to NULL.'
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN vyuICGetStorageLocation su
		ON 
		RTRIM(LTRIM(su.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strStorageLocation) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND su.strName IS NULL
	AND s.strStorageLocation IS NOT NULL

--Check lotted items without storage

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Lot No',
	s.strLotNo,
	'Lotted Item: ' + s.strItemNo + ' requires storage unit'
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN tblICItem i
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
	LEFT JOIN vyuICGetItemSubLocation sl 
		ON RTRIM(LTRIM(sl.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(sl.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
	LEFT JOIN vyuICGetStorageLocation su
		ON 
		RTRIM(LTRIM(su.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strStorageLocation) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND 
	(
		su.strName IS NULL
		OR
		sl.strSubLocationName IS NULL
	)
	AND
	i.strLotTracking <> 'No'

--Check invalid uom of lotted item

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'UOM',
	s.strUnitMeasure,
	'Lot: ' + s.strLotNo + ' exists in ' + v.strItemUOM + '. Cannot retrieve in {uom}. Change the receiving UOM to ' + v.strItemUOM + ' or create a new lot.'
FROM 
	tblICImportStagingCountDetail s
	LEFT JOIN vyuICGetStorageLocation su
		ON 
		RTRIM(LTRIM(su.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strStorageLocation) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICLot l
	ON
		l.strLotNumber = s.strLotNo
		AND
		l.intItemId = su.intItemId
		AND
		l.intStorageLocationId = su.intStorageLocationId
		AND
		l.intSubLocationId = su.intSubLocationId
	LEFT JOIN vyuICItemLot v
	ON
		v.intLotId = l.intLotId
WHERE
	s.strImportIdentifier = @strIdentifier
	AND 
	s.strUnitMeasure != v.strItemUOM

--Check invalid count group

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Count Group',
	s.strCountGroup,
	'Missing Count Group: ' + s.strCountGroup + ' on Item: ' + s.strItemNo
FROM 
	tblICImportStagingCountDetail s	
	LEFT JOIN tblICCountGroup t
		ON RTRIM(LTRIM(t.strCountGroup)) COLLATE Latin1_General_CI_AS = LTRIM(s.strCountGroup) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND 
	t.strCountGroup IS NULL 
	AND 
	s.strCountGroup IS NOT NULL

INSERT INTO @tblErrors (
	intStagingId, 
	strErrorColumn, 
	strErrorValue, 
	strErrorMessage
)
SELECT
	s.intImportStagingCountDetailId,
	'Gross UOM',
	s.strGrossUnitMeasure,
	'Gross UOM is required for Item: ' + s.strItemNo
FROM 
	tblICImportStagingCountDetail s	
	INNER JOIN tblICItem i
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS	
WHERE
	s.strImportIdentifier = @strIdentifier
	AND i.ysnLotWeightsRequired = 1 
	AND i.strLotTracking <> 'No'
	AND s.strGrossUnitMeasure IS NULL

DECLARE @tblInventoryCounts TABLE(
	intStagingId INT, 
	dtmCountDate DATETIME NULL,
	strDescription NVARCHAR(200),
	ysnCountByLots BIT NULL,
	strCountBy NVARCHAR(200),
	intLocationId INT,
	intCreatedByUserId INT
)

INSERT INTO @tblInventoryCounts (
	intStagingId, 
	dtmCountDate,
	strDescription,
	ysnCountByLots,
	strCountBy,
	intLocationId,
	intCreatedByUserId
)
SELECT 
	Grouped.intImportStagingCountDetailId,
	Grouped.dtmCountDate,
	Grouped.strDescription,
	Grouped.ysnCountByLots,
	COALESCE(Grouped.strCountBy, 'Item'),
	ItemLocation.intLocationId,
	Grouped.intCreatedByUserId
FROM 
(
	SELECT 
		s.*, 
		ROW_NUMBER() over(PARTITION BY s.strLocationName ORDER BY s.intImportStagingCountDetailId) AS RN 
	FROM
		tblICImportStagingCountDetail s
	LEFT JOIN 
		@tblErrors e
		ON
		s.intImportStagingCountDetailId = e.intStagingId
	WHERE
		s.strImportIdentifier = @strIdentifier
		AND
		e.intStagingId IS NULL
) AS Grouped
LEFT JOIN vyuICGetItemLocation ItemLocation 
	ON RTRIM(LTRIM(ItemLocation.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(Grouped.strItemNo) COLLATE Latin1_General_CI_AS
	AND
	RTRIM(LTRIM(ItemLocation.strLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(Grouped.strLocationName) COLLATE Latin1_General_CI_AS
WHERE Grouped.RN = 1

DECLARE @tblInventoryCountDetails TABLE(
	intStagingId INT, 
	intLocationId INT,
	intEntityUserSecurityId INT,
	dblLastCost NUMERIC(38, 20) NULL,
	intItemId INT,
	intItemLocationId INT,
	intItemUOMId INT,
	dblPhysicalCount NUMERIC(38, 20) NULL,
	dblPallets NUMERIC(38, 20) NULL,
	dblQtyPerPallet NUMERIC(38, 20) NULL,
	intSubLocationId INT,
	intStorageLocationId INT,
	strLotNo NVARCHAR(200),
	intLotId INT,
	strAutoCreatedLotNumber NVARCHAR(200),
	intWeightUOMId INT,
	dblWeightQty NUMERIC(38, 20) NULL,
	dblNetQty NUMERIC(38, 20) NULL
)

INSERT INTO @tblInventoryCountDetails (
	intStagingId, 
	intLocationId,
	intEntityUserSecurityId,
	intItemId,
	intItemLocationId,
	dblPhysicalCount,
	dblPallets,
	dblQtyPerPallet,
	intItemUOMId,
	dblLastCost,
	intSubLocationId,
	intStorageLocationId,
	strLotNo,
	intLotId,
	strAutoCreatedLotNumber,
	intWeightUOMId,
	dblWeightQty,
	dblNetQty
)
SELECT 
	s.intImportStagingCountDetailId,
	il.intLocationId,
	s.intEntityUserSecurityId,
	i.intItemId,
	il.intItemLocationId,
	s.dblPhysicalCount,
	s.dblPallets,
	s.dblQtyPerPallet,
	iu.intItemUOMId,
	s.dblLastCost,
	CASE
		WHEN wsl.intStagingId IS NULL
		THEN su.intSubLocationId
		ELSE NULL
	END,
	CASE
		WHEN wsu.intStagingId IS NULL
		THEN su.intStorageLocationId
		ELSE NULL
	END,
	s.strLotNo,
	l.intLotId,
	CASE
		WHEN l.intLotId IS NULL
		THEN s.strLotNo
		ELSE NULL
	END,
	CASE
		WHEN s.strGrossUnitMeasure IS NOT NULL
		THEN giu.intItemUOMId
		ELSE NULL
	END,
	CASE
		WHEN s.strGrossUnitMeasure IS NOT NULL
		THEN s.dblPhysicalWeight
		ELSE NULL
	END,
	CASE
		WHEN s.strGrossUnitMeasure IS NOT NULL
		THEN s.dblPhysicalWeight
		ELSE NULL
	END
FROM
	tblICImportStagingCountDetail s
LEFT JOIN 
	@tblErrors e
	ON
	s.intImportStagingCountDetailId = e.intStagingId
LEFT JOIN
	tblICItem i 
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
LEFT JOIN vyuICGetItemLocation il 
		ON RTRIM(LTRIM(il.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(il.strLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strLocationName) COLLATE Latin1_General_CI_AS
LEFT JOIN	
	vyuICGetItemUOM iu
		ON RTRIM(LTRIM(iu.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(s.strUnitMeasure) COLLATE Latin1_General_CI_AS
		AND
		iu.intItemId = i.intItemId
LEFT JOIN vyuICGetStorageLocation su
		ON 
		RTRIM(LTRIM(su.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strSubLocationName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strSubLocationName) COLLATE Latin1_General_CI_AS
		AND
		RTRIM(LTRIM(su.strName)) COLLATE Latin1_General_CI_AS = LTRIM(s.strStorageLocation) COLLATE Latin1_General_CI_AS
LEFT JOIN tblICLot l
	ON
		l.strLotNumber = s.strLotNo
		AND
		l.intItemId = su.intItemId
		AND
		l.intStorageLocationId = su.intStorageLocationId
		AND
		l.intSubLocationId = su.intSubLocationId
LEFT JOIN	
	vyuICGetItemUOM giu
		ON RTRIM(LTRIM(giu.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(s.strGrossUnitMeasure) COLLATE Latin1_General_CI_AS
		AND
		giu.intItemId = i.intItemId
LEFT JOIN
	@tblWarnings wsl
		ON
		s.intImportStagingCountDetailId = wsl.intStagingId
		AND
		wsl.strWarningColumn = 'Storage Location'
LEFT JOIN
	@tblWarnings wsu
		ON
		s.intImportStagingCountDetailId = wsl.intStagingId
		AND
		wsl.strWarningColumn = 'Storage Unit'
	
WHERE
	s.strImportIdentifier = @strIdentifier
	AND
	e.intStagingId IS NULL


DECLARE @intStagingId INT 
DECLARE @dtmCountDate DATETIME
DECLARE @strDescription NVARCHAR(200)
DECLARE @ysnCountByLots BIT
DECLARE @strCountBy NVARCHAR(200)
DECLARE @intLocationId INT
DECLARE @strCountNo NVARCHAR(200)
DECLARE @intCountId INT
DECLARE @intCreatedByUserId INT

DECLARE count_cursor CURSOR FOR 
SELECT 
	intStagingId, 
	dtmCountDate,
	strDescription,
	ysnCountByLots,
	strCountBy,
	intLocationId,
	intCreatedByUserId
FROM @tblInventoryCounts

OPEN count_cursor  
FETCH NEXT FROM count_cursor INTO 
	@intStagingId,  
	@dtmCountDate,
	@strDescription, 
	@ysnCountByLots, 
	@strCountBy,
	@intLocationId,
	@intCreatedByUserId

WHILE @@FETCH_STATUS = 0  
BEGIN  

	EXEC dbo.uspSMGetStartingNumber 76, @strCountNo OUTPUT, @intLocationId

	INSERT INTO tblICInventoryCount
	(
		ysnPosted,
		intStatus,
		intImportFlagInternal,
		ysnIncludeZeroOnHand,
        ysnIncludeOnHand ,
        ysnScannedCountEntry,
        ysnCountByLots,
        ysnCountByPallets,
        ysnRecountMismatch,
        ysnRecount,
        ysnExternal,
        dtmCountDate,
		strCountNo,
		strDescription,
		strCountBy,
		intLocationId,
		strDataSource,
		dtmDateCreated,
		intCreatedByUserId
	)
	VALUES
	(
		0,
		1,
		1,
		0,
		0,
		0,
		ISNULL(@ysnCountByLots, 0),
		0,
		0,
		0,
		0,
		ISNULL(@dtmCountDate, GETDATE()),
		@strCountNo,
		@strDescription,
		@strCountBy,
		@intLocationId,
		'Import CSV',
		GETDATE(),
		@intCreatedByUserId
	)

	SELECT @intCountId = intInventoryCountId FROM tblICInventoryCount WHERE strCountNo = @strCountNo

	UPDATE C 
	SET C.ysnCountByLots = 1 
	FROM tblICInventoryCount C
	WHERE 
	C.strCountNo = @strCountNo
	AND
	C.intLocationId = @intLocationId
	AND
	(SELECT COUNT(*) FROM @tblInventoryCountDetails WHERE intLocationId = @intLocationId AND strLotNo IS NOT NULL) > 0
	
	INSERT INTO tblICInventoryCountDetail 
	(
		intInventoryCountId,
		intEntityUserSecurityId,
		dblSystemCount,
        ysnRecount,
        dblLastCost,
        dblPhysicalCount,
		intItemId,
		intItemLocationId,
		intItemUOMId,
		intSubLocationId,
		intStorageLocationId,
		strLotNo,
		intLotId,
		strAutoCreatedLotNumber,
		intWeightUOMId,
		dblWeightQty,
		dblNetQty,
		strCountLine,
		intCreatedByUserId,
		dtmDateCreated
	)
	SELECT
		@intCountId,
		intEntityUserSecurityId,
		0,
		0,
		ISNULL(dblLastCost, NULL),
		ISNULL(dblPhysicalCount, 0),
		intItemId,
		intItemLocationId,
		intItemUOMId,
		intSubLocationId,
		intStorageLocationId,
		strLotNo,
		intLotId,
		strAutoCreatedLotNumber,
		intWeightUOMId,
		dblWeightQty,
		dblNetQty,
		@strCountNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY intStagingId) AS NVARCHAR(20)),
		intEntityUserSecurityId,
		GETDATE()
	FROM @tblInventoryCountDetails
	WHERE @intLocationId = intLocationId

      FETCH NEXT FROM count_cursor INTO 
		@intStagingId,  
		@dtmCountDate,
		@strDescription, 
		@ysnCountByLots, 
		@strCountBy,
		@intLocationId,
		@intCreatedByUserId
END 

CLOSE count_cursor  
DEALLOCATE count_cursor 

-- Logs 
BEGIN 
	DECLARE 
		@intRowsImported AS INT 
		,@intRowsSkipped AS INT

	DECLARE @intTotalErrors INT
	DECLARE @intTotalWarnings INT
	DECLARE @intTotalRows INT

	SELECT @intRowsImported = COUNT(*) FROM @tblInventoryCountDetails
	SELECT @intRowsSkipped = COUNT(DISTINCT intStagingId) FROM @tblErrors
	SELECT @intTotalErrors = COUNT(*) FROM @tblErrors 
	SELECT @intTotalWarnings = COUNT(*) FROM @tblWarnings
	SELECT @intTotalRows = COUNT(*) FROM tblICImportStagingCountDetail WHERE strImportIdentifier = @strIdentifier


	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
		,[intTotalWarnings]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@intRowsImported, 0)
		,intRowsUpdated = 0
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)
		,intTotalWarnings = ISNULL(@intTotalWarnings, 0)

	-- Log Detail for errors and warnings
	INSERT INTO tblICImportLogDetailFromStaging(
		strUniqueId
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
		, strErrorColumn
		, 'Import Failed.'
		, strErrorValue
		, strErrorMessage
		, 'Failed'
		, 'Error'
		, 1
	FROM 
		@tblErrors
	UNION ALL
	SELECT 
		@strIdentifier
		, strWarningColumn
		, 'Import Finished.'
		, strWarningValue
		, strWarningMessage
		, 'Success'
		, 'Warning'
		, 1
	FROM 
		@tblWarnings

	
END

DELETE FROM tblICImportStagingCountDetail WHERE strImportIdentifier = @strIdentifier

--Successful Exit
GOTO Import_Exit

END TRY

BEGIN CATCH

	--Rollback Exit
	GOTO Import_Rollback_Exit

END CATCH

--Rollback Transaction
Import_Rollback_Exit:
BEGIN 
	ROLLBACK TRAN TransactionImportCount
END

Import_Exit:
BEGIN
	COMMIT TRAN TransactionImportCount
END