CREATE TABLE [dbo].[tblICStagingItemUom] (
	  intStagingItemUomId INT IDENTITY(1,1)
	, intItemId INT
	, intItemUomId INT
	, intUnitMeasureId INT
	, strUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblUnitQty NUMERIC(18, 6)
	, strShortUpc NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strUpc NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, ysnStockUnit BIT NULL
	, ysnAllowPurchase BIT NULL
	, ysnAllowSale BIT NULL
	, dblMaxQty NUMERIC(18,6) NULL
	, CONSTRAINT PK_tblICStagingItemUom_intStagingItemUomId PRIMARY KEY (intStagingItemUomId)
)