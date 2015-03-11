CREATE TABLE [dbo].[tblRKFuturesSettlementPrice]
(
	[intFutureSettlementPriceId] INT IDENTITY(1,1) NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [dtmPriceDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKFuturesSettlementPrice_intFutureSettlementPriceId] PRIMARY KEY ([intFutureSettlementPriceId]), 
	CONSTRAINT [FK_tblRKFuturesSettlementPrice_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [UK_tblRKFuturesSettlementPrice_intFutureMarketId_dtmPriceDate] UNIQUE ([intFutureMarketId], [dtmPriceDate])
)