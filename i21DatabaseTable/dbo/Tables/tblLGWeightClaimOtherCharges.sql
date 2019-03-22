CREATE TABLE [dbo].[tblLGWeightClaimOtherCharges]
(
	[intWeightClaimOtherChargesId] INT IDENTITY PRIMARY KEY
	,[intConcurrencyId] INT
	,[intWeightClaimId] INT
	,[intItemId] INT
	,[intVendorId] INT
	,[dblQuantity] NUMERIC(18, 6)
	,[intItemUOMId] INT
	,[dblWeight] NUMERIC(18, 6)
	,[intWeightUOMId] INT
	,[strCostMethod] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[dblRate] NUMERIC(18, 6)
	,[intRateCurrencyId] INT
	,[intRateUOMId] INT
	,[dblAmount] NUMERIC(18, 6)
	,[intCurrencyId] INT
	,[strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL

	CONSTRAINT [FK_tblLGWeightClaimOtherCharges_tblLGWeightClaim_intWeightClaimId] FOREIGN KEY ([intWeightClaimId]) REFERENCES [tblLGWeightClaim]([intWeightClaimId]) ON DELETE CASCADE, 
)
