﻿CREATE TABLE [dbo].[tblLGPendingClaim]
(
	[intPendingClaimId] INT NOT NULL IDENTITY (1, 1),
	[intPurchaseSale] INT NOT NULL,
	[intLoadId] INT NOT NULL,
	[intLoadContainerId] INT NULL,
	[intContractDetailId] INT NULL,
	[intEntityId] INT NULL,
	[intPartyEntityId] INT NULL,
	[intWeightId] INT NULL,
	[intItemId] INT NULL,
	[intWeightUnitMeasureId] INT NULL,
	[dblShippedNetWt] NUMERIC(18, 6) NULL,
	[dblReceivedNetWt] NUMERIC(18, 6) NULL,
	[dblReceivedGrossWt] NUMERIC(18, 6) NULL,
	[dblFranchisePercent] NUMERIC(18, 6) NULL,
	[dblFranchise] NUMERIC(18, 6) NULL,
	[dblFranchiseWt] NUMERIC(18, 6) NULL,
	[dblWeightLoss] NUMERIC(18, 6) NULL,
	[dblClaimableWt] NUMERIC(18, 6) NULL,
	[dblClaimableAmount] NUMERIC(18, 6) NULL,
	[dblSeqPrice] NUMERIC(18, 6) NULL,
	[intSeqCurrencyId] INT NULL,
	[intSeqPriceUOMId] INT NULL,
	[intSeqBasisCurrencyId] INT NULL,
	[ysnSeqSubCurrency] BIT NULL,
	[dblSeqPriceInWeightUOM] NUMERIC(18, 6) NULL,
	[dblSeqPriceConversionFactoryWeightUOM] NUMERIC(18, 6) NULL,
	[dtmReceiptDate] DATETIME NULL,
	[dtmDateAdded] DATETIME NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	
	CONSTRAINT [PK_tblLGPendingClaim_intPendingClaimId] PRIMARY KEY ([intPendingClaimId]), 
	CONSTRAINT [FK_tblLGPendingClaim_tblLGLoad] FOREIGN KEY ([intLoadId]) REFERENCES tblLGLoad([intLoadId]),
	CONSTRAINT [PK_tblLGPendingClaim_tblLGLoadContainer] FOREIGN KEY ([intLoadContainerId]) REFERENCES tblLGLoadContainer([intLoadContainerId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES tblCTContractDetail([intContractDetailId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblEMEntity_intPartyEntityId] FOREIGN KEY ([intPartyEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblCTWeightGrade] FOREIGN KEY ([intWeightId]) REFERENCES tblCTWeightGrade([intWeightGradeId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblSMCurrency_intSeqCurrencyId] FOREIGN KEY ([intSeqCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblLGPendingClaim_tblSMCurrency_intSeqBasisCurrencyId] FOREIGN KEY ([intSeqBasisCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblLGPendingClaim_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblICItemUOM_intSeqPriceUOMId] FOREIGN KEY ([intSeqPriceUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGPendingClaim_tblICUnitMeasure] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblLGPendingClaim_intLoadId] ON [dbo].[tblLGPendingClaim]
(
	[intLoadId], [intPurchaseSale], [intContractDetailId], [intLoadContainerId]
)
GO