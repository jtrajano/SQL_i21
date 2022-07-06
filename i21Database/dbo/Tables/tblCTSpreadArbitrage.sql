﻿CREATE TABLE [dbo].[tblCTSpreadArbitrage]
(
	[intSpreadArbitrageId] INT IDENTITY NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intPriceFixationId] INT NOT NULL,
	[dtmSpreadArbitrageDate] DATETIME NOT NULL,
	[intTypeRef] INT NOT NULL,
	[strTradeType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[intNewFutureMarketId] INT,
	[intNewFutureMonthId] INT,
	[intOldFutureMarketId] INT,
	[intOldFutureMonthId] INT,
	[strBuySell] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[dblSpreadPrice] NUMERIC(18,6) NOT NULL,
	[intSpreadUOMId] INT NOT NULL,
	[dblSpreadAmount] NUMERIC(18,6) NOT NULL,
	[dblNoOfLots] NUMERIC(18,6) NOT NULL,
	[dblCommissionPrice] NUMERIC(18,6) NULL,
	[dblCommission] NUMERIC(18,6) NULL,
	[dblTotalSpread] NUMERIC(18,6) NULL,
	[strRemarks] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL ,
	[dblCurrentBasis] NUMERIC(18,6) NOT NULL,
	[dblExchangeBasedSpreadArbitrage] NUMERIC(18,6) NULL,

	[ysnPriceImpact] bit not null default 0,
	[intCurrencyId] int null,
	[dblFX] NUMERIC(18,6) NULL,	
	[ysnDerivative] bit not null default 0,
	[intInternalTradeNumberId]  int null,
	[intBrokerId] int null,
	[intBrokerAccountId] int null,
	
	CONSTRAINT [PK_tblCTSpreadArbitrage_intSpreadArbitrageId] PRIMARY KEY CLUSTERED ([intSpreadArbitrageId] ASC),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY ([intPriceFixationId]) REFERENCES [tblCTPriceFixation]([intPriceFixationId]) ON DELETE CASCADE,
		
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFutureMarket_intNewFutureMarketId_intFutureMarketId] FOREIGN KEY ([intNewFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFuturesMonth_intNewFutureMonthId_intFutureMonthId] FOREIGN KEY ([intNewFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFutureMarket_intOldFutureMarketId_intFutureMarketId] FOREIGN KEY ([intOldFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTSpreadArbitrage_tblRKFuturesMonth_intOldFutureMonthId_intFutureMonthId] FOREIGN KEY ([intOldFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),

	CONSTRAINT [FK_tblCTSpreadArbitrage_tblICCommodityUnitMeasure_intSpreadUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intSpreadUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId])
)
