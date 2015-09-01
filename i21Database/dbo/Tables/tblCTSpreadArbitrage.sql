CREATE TABLE [dbo].[tblCTSpreadArbitrage]
(
	[intSpreadArbitrageId] INT IDENTITY NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intPriceFixationId] INT NOT NULL,
	[dtmSpreadArbitrageDate] DATETIME NOT NULL,
	[intTypeRef] INT NOT NULL,
	[strTradeType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[intNewFutureMarketId] INT,
	[intNewFutureMonthId] INT NOT NULL,
	[intOldFutureMarketId] INT,
	[intOldFutureMonthId] INT,
	[strBuySell] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[dblSpreadAmount] NUMERIC(18,6) NOT NULL,
	[intNoOfLots] INT NOT NULL,
	[dblCommission] NUMERIC(18,6) NULL,
	[strRemarks] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL ,
	[dblCurrentBasis] NUMERIC(18,6) NOT NULL,
	[dblExchangeBasedSpreadArbitrage] NUMERIC(18,6) NULL,
	
	CONSTRAINT [PK_tblCTSpreadArbitrage_intSpreadArbitrageId] PRIMARY KEY CLUSTERED ([intSpreadArbitrageId] ASC),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY ([intPriceFixationId]) REFERENCES [tblCTPriceFixation]([intPriceFixationId]) ON DELETE CASCADE,
		
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFutureMarket_intNewFutureMarketId_intFutureMarketId] FOREIGN KEY ([intNewFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFuturesMonth_intNewFutureMonthId_intFutureMonthId] FOREIGN KEY ([intNewFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFutureMarket_intOldFutureMarketId_intFutureMarketId] FOREIGN KEY ([intOldFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFuturesMonth_intOldFutureMonthId_intFutureMonthId] FOREIGN KEY ([intOldFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
)
