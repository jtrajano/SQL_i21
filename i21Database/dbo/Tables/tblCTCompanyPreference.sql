CREATE TABLE [dbo].[tblCTCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY, 
    [ysnAssignSaleContract] BIT NULL, 
    [ysnAssignPurchaseContract] BIT NULL,
	[ysnRequireDPContract] BIT NULL,
	[ysnApplyScaleToBasis] BIT NULL,
	[intPriceCalculationTypeId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	[strLotCalculationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnPartialPricing] BIT,
	[ysnPolarization] BIT,
	[strPricingQuantity] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intCleanCostCurrencyId] INT NULL,
	[intCleanCostUOMId] INT NULL,
	CONSTRAINT [PK_tblCTCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC),
	CONSTRAINT [FK_tblCTCompanyPreference_tblSMCurrency_intCleanCostCurrencyId_intCurrencyId] FOREIGN KEY ([intCleanCostCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblICUnitMeasure_intCleanCostUOMId_intUnitMeasureId] FOREIGN KEY ([intCleanCostUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])

)