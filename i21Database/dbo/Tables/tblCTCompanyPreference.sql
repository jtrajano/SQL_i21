CREATE TABLE [dbo].[tblCTCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY, 
    [ysnAssignSaleContract] BIT NULL, 
    [ysnAssignPurchaseContract] BIT NULL,
	[ysnRequireDPContract] BIT NULL,
	[ysnApplyScaleToBasis] BIT NULL,
	[intPriceCalculationTypeId] INT NULL,
	CONSTRAINT [PK_tblCTCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC), 
)