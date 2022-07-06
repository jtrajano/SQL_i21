CREATE TABLE [dbo].[tblLGInsurancePremiumFactorPurchase]
(
	[intInsurancePremiumFactorPurchaseId] INT IDENTITY NOT NULL , 
    [intInsurancePremiumFactorId] INT NOT NULL, 
    [intFreightTermId] INT NOT NULL, 
    [dblInsurancePercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblLGInsurancePremiumFactorPurchase] PRIMARY KEY ([intInsurancePremiumFactorPurchaseId]), 
    CONSTRAINT [FK_tblLGInsurancePremiumFactorPurchase_tblLGInsurancePremiumFactor] FOREIGN KEY ([intInsurancePremiumFactorId]) REFERENCES [tblLGInsurancePremiumFactor]([intInsurancePremiumFactorId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblLGInsurancePremiumFactorPurchase_tblSMFreightTerms] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId])
)
