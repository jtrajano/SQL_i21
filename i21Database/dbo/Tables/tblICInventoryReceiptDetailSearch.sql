CREATE TABLE tblICInventoryReceiptDetailSearch
(
      intId INT NOT NULL IDENTITY(1, 1)
	, dtmDateCreated DATETIME NULL
	, dtmDateModified DATETIME NULL
    , intInventoryReceiptId INT NOT NULL
    , intInventoryReceiptItemId INT NOT NULL
    , strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strReceiptType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strSourceType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dtmReceiptDate DATETIME NULL
    , strVendorId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strVendorName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strBillOfLading NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , ysnPosted BIT NULL
    , intLineNo INT NULL
    , intItemId INT NULL
    , strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
    , dblQtyToReceive NUMERIC(38, 15) NULL
    , intLoadToReceive INT NULL
    , dblUnitCost NUMERIC(38, 15) NULL
    , dblTax NUMERIC(38, 15) NULL
    , dblLineTotal NUMERIC(38, 15) NULL
    , dblGrossWgt NUMERIC(38, 15) NULL
    , dblNetWgt NUMERIC(38, 15) NULL
    , strLotTracking NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , intCommodityId INT NULL
    , intContainerId INT NULL
    , intSourceId INT NULL
    , intSubLocationId INT NULL
    , strSubLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strSubLocationDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , intStorageLocationId INT NULL
    , strStorageLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strStorageUnitType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strUnitType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strWeightUOM NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dblItemUOMConvFactor NUMERIC(38, 15) NULL
    , dblWeightUOMConvFactor NUMERIC(38, 15) NULL
    , strCostUOM NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dblCostUOMConvFactor NUMERIC(38, 15) NULL
    , ysnSubCurrency BIT NULL
    , strSubCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dblGrossMargin NUMERIC(38, 15) NULL
    , intGradeId INT NULL
    , dblBillQty NUMERIC(38, 15) NULL
    , strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , intLifeTime INT NULL
    , strLifeTimeType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , intDiscountSchedule INT NULL
    , strDiscountSchedule NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , ysnExported BIT NULL
    , dtmExportedDate DATETIME NULL
    , strVendorRefNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strShipFromEntity NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strShipFrom NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
    , intCurrencyId INT NULL
    , strCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , ysnLotWeightsRequired BIT NULL
    , strBook NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strSubBook NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , ysnStorageUnitRequired BIT NULL
    , intLocationId INT NULL
    , intShipToLocationId INT NULL
    , intContractSeq INT NULL
    , strERPPONumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strERPItemNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strOrigin NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strPurchasingGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , strINCOShipTerm NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , dblFranchise NUMERIC(38, 15) NULL
    , dblContainerWeightPerQty NUMERIC(38, 15) NULL
    , ysnLoad BIT NULL
    , dblAvailableQty NUMERIC(38, 15) NULL
    , strOrderUOM NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dblOrderUOMConvFactor NUMERIC(38, 15) NULL
    , strContainer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , intOrderId INT NULL
    , strOrderNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    , dtmDate DATETIME NULL
    , dblOrdered NUMERIC(38, 15) NULL
    , dblReceived NUMERIC(38, 15) NULL
    , strSourceNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strFieldNo NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
    , strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strCommodity NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , intCategoryId INT NULL
    , intUserId INT NULL
    , intRoleId INT NULL
    , CONSTRAINT [PK_tblICInventoryReceiptDetailSearchByLocation] PRIMARY KEY ([intId])
)