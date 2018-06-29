CREATE TABLE [dbo].[tblLGInsurancePremiumFactorDetail]
(
	intInsurancePremiumFactorDetailId INT NOT NULL PRIMARY KEY IDENTITY (1, 1),
	intInsurancePremiumFactorId INT NOT NULL,
	dtmValidFrom DATETIME NOT NULL,
	dtmValidTo DATETIME NOT NULL,
	dblCost NUMERIC(18,6) NOT NULL,
	intCostUOM INT NOT NULL, 
	dblInsurancePremiumFactor NUMERIC(18,6),
	dblProfitMarkup NUMERIC(18,6),
	intConcurrencyId INT NOT NULL, 

	CONSTRAINT [FK_tblLGInsurancePremiumFactorDetail_tblLGInsurancePremiumFactor_intInsurancePremiumFactorId] FOREIGN KEY ([intInsurancePremiumFactorId]) REFERENCES [tblLGInsurancePremiumFactor]([intInsurancePremiumFactorId])
)