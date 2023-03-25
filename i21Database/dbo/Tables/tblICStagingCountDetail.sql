CREATE TABLE tblICStagingCountDetail (
	  intStagingCountDetailId INT IDENTITY(1, 1)
	, guiIdentifier UNIQUEIDENTIFIER NOT NULL
	, strCountNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL -- Used for grouping or when exporting
	, intCountId INT NULL -- Normally used when this field is included in export
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	, dblPhysicalCount NUMERIC(38, 20) NULL
	, strCountUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	, strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strCountGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strLotAlias NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strParentLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strParentLotAlias NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strWeightUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblLastCost NUMERIC(38, 20) NULL
	, dblPallets NUMERIC(38, 20) NULL
	, dblQtyPerPallet NUMERIC(38, 20) NULL
	, ysnRecount BIT NULL
	, dblWeightQty NUMERIC(38, 20) NULL
	, intCountUOMId INT NULL
	, intWeightUOMId INT NULL
	, CONSTRAINT PK_tblICStagingCountDetail_intStagingCountDetailId PRIMARY KEY(intStagingCountDetailId)
)