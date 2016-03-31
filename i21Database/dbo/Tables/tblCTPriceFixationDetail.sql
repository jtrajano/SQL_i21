﻿CREATE TABLE [dbo].[tblCTPriceFixationDetail]
(
	[intPriceFixationDetailId] INT IDENTITY NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intPriceFixationId] INT NOT NULL,
	[strTradeNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,
	[dtmFixationDate] DATETIME NOT NULL,
	[dblQuantity] NUMERIC(18,6) NULL,
	[intQtyItemUOMId] INT NULL,
	[intNoOfLots] INT NOT NULL,
	[intFutureMarketId] INT NOT NULL,
	[intFutureMonthId] INT NOT NULL,
	[dblFixationPrice] NUMERIC(18,6) NULL,
	[dblFutures] NUMERIC(18,6) NULL,
	[dblBasis] NUMERIC(18,6) NULL,
	[dblPolRefPrice] NUMERIC(18,6) NULL,
	[dblPolPremium] NUMERIC(18,6) NULL,
	[dblCashPrice] NUMERIC(18,6) NULL,
	[intPricingUOMId] INT NOT NULL,
	[ysnHedge] BIT,
	[dblHedgePrice] NUMERIC(18,6) NULL,
	[intHedgeFutureMonthId] INT,
	[intBrokerId] INT,
	[intBrokerageAccountId] INT,
	[intFutOptTransactionId] INT,
	[dblFinalPrice] NUMERIC(18,6) NULL,
	[strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL ,

	CONSTRAINT [PK_tblCTPriceFixationDetail_intPriceFixationDetailId] PRIMARY KEY CLUSTERED ([intPriceFixationDetailId] ASC),
	CONSTRAINT [UK_tblCTPackingDescriptionDetail_strTradeNo] UNIQUE ([strTradeNo]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY ([intPriceFixationId]) REFERENCES [tblCTPriceFixation]([intPriceFixationId]) ON DELETE CASCADE,
	
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblICItemUOM_intQtyItemUOMId_intItemUOMId] FOREIGN KEY ([intQtyItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblICCommodityUnitMeasure_intPricingUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intPricingUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFuturesMonth_intHedgeFutureMonthId_intFutureMonthId] FOREIGN KEY ([intHedgeFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),

	CONSTRAINT [FK_tblCTPriceFixationDetail_tblEntity_intBrokerId_intEntityId] FOREIGN KEY ([intBrokerId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]),
	CONSTRAINT [FK_tblCTPriceFixationDetail_tblRKFutOptTransaction_intFutOptTransactionId] FOREIGN KEY ([intFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId])
)
