CREATE TABLE [dbo].[tblApiSchemaTransformItemPricing] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing location.
	dblAmountPercent NUMERIC(38, 20) NULL, -- The item pricing amount percent.
	dblSalePrice NUMERIC(38, 20) NULL, -- The item pricing sale price.
	dblMSRPPrice NUMERIC(38, 20) NULL, -- The item pricing MSRP price.
	strPricingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing method.
	dblLastCost NUMERIC(38, 20) NULL, -- The item pricing last cost.
	dblStandardCost NUMERIC(38, 20) NULL, -- The item pricing standard cost.
	dblAverageCost NUMERIC(38, 20) NULL, -- The item pricing average cost.
	dblDefaultGrossPrice NUMERIC(38, 20) NULL, -- The item pricing default gross.
)