﻿CREATE TABLE [dbo].[tblCTCompanyPreference]
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
	CONSTRAINT [PK_tblCTCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
)