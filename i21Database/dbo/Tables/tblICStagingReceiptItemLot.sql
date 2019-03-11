CREATE TABLE [dbo].[tblICStagingReceiptItemLot] (
	  intStagingReceiptItemLotId INT IDENTITY(1, 1)
	, intReceiptItemId INT NULL -- Normally used when this field is included in export
	, intReceiptItemLotId INT NULL -- Normally used when this field is included in export
	, intLotId INT NULL -- Normally used when this field is included in export
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblQuantity NUMERIC(38, 20)
	, dblGrossQty NUMERIC(38, 20) NULL
	, dblTareQty NUMERIC(38, 20) NULL
	, dblNetQty NUMERIC(38, 20) NULL -- Normally used when this field is included in export
	, CONSTRAINT PK_tblICStagingReceiptItemLot_intStagingReceiptItemLotId PRIMARY KEY(intStagingReceiptItemLotId)
)