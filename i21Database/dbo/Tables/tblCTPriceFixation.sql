CREATE TABLE [dbo].[tblCTPriceFixation]
(
	[intPriceFixationId] INT IDENTITY(1,1) NOT NULL,
	intPriceContractId INT,
	[intConcurrencyId] INT NOT NULL,
	[intContractHeaderId] INT NOT NULL, 
	[intContractDetailId] INT NULL,
	[intOriginalFutureMarketId] INT NOT NULL,
	[intOriginalFutureMonthId] INT NOT NULL,
	[dblOriginalBasis] NUMERIC(18,6) NOT NULL,
	[dblTotalLots] NUMERIC(18,6),
	[dblLotsFixed] NUMERIC(18,6),
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
	[ysnSplit] BIT,
	[intPriceFixationRefId] INT,

    CONSTRAINT [PK_tblCTPriceFixation_intPriceFixationId] PRIMARY KEY CLUSTERED ([intPriceFixationId] ASC),
	CONSTRAINT [UQ_tblCTPriceFixation_intContractHeaderId_intContractDetailId] UNIQUE (intContractHeaderId,intContractDetailId), 
	CONSTRAINT [FK_tblCTPriceFixation_tblCTPriceContract_intContractDetailId] FOREIGN KEY (intPriceContractId) REFERENCES tblCTPriceContract(intPriceContractId) ON DELETE CASCADE,

	CONSTRAINT [FK_tblCTPriceFixation_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intAgreedItemUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intAgreedItemUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId])
)

GO

CREATE NONCLUSTERED INDEX [_dta_index_tblCTPriceFixation_197_13243102__K4_5_9_10] ON [dbo].[tblCTPriceFixation]
(
       [intContractHeaderId] ASC
)
INCLUDE (     [intContractDetailId],
       [dblTotalLots],
       [dblLotsFixed]) WITH (  DROP_EXISTING = OFF, ONLINE = OFF)
go