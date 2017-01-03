CREATE TYPE [dbo].[TFTaxCategory] AS TABLE(
	[intId] [int] NULL,
	[intTaxCodeId] [int] NULL,
	[strCriteria] [nvarchar](50) NULL
)