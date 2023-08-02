﻿CREATE TABLE [dbo].[tblLGWeightClaimDetail]
(
[intWeightClaimDetailId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intWeightClaimId] INT NOT NULL,
[intLoadContainerId] INT NULL,
[strCondition] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intItemId] INT NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[dblFromNet] NUMERIC(18, 6) NULL,
[dblToGross] NUMERIC(18, 6) NULL,
[dblToTare] NUMERIC(18, 6) NULL,
[dblToNet] NUMERIC(18, 6) NULL,
[dblFranchiseWt] NUMERIC(18, 6) NULL,
[dblWeightLoss] NUMERIC(18, 6) NULL,
[dblClaimableWt] NUMERIC(18, 6) NULL,
[intPartyEntityId] INT NULL,
[dblUnitPrice] NUMERIC(18, 6) NULL,
[intCurrencyId] INT NULL,
[dblClaimAmount] NUMERIC(18, 6) NULL,
[intPriceItemUOMId] INT NULL,
[dblAdditionalCost] NUMERIC(18, 6) NULL,
[ysnNoClaim] [bit] NULL,
[intContractDetailId] INT NULL,
[intBillId] INT NULL,
[intInvoiceId] INT NULL,
[dblFranchise] NUMERIC(18, 6) NULL,
[dblSeqPriceConversionFactoryWeightUOM] NUMERIC(18, 6) NULL,
[intWeightClaimDetailRefId] INT NULL,
[strClaimRemarks] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblLGWeightClaimDetail] PRIMARY KEY ([intWeightClaimDetailId]), 
CONSTRAINT [FK_tblLGWeightClaimDetail_tblLGWeightClaim_intWeightClaimId] FOREIGN KEY ([intWeightClaimId]) REFERENCES [tblLGWeightClaim]([intWeightClaimId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGWeightClaimDetail_tblLGLoadContainer_intLoadContainerId] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblEMEntity_intPartyEntityId] FOREIGN KEY ([intPartyEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblICItem_intItemd] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblICItemUOM_intPriceItemUOMId] FOREIGN KEY ([intPriceItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblLGWeightClaimDetail_intWeightClaimId] ON [dbo].[tblLGWeightClaimDetail]
(
	[intWeightClaimId], [intBillId]
)
GO