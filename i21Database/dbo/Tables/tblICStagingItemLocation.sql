CREATE TABLE [dbo].[tblICStagingItemLocation] (
	  intStagingItemLocationId INT IDENTITY(1,1)
	, intItemId INT
	, intItemLocationId INT
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCostingMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnAllowNegativeInventory BIT NULL
	, ysnRequireStorageUnit BIT NULL
	, strDefaultVendorNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultSaleUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultPurchaseUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultGrossUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strInventoryCountGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, CONSTRAINT PK_tblICStagingItemLocation_intStagingItemLocationId PRIMARY KEY (intStagingItemLocationId)
)