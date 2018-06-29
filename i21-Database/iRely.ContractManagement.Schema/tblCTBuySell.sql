CREATE TABLE [dbo].[tblCTBuySell](
	[intBuySellId] [int] NOT NULL,
	[strBuySell] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTBuySell_intBuySellId] PRIMARY KEY ([intBuySellId])
)

