CREATE TABLE [dbo].[tblCTCostMethod](
	[intCostMethodId] [int] NOT NULL,
	[strCostMethod] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTCostMethod_intCostMethodId] PRIMARY KEY ([intCostMethodId])
)