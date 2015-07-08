CREATE TABLE [dbo].[tblCTPriceFixationDetail]
(
	[intPriceFixationDetailId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intPriceFixationId] INT NOT NULL,
	[strTradeNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[dtmFixationDate] DATETIME NOT NULL,
	[dblQuantity] NUMERIC(18,4) NOT NULL,
	[intQtyItemUOMId] INT NOT NULL,
	[intNoOfLots] INT NOT NULL,
	[intFutureMarketId] INT NOT NULL,
	[intFutureMonthId] INT NOT NULL,
	[dblFutures] NUMERIC(8, 4) NULL,
	[dblBasis] NUMERIC(8, 4) NULL,
	[dblPolRefPrice] NUMERIC(8, 4) NULL,
	[dblPolPremium] NUMERIC(8, 4) NULL,
	[dblCashPrice] NUMERIC(9, 4) NULL,
	[intPriceItemUOMId] INT NOT NULL,
	[ysnHedge] BIT,
	[dblHedgePrice] NUMERIC(8, 4) NULL,
	[intHedgeFutureMonthId] INT,
	[intBrokerId] INT,
	[intBrokerageAccountId] INT

	CONSTRAINT [PK_tblCTPriceFixationDetail_intPriceFixationDetailId] PRIMARY KEY CLUSTERED ([intPriceFixationDetailId] ASC),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY ([intPriceFixationId]) REFERENCES [tblCTPriceFixation]([intPriceFixationId]) ON DELETE CASCADE,
	
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblICItemUOM_intQtyItemUOMId_intItemUOMId] FOREIGN KEY ([intQtyItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblICItemUOM_intPriceItemUOMId_intItemUOMId] FOREIGN KEY ([intPriceItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFuturesMonth_intHedgeFutureMonthId_intFutureMonthId] FOREIGN KEY ([intHedgeFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),

	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKBroker_intBrokerId] FOREIGN KEY ([intBrokerId]) REFERENCES [tblRKBroker]([intBrokerId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]),
)
