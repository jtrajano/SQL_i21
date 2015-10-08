﻿CREATE TABLE [dbo].[tblCTPriceFixation]
(
	[intPriceFixationId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intContractHeaderId] INT NOT NULL, 
	[intContractDetailId] INT NULL,
	[intOriginalFutureMarketId] INT NOT NULL,
	[intOriginalFutureMonthId] INT NOT NULL,
	[dblOriginalBasis] NUMERIC(18,6) NOT NULL,
	[intTotalLots] INT,
	[intLotsFixed] INT,
	[intLotsHedged] INT,
	[dblPolResult] NUMERIC(18,6),
	[dblPremiumPoints] NUMERIC(18,6),
	[ysnAAPrice] BIT,
	[ysnSettlementPrice] BIT,
	[ysnToBeAgreed] BIT,
	[dblSettlementPrice] NUMERIC(18,6),
	[dblAgreedAmount] NUMERIC(18,6),
	[intAgreedItemUOMId] INT,
	[dblPolPct] NUMERIC(18,6),
	[dblPriceWORollArb]  NUMERIC(18,6),
	[dblRollArb]  NUMERIC(18,6),
	[dblPolSummary]  NUMERIC(18,6),
	[dblAdditionalCost]  NUMERIC(18,6),
	[dblFinalPrice]  NUMERIC(18,6),
	[intFinalPriceUOMId] INT NOT NULL,

    CONSTRAINT [PK_tblCTPriceFixation_intPriceFixationId] PRIMARY KEY CLUSTERED ([intPriceFixationId] ASC),
	CONSTRAINT [FK_tblCTPriceFixation_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intAgreedItemUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intAgreedItemUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId])
)
