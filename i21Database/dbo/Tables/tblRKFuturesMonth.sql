CREATE TABLE [dbo].[tblRKFuturesMonth]
(
	[intFutureMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[strFutureMonth] nvarchar(20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intFutureMarketId] INT NOT NULL, 
   	CONSTRAINT [PK_tblRKFuturesMonth_intFuturesMonthId] PRIMARY KEY ([intFutureMonthId]), 
CONSTRAINT [FK_tblRKFuturesMonth_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])
)