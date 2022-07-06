CREATE PROCEDURE [dbo].[uspApiGetItemStockByUom] (
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @intLocationId INT,
    @intItemId INT,
    @dtmDate DATETIME = NULL,
    @intSubLocationId INT = NULL,
    @intStorageLocationId INT = NULL,
    @intOwnershipType INT = 1
)
AS 

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

INSERT INTO tblApiInventoryItemStock (
      guiApiUniqueId
    , intKey
    , intItemId
    , strItemNo
    , intItemUOMId
    , intUOMId
    , strUOM
    , strItemUOMType
    , ysnStockUnit
    , dblUnitQty
    , strCostingMethod
    , intCostingMethodId
    , intLocationId
    , strLocation
    , intSubLocationId
    , strSubLocationName
    , intStorageLocationId
    , strStorageLocationName
    , intOwnershipType
    , strOwnershipType
    , dblRunningAvailableQty
    , dblStorageAvailableQty
    , dblCost
)
SELECT 
  @guiApiUniqueId
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