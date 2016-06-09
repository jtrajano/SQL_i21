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
	[intCleanCostCurrencyId] INT NULL,
	[intCleanCostUOMId] INT NULL,
	[strDefaultContractReport] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[ysnDemandViewForBlend] BIT NOT NULL CONSTRAINT [DF_tblCTCompanyPreference_ysnDemandViewForBlend] DEFAULT 0,
	[intEarlyDaysPurchase] INT NULL,
	[intEarlyDaysSales] INT NULL,
	[strDemandItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnBagMarkMandatory] BIT NULL,
	[strESA] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnAutoCreateDP BIT,
	intDefSalespersonId	INT,
	dtmDefEndDate DATETIME,
	[strSignature] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

    CONSTRAINT [PK_tblCTCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC),
	CONSTRAINT [FK_tblCTCompanyPreference_tblSMCurrency_intCleanCostCurrencyId_intCurrencyId] FOREIGN KEY ([intCleanCostCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblICUnitMeasure_intCleanCostUOMId_intUnitMeasureId] FOREIGN KEY ([intCleanCostUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblEMEntity_intDefSalespersonId_intEntityId] FOREIGN KEY (intDefSalespersonId) REFERENCES tblEMEntity(intEntityId)

)