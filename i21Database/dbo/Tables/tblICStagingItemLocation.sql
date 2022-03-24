CREATE TABLE [dbo].[tblICStagingItemLocation] (
	  intStagingItemLocationId INT IDENTITY(1,1)
	, intItemId INT NULL -- Normally used when this field is included in export
	, intItemLocationId INT NULL -- Normally used when this field is included in export
	, intLocationId INT NULL -- Normally used when this field is included in export
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocationNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCostingMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnAllowNegativeInventory BIT NULL
	, ysnActive BIT NULL
	, intAllowZeroCostTypeId INT NULL -- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
	, ysnRequireStorageUnit BIT NULL
	, dblReorderPoint NUMERIC(18, 6) NULL
	, dblLeadTime NUMERIC(18, 6) NULL
	, intDefaultGrossUomId INT NULL
	, intDefaultPurchaseUomId INT NULL
	, intDefaultSaleUomId INT NULL
	, intDefaultGrossUnitMeasureId INT NULL
	, intDefaultPurchaseUnitMeasureId INT NULL
	, intDefaultSaleUnitMeasureId INT NULL
	, intReorderPoint AS CAST(ROUND(dblReorderPoint, 2) AS INT)
	, intLeadTime AS CAST(ROUND(dblLeadTime, 2) AS INT)
	, strDefaultVendorNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultSaleUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultPurchaseUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultGrossUom NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strInventoryCountGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dtmDateLastUpdated DATETIME NULL
	, CONSTRAINT PK_tblICStagingItemLocation_intStagingItemLocationId PRIMARY KEY (intStagingItemLocationId)
)
