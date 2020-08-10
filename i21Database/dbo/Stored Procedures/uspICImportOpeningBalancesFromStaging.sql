CREATE PROCEDURE uspICImportOpeningBalancesFromStaging @strIdentifier NVARCHAR(100), @intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingOpeningBalance WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strLocationNo, dtmDate, strItemNo ORDER BY strLocationNo, dtmDate, strItemNo) AS RowNumber
   FROM tblICImportStagingOpeningBalance
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

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
FROM tblICImportStagingOpeningBalance x
	INNER JOIN tblICItem i ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strItemNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICUnitMeasure u ON RTRIM(LTRIM(u.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strUOM)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.intUnitMeasureId = u.intUnitMeasureId
	LEFT OUTER JOIN tblICUnitMeasure uw ON RTRIM(LTRIM(uw.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strWeightUOM)) COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN tblICItemUOM iuw ON iuw.intItemId = i.intItemId AND iuw.intUnitMeasureId = uw.intUnitMeasureId
	INNER JOIN tblSMCompanyLocation c ON RTRIM(LTRIM(c.strLocationNumber)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
		OR RTRIM(LTRIM(c.strLocationName)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId AND il.intLocationId = c.intCompanyLocationId
	LEFT OUTER JOIN tblICLot lot ON lot.strLotNumber COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLotNumber)) COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sl ON sl.strSubLocationName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageLocation)) COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN tblICStorageLocation su ON su.strName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
		OR su.strDescription COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
WHERE x.strImportIdentifier = @strIdentifier

DECLARE @Adjustments TABLE(intId INT, intLocationId INT, dtmDate DATETIME, strDescription NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, intUserId INT, dtmDateCreated DATETIME)

;WITH headers (intId)
AS
(
	SELECT MIN(intId) intId
	FROM #tmp
	GROUP BY intLocationId, dtmDate
)
INSERT INTO @Adjustments (intId, intLocationId, dtmDate, strDescription, intUserId, dtmDateCreated)
SELECT h.intId, t.intLocationId, t.dtmDate, t.strDescription, t.intCreatedByUserId, t.dtmDateCreated
FROM #tmp t
INNER JOIN headers h ON h.intId = t.intId

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500))

-- Log Invalid company locations
INSERT INTO @Logs(strError, strValue, strField)
SELECT 'The company location no: ''' + a.strLocationNo + ''' does not exists.' strError, a.strLocationNo strValue, 'location' strField
FROM tblSMCompanyLocation c
RIGHT OUTER JOIN tblICImportStagingOpeningBalance a ON c.strLocationNumber = a.strLocationNo OR c.strLocationName = a.strLocationNo
WHERE c.intCompanyLocationId IS NULL 

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

FETCH NEXT FROM cur INTO @intId, @intLocationId, @dtmDate, @strDescription, @intUserId, @dtmDateCreated

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 30, @strAdjustmentNo OUTPUT, @intLocationId
	
	INSERT INTO tblICInventoryAdjustment(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, intCreatedByUserId, dtmDateCreated, strDataSource)
	VALUES(@strAdjustmentNo, @intLocationId, 10 /*Opening Inventory*/, @dtmDate, @strDescription, @intUserId, @dtmDateCreated, 'Import CSV')
	
	SET @intAdjustmentId = SCOPE_IDENTITY()

	INSERT INTO tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentId, 
		intItemId,
		dblNewQuantity,
		intNewItemUOMId,
		dblNewCost,
		intNewWeightUOMId,
		dblNewWeight,
		intNewLotId,
		intOwnershipType,
		intNewSubLocationId,
		intNewStorageLocationId,
		intCreatedByUserId, 
		dtmDateCreated)
	SELECT
		@intAdjustmentId,
		t.intItemId,
		t.dblQuantity,
		t.intItemUOMId,
		t.dblUnitCost,
		t.intWeightUOMId,
		t.dblNetWeight,
		t.intLotId,
		t.intOwnershipTypeId,
		t.intStorageLocationId,
		t.intStorageUnitId,
		@intUserId,
		@dtmDateCreated
	FROM #tmp t
	WHERE t.dtmDate = @dtmDate
		AND t.intLocationId = @intLocationId

	FETCH NEXT FROM cur INTO @intId, @intLocationId, @dtmDate, @strDescription, @intUserId, @dtmDateCreated
END

CLOSE cur
DEALLOCATE cur

DROP TABLE #tmp

DELETE FROM tblICImportStagingOpeningBalance WHERE strImportIdentifier = @strIdentifier