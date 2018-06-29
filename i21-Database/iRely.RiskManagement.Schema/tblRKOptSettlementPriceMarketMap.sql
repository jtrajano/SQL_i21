CREATE TABLE [dbo].[tblRKOptSettlementPriceMarketMap]
(
	[intOptSettlementPriceMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
    [intFutureSettlementPriceId] INT NOT NULL, 
    [intOptionMonthId] INT NOT NULL, 
    [dblStrike] NUMERIC(18, 6) NOT NULL, 
    [intTypeId] int NOT NULL, 
    [dblSettle] NUMERIC(18, 6) NOT NULL, 
	[dblDelta] NUMERIC(18, 6) NOT NULL, 
    [strComments] NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,	
	CONSTRAINT [PK_tblRKOptSettlementPriceMarketMap_intOptSettlementPriceMonthId] PRIMARY KEY ([intOptSettlementPriceMonthId]), 
	CONSTRAINT [FK_tblRKOptSettlementPriceMarketMap_tblRKFutureSettlementPrice_intFutureSettlementPriceId] FOREIGN KEY ([intFutureSettlementPriceId]) REFERENCES [tblRKFuturesSettlementPrice]([intFutureSettlementPriceId])ON DELETE CASCADE,
	CONSTRAINT [FK_tblRKOptSettlementPriceMarketMap_tblRKOptionsMonth_intFutureMonthId] FOREIGN KEY ([intOptionMonthId]) REFERENCES [tblRKOptionsMonth]([intOptionMonthId])
	
)
GO
