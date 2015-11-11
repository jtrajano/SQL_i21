CREATE TABLE [dbo].[tblLGWeightClaimDetail]
(
[intWeightClaimDetailId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intWeightClaimId] INT NOT NULL,
[strCondition] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intItemId] INT NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[dblFromNet] NUMERIC(18, 6) NULL,
[dblToNet] NUMERIC(18, 6) NULL,
[dblFranchiseWt] NUMERIC(18, 6) NULL,
[dblWeightLoss] NUMERIC(18, 6) NULL,
[dblClaimableWt] NUMERIC(18, 6) NULL,
[intPartyEntityId] INT NULL,
[dblUnitPrice] NUMERIC(18, 6) NULL,
[intCurrencyId] INT NULL,
[dblClaimAmount] NUMERIC(18, 6) NULL,
[intPriceItemUOMId] INT NULL,
[ysnNoClaim] [bit] NULL,

CONSTRAINT [PK_tblLGWeightClaimDetail] PRIMARY KEY ([intWeightClaimDetailId]), 
CONSTRAINT [FK_tblLGWeightClaimDetail_tblLGWeightClaim_intWeightClaimId] FOREIGN KEY ([intWeightClaimId]) REFERENCES [tblLGWeightClaim]([intWeightClaimId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGWeightClaimDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblEntity_intPartyEntityId] FOREIGN KEY ([intPartyEntityId]) REFERENCES [tblEntity]([intEntityId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblICItem_intItemd] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGWeightClaimDetail_tblICItemUOM_intPriceItemUOMId] FOREIGN KEY ([intPriceItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
