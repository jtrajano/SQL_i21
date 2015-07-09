CREATE TABLE [dbo].[tblCTPriceFixation]
(
	[intPriceFixationId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intContractDetailId] INT NOT NULL,
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
	[dblWAContractBasis]  NUMERIC(8,4),
	[dblRollArb]  NUMERIC(8,4),
	[dblAdditionalCost]  NUMERIC(8,4),
	[dblFinalPrice]  NUMERIC(8,4),

	CONSTRAINT [PK_tblCTPriceFixation_intPriceFixationId] PRIMARY KEY CLUSTERED ([intPriceFixationId] ASC),
	CONSTRAINT [FK_tblCTPriceFixation_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTPriceFixation_tblICItemUOM_intAgreedItemUOMId_intItemUOMId] FOREIGN KEY ([intAgreedItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
