CREATE TABLE [dbo].[tblRKAllocatedContractsSettlementPrice]
(
	[intAllocatedContractsSettlementPriceId] INT NOT NULL IDENTITY, 
    [intAllocatedContractsGainOrLossHeaderId] INT NOT NULL, 
    [intFutureMarketId] INT  NULL, 
    [intFutureMonthId] INT  NULL,
	[intFutSettlementPriceMonthId] INT  NULL,
    [dblClosingPrice] NUMERIC(18, 6) NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKAllocatedContractsSettlementPrice] PRIMARY KEY ([intAllocatedContractsSettlementPriceId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsSettlementPrice_tblRKAllocatedContractsGainOrLossHeader] FOREIGN KEY ([intAllocatedContractsGainOrLossHeaderId]) REFERENCES [tblRKAllocatedContractsGainOrLossHeader]([intAllocatedContractsGainOrLossHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKAllocatedContractsSettlementPrice_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsSettlementPrice_tblRKFuturesMonth] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
)