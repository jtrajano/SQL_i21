﻿CREATE TABLE [dbo].[tblTRLoadBlendIngredient]
(
	[intLoadBlendIngredientId] INT NOT NULL IDENTITY, 
    [intLoadDistributionDetailId] INT NOT NULL, 
	[strBillOfLading] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strReceiptLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intRecipeItemId] INT NOT NULL,
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
	[ysnSubstituteItem] BIT NULL DEFAULT((0)),
	[intSubstituteItemId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTRLoadBlendIngredient] PRIMARY KEY ([intLoadBlendIngredientId]), 
    CONSTRAINT [FK_tblTRLoadBlendIngredient_tblTRLoadDistributionDetail] FOREIGN KEY ([intLoadDistributionDetailId]) REFERENCES [tblTRLoadDistributionDetail]([intLoadDistributionDetailId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTRLoadBlendIngredient_tblMFRecipeItem] FOREIGN KEY ([intRecipeItemId]) REFERENCES [tblMFRecipeItem]([intRecipeItemId])
)
GO

CREATE INDEX [IX_tblTRLoadBlendIngredient_intLoadDistributionDetailId] ON [dbo].[tblTRLoadBlendIngredient] ([intLoadDistributionDetailId])
GO

CREATE INDEX [IX_tblTRLoadBlendIngredient_strReceiptLink] ON [dbo].[tblTRLoadBlendIngredient] ([strReceiptLink])
GO