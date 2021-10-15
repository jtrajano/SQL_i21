CREATE TABLE [dbo].[tblApiSchemaTransformItemSpecialPricing] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The special pricing location.
	strPromotionType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The special pricing promotion type.
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The special pricing unit of measure.
	dblUnit NUMERIC(38, 20) NULL, -- The special pricing discount unit.
	strDiscountBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The special pricing discount by.
	dblDiscount NUMERIC(38, 20) NULL, -- The special pricing discount amount/percent.
	strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The special pricing currency.
	dblUnitAfterDiscount NUMERIC(38, 20) NULL, -- The special pricing retail price.
	dtmBeginDate DATETIME NULL, -- The special pricing begin date.
	dtmEndDate DATETIME NULL, -- The special pricing end date.
	dblDiscountThruQty NUMERIC(38, 20) NULL, -- The special pricing discount through quantity.
	dblDiscountThruAmount NUMERIC(38, 20) NULL, -- The special pricing discount through amount.
	dblAccumulatedQty NUMERIC(38, 20) NULL, -- The special pricing accumulated quantity.
	dblAccumulatedAmount NUMERIC(38, 20) NULL -- The special pricing accumulated amount.
)