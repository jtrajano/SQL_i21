CREATE TABLE [dbo].[tblICStagingItem] (
	  intStagingItemId INT IDENTITY(1,1)
	, intItemId INT -- Normally used when this field is included in export
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS 
	, strDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBundleType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strInventoryTracking NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strLotTracking NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strCostType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strCostMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strModelNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnUseWeighScales BIT NULL
	, ysnLotWeightsRequired BIT NULL
	, ysnStockedItem BIT NULL
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strBrandCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strManufacturer NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dtmDateLastUpdated DATETIME NULL
	, CONSTRAINT PK_tblICStagingItem_intStagingItemId PRIMARY KEY (intStagingItemId)
)