CREATE TABLE [dbo].[tblRestApiReceiptStaging]
(
      intRestApiReceiptStagingId INT IDENTITY(1, 1) NOT NULL
    , guiUniqueId UNIQUEIDENTIFIER NOT NULL
	, intEntityId INT NOT NULL
	, intLocationId INT NOT NULL
	, dtmReceiptDate DATETIME NULL
	, intShipFromEntityId INT NULL
	, intShipFromLocationId INT NULL
	, intCurrencyId INT NULL
	, intFreightTermId INT NULL
	, strVendorRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strWarehouseRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strShiftNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, dtmLastFreeWhseDate DATETIME NULL
	, CONSTRAINT PK_tblRestApiReceiptStaging_intRestApiReceiptStagingId PRIMARY KEY (intRestApiReceiptStagingId)
)