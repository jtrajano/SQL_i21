CREATE TABLE [dbo].[tblICStagingReceiptItem] (
	  intStagingReceiptItemId INT IDENTITY(1, 1)
	, intReceiptItemId INT NULL -- Normally used when this field is included in export
	, intReceiptId INT NULL -- Normally used when this field is included in export
	, intItemId INT NULL -- Normally used when this field is included in export
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblReceiptQty NUMERIC(38, 20)
	, strReceiveUom NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strOwnerShipType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblCost NUMERIC(38, 20) NULL
	, strCostUom NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblUnitRetail NUMERIC(38, 20) NULL
	, strGrossUom NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblGrossQty NUMERIC(38, 20) NULL
	, dblNetQty NUMERIC(38, 20) NULL -- Normally used when this field is included in export
	, strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTaxGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strForexRateType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, CONSTRAINT PK_tblICStagingReceiptItem_intStagingReceiptItemId PRIMARY KEY(intStagingReceiptItemId)
)