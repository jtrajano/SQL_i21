CREATE TABLE [dbo].[tblRKM2MSettlementPrice]
(
	[intM2MSettlementPriceId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
    [intFutureMarketId] INT  NULL, 
    [intFutureMonthId] INT  NULL,
	[intFutSettlementPriceMonthId] INT  NULL,
    [dblClosingPrice] NUMERIC(18, 6) NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MSettlementPrice] PRIMARY KEY ([intM2MSettlementPriceId]), 
    CONSTRAINT [FK_tblRKM2MSettlementPrice_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKM2MSettlementPrice_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKM2MSettlementPrice_tblRKFuturesMonth] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
)
