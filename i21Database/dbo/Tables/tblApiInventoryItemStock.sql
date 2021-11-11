CREATE TABLE tblApiInventoryItemStock (
      intId INT IDENTITY(1, 1) PRIMARY KEY
    , guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    , intKey INT NOT NULL
    , intItemId INT NOT NULL
    , strItemNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL
    , intItemUOMId INT NULL
    , intUOMId INT NULL
    , strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
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