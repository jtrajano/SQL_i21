CREATE TABLE [dbo].[tblCTPricingType](
	[intPricingTypeId] [int] NOT NULL,
	[strPricingType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTPricingType_intPricingTypeId] PRIMARY KEY ([intPricingTypeId])
)