CREATE TABLE tblICStagingAdjustmentDetail (
	  intStagingAdjustmentDetailId INT IDENTITY(1,1)
	, intItemId INT NULL -- Used when this field is included in export
	, intAdjustmentId INT NULL -- Normally used when this field is included in export
	, strAdjustmentNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL -- Used in export but required to have an initial value in import for grouping details
	, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	, strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intOwnershipType INT NULL
	, strLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intUomId INT NULL
	, intItemUOMId INT NULL
	-- Quantity Change
	, dblAdjustQtyBy NUMERIC(38, 20) NULL
	, dblNewQuantity NUMERIC(38, 20) NULL
	, strNewLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblNewUnitCost NUMERIC(38, 20) NULL
	-- Uom Change
	, strNewUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intNewItemUOMId INT NULL
	-- Item Change
	, strNewItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	-- Split Lot, Lot Merge, Lot Move
	, dblNewLotQty NUMERIC(38, 20) NULL
	, strNewWeightUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intNewWeightUomId INT NULL
	, strNewLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strNewStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strNewStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	-- Expiry Date Change
	, dtmNewExpiryDate DATETIME NULL
	-- Lot Owner Change
	, strNewOwner NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, LineNumber INT NULL
	, LinePosition INT NULL
	, CONSTRAINT PK_tblICStagingAdjustmentDetail_intStagingAdjustmentDetailId PRIMARY KEY(intStagingAdjustmentDetailId)
)