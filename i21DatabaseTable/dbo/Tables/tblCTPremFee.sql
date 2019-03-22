CREATE TABLE [dbo].[tblCTPremFee](
	[intPremFeeId] [int] NOT NULL,
	[strPremFee] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTPremFee_intPremFeeId] PRIMARY KEY ([intPremFeeId])
)