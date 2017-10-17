CREATE TABLE [dbo].[tblAPBasisAdvanceFuture]
(
	[intBasisAdvanceFuturesId] INT NOT NULL PRIMARY KEY,
	[intBasisAdvanceDummyHeaderId] INT NOT NULL,
	[intFutureMarketId] INT NOT NULL,
	[intMonthId] INT NOT NULL,
	[strFutures] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[strMonthYear] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[dblPrice] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL ,
	CONSTRAINT [FK_tblAPBasisAdvanceFuture_tblAPBasisAdvanceDummyHeader] FOREIGN KEY ([intBasisAdvanceDummyHeaderId]) REFERENCES [dbo].[tblAPBasisAdvanceDummyHeader] ([intBasisAdvanceDummyHeaderId])
)
