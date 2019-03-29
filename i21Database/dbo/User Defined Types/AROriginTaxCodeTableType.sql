CREATE TYPE AROriginTaxCodeTableType AS TABLE(
	[strTaxGroup] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTaxClassId] [int]  NULL,
	[strTaxClass] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[intUnitMeasureId] [int]  NULL,
	[strUnitMeasure] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strTaxableByOtherTaxes] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCountry] [nvarchar](25) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](18,6) NOT NULL,
	[strAccountId] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPurchaseTaxAccountId] [int] NOT NULL,
	[intSalesTaxAccountId] [int] NOT NULL,
	[dtmEffectiveDate] [datetime] NOT NULL
)