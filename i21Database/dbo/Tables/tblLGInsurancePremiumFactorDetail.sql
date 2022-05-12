CREATE TABLE [dbo].[tblLGInsurancePremiumFactorDetail]
(
	intInsurancePremiumFactorDetailId INT NOT NULL IDENTITY (1, 1),
	intInsurancePremiumFactorId INT NOT NULL,
	intProcurementZoneId INT NULL,
	intLoadingPortId INT NULL,
	intDestinationZoneId INT NULL,
	intDestinationPortId INT NULL,
	dblCost NUMERIC(18,6) NULL,
	intCostUOM INT NULL, 
	dblInsurancePremiumFactor NUMERIC(18,6),
	dblProfitMarkup NUMERIC(18,6),
	intConcurrencyId INT NOT NULL, 

	CONSTRAINT [FK_tblLGInsurancePremiumFactorDetail_tblLGInsurancePremiumFactor_intInsurancePremiumFactorId] FOREIGN KEY ([intInsurancePremiumFactorId]) REFERENCES [tblLGInsurancePremiumFactor]([intInsurancePremiumFactorId]) ON DELETE CASCADE, 
    CONSTRAINT [PK_tblLGInsurancePremiumFactorDetail] PRIMARY KEY ([intInsurancePremiumFactorDetailId])
)