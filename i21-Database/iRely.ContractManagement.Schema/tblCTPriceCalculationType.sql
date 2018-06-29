CREATE TABLE [dbo].[tblCTPriceCalculationType](
	[intPriceCalculationTypeId] [int] NOT NULL,
	[strPriceCalculationType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTPriceCalculationType_intPriceCalculationTypeId] PRIMARY KEY ([intPriceCalculationTypeId])
)

