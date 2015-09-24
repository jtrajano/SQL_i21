﻿CREATE TABLE [dbo].[tblCTPriceFixation]
(
	[intPriceFixationId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intContractHeaderId] INT NOT NULL, 
	[intContractDetailId] INT NULL,
	[intOriginalFutureMarketId] INT NOT NULL,
	[intOriginalFutureMonthId] INT NOT NULL,
	[dblOriginalBasis] NUMERIC(8,4) NOT NULL,
	[intTotalLots] INT,
	[intLotsFixed] INT,
	[intLotsHedged] INT,
	[dblPolResult] NUMERIC(8,4),
	[dblPremiumPoints] NUMERIC(8,4),
	[ysnAAPrice] BIT,
	[ysnSettlementPrice] BIT,
	[ysnToBeAgreed] BIT,
	[dblAgreedAmount] NUMERIC(8,4),
	[intAgreedItemUOMId] INT,
	[dblPolPct] NUMERIC(5,2),
	[dblPriceWORollArb]  NUMERIC(8,4),
	[dblRollArb]  NUMERIC(8,4),
	[dblAdditionalCost]  NUMERIC(8,4),
	[dblFinalPrice]  NUMERIC(8,4),
	[intFinalPriceUOMId] INT NOT NULL,

    CONSTRAINT [PK_tblCTPriceFixation_intPriceFixationId] PRIMARY KEY CLUSTERED ([intPriceFixationId] ASC),
	CONSTRAINT [FK_tblCTPriceFixation_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intAgreedItemUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intAgreedItemUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId])
)
