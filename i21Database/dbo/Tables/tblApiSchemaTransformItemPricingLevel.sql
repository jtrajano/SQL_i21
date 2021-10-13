CREATE TABLE [dbo].[tblApiSchemaTransformItemPricingLevel] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing level location.
	strPriceLevel NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing level.
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The unit of measure.
	dblMin NUMERIC(38, 20) NULL, -- The item pricing level minimum.
	dblMax NUMERIC(38, 20) NULL, -- The item pricing level maximum.
	strPricingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The pricing method.
	strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing level currency.
	dblAmountRate NUMERIC(38, 20) NULL, -- The item pricing level amount rate.
	dblUnitPrice NUMERIC(38, 20) NULL, -- The item level price.
	strCommissionOn NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item pricing level commission.
	dblCommissionRate NUMERIC(38, 20) NULL, -- The item pricing level commission rate.
	dtmEffectiveDate DATETIME NULL -- The item pricing level effetive date.
)