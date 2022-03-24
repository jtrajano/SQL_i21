CREATE PROCEDURE [dbo].[uspApiGetItemStock] (
    @intLocationId INT,
    @intItemId INT,
    @intUOMId INT,
    @dtmDate DATETIME = NULL,
    @intSubLocationId INT = NULL,
    @intStorageLocationId INT = NULL,
    @intOwnershipType INT = 1
)
AS 

IF NOT EXISTS(SELECT * FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId)
    RAISERROR('Invalid intLocationId.', 11, 1)

IF NOT EXISTS(SELECT * FROM tblICItem WHERE intItemId = @intItemId)
    RAISERROR('Invalid itemId.', 11, 1)

IF NOT EXISTS(SELECT * FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUOMId)
    RAISERROR('Invalid uomId.', 11, 1)

DECLARE @itemNo NVARCHAR(150)
DECLARE @uom NVARCHAR(100)
SELECT @itemNo = strItemNo FROM tblICItem WHERE intItemId = @intItemId
SELECT @uom = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUOMId

IF NOT EXISTS (SELECT *
FROM tblICItemUOM m
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = m.intUnitMeasureId
WHERE m.intItemId = @intItemId
    AND u.intUnitMeasureId = @intUOMId)
BEGIN
    DECLARE @msg NVARCHAR(200)
    SET @msg = 'The uomId "' + CAST(@intUOMId AS NVARCHAR(50)) + '" is not valid for the itemId "' + CAST(@intItemId AS NVARCHAR(50)) + '". The uom "' + @uom + '" is not setup for the item "' + @itemNo + '".'
    RAISERROR(@msg, 11, 1)
END

If(OBJECT_ID('tempdb..#ItemStock') IS NOT NULL)
BEGIN
    DROP TABLE #Temp
END

CREATE TABLE #ItemStock (
      intKey INT NOT NULL
    , intItemId INT NOT NULL
    , strItemNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL
    , intItemUOMId INT NULL
    , strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strItemUOMType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , ysnStockUnit BIT NULL
    , dblUnitQty NUMERIC(38, 20) NULL
    , strCostingMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , intCostingMethodId INT NULL
    , intLocationId INT
    , strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
    , intSubLocationId INT NULL
    , strSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , intStorageLocationId INT NULL
    , strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , intOwnershipType INT NULL
    , strOwnershipType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , dblRunningAvailableQty NUMERIC(38, 20) NULL
    , dblStorageAvailableQty NUMERIC(38, 20) NULL
    , dblCost NUMERIC(18, 6) NULL
)

IF @dtmDate IS NULL SET @dtmDate = GETDATE()
IF @intOwnershipType IS NULL SET @intOwnershipType = 1

INSERT INTO #ItemStock
EXEC uspICGetItemUOMFromRunningStock @intItemId = @intItemId, @intLocationId = @intLocationId
    , @intSubLocationId = @intSubLocationId, @intStorageLocationId = @intStorageLocationId
    , @dtmDate = @dtmDate, @intOwnershipType = @intOwnershipType

SELECT TOP 1 1 intId
, NEWID() guiApiUniqueId
, s.intKey
, s.intItemId
, s.strItemNo
, s.intItemUOMId
, u.intUnitMeasureId intUOMId
, s.strUnitMeasure strUOM
, s.strItemUOMType
, s.ysnStockUnit
, s.dblUnitQty
, s.strCostingMethod
, s.intCostingMethodId
, s.intLocationId
, s.strLocation
, s.intSubLocationId
, s.strSubLocationName
, s.intStorageLocationId
, s.strStorageLocationName
, s.intOwnershipType
, s.strOwnershipType
, s.dblRunningAvailableQty
, s.dblStorageAvailableQty
, s.dblCost
FROM #ItemStock s
INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = s.intItemUOMId
INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
WHERE u.intUnitMeasureId = @intUOMId
ORDER BY s.intSubLocationId ASC, s.intStorageLocationId ASC