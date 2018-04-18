CREATE TABLE [dbo].[tblRKFuturesSettlementPrice]
(
	[intFutureSettlementPriceId] INT IDENTITY(1,1) NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
	[intCommodityMarketId] INT  NULL, 
    [dtmPriceDate] DATETIME NOT NULL, 
	[strPricingType] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL, 
	[intCompanyId] INT NULL,
    CONSTRAINT [PK_tblRKFuturesSettlementPrice_intFutureSettlementPriceId] PRIMARY KEY ([intFutureSettlementPriceId]), 
	CONSTRAINT [FK_tblRKFuturesSettlementPrice_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [UK_tblRKFuturesSettlementPrice_intFutureMarketId_dtmPriceDate] UNIQUE ([intFutureMarketId], [dtmPriceDate])
)