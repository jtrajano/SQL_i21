CREATE TABLE [dbo].[tblARCompanyPreference]
(
	[intCompanyPreferenceId]		INT NOT NULL PRIMARY KEY IDENTITY, 
    [intARAccountId]				INT NULL, 
    [intDiscountAccountId]			INT NULL,
	[strServiceChargeAccount]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strServiceChargeCalculation]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strServiceChargeFrequency]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT 1
)
