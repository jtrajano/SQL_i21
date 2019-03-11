CREATE TABLE [dbo].[tblICStagingReceiptCharges] (
	  intStagingReceiptChargeId INT IDENTITY(1, 1)
	, intReceiptId INT NULL -- Normally used when this field is included in export
	, intChargeId INT NULL -- Normally used when this field is included in export
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strChargeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCostMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strCostUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strTaxGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strForexRateType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblQuantity NUMERIC(38, 20) NULL
	, dblRate NUMERIC(38, 20) NULL
	, dblAmount NUMERIC(38, 20) NULL
	, strVendorNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnInventoryCost BIT NULL
	, strAllocateCostBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnChargeEntity BIT NULL
	, CONSTRAINT PK_tblICStagingReceiptCharge_intStagingReceiptChargeId PRIMARY KEY(intStagingReceiptChargeId)
)