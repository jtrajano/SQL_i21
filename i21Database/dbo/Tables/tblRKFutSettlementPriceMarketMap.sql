CREATE TABLE [dbo].[tblRKFutSettlementPriceMarketMap]
(
	[intFutSettlementPriceMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
    [intFutureSettlementPriceId] INT NOT NULL, 
    [intFutureMonthId] INT NOT NULL, 
    [dblLastSettle] NUMERIC(18, 6) NOT NULL, 
    [dblLow] NUMERIC(18, 6) NOT NULL, 
    [dblHigh] NUMERIC(18, 6) NOT NULL, 
    [strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,	
    CONSTRAINT [PK_tblRKFutSettlementPriceMarketMap_intFutSettlementPriceMonthId] PRIMARY KEY ([intFutSettlementPriceMonthId]), 
	CONSTRAINT [FK_tblRKFutSettlementPriceMarketMap_tblRKFuturesSettlementPrice_intFutureSettlementPriceId] FOREIGN KEY ([intFutureSettlementPriceId]) REFERENCES [tblRKFuturesSettlementPrice]([intFutureSettlementPriceId])ON DELETE CASCADE,
	CONSTRAINT [FK_tblRKFutSettlementPriceMarketMap_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
	
)
