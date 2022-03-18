CREATE TABLE [dbo].[tblICStagingItemUom] (
	  intStagingItemUomId INT IDENTITY(1,1)
	, intItemId INT -- Normally used when this field is included in export
	, intItemUomId INT -- Normally used when this field is included in export
	, intUnitMeasureId INT -- Normally used when this field is included in export
	, strUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblUnitQty NUMERIC(18, 6)
	, strShortUpc NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strUpc NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, ysnStockUnit BIT NULL
	, ysnAllowPurchase BIT NULL
	, ysnAllowSale BIT NULL
	, dblMaxQty NUMERIC(18,6) NULL
	, dtmDateLastUpdated DATETIME NULL
	, CONSTRAINT PK_tblICStagingItemUom_intStagingItemUomId PRIMARY KEY (intStagingItemUomId)
)