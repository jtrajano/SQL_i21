CREATE TABLE [dbo].[tblRestApiReceiptChargeStaging] (
	  intRestApiReceiptChargeStagingId INT IDENTITY(1, 1) NOT NULL
    , intRestApiReceiptStagingId INT NOT NULL
	, strCostMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intChargeId INT NOT NULL
	, intCurrencyId INT NULL
	, intCostUOMId INT NULL
	, intTaxGroupId INT NULL
	, intForexRateTypeId INT NULL
	, dblQuantity NUMERIC(38, 20) NULL
	, dblRate NUMERIC(38, 20) NULL
	, dblAmount NUMERIC(38, 20) NULL
	, intEntityId INT NULL
	, ysnInventoryCost BIT NULL
	, ysnChargeEntity BIT NULL
	, CONSTRAINT PK_tblRestApiReceiptChargeStaging_intRestApiReceiptChargeStagingId PRIMARY KEY(intRestApiReceiptChargeStagingId)
    , CONSTRAINT [FK_tblRestApiReceiptChargeStaging_tblRestApiReceiptStaging_intRestApiReceiptStagingId] 
        FOREIGN KEY ([intRestApiReceiptStagingId]) 
        REFERENCES [tblRestApiReceiptStaging]([intRestApiReceiptStagingId]) ON DELETE CASCADE
)