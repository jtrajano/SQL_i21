CREATE TABLE [dbo].[tblCMCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NULL,
	ysnRemittanceAdvice_DisplayVendorAccountNumber BIT NULL,
	ysnRemittanceAdvice_AttachSettlement BIT NULL
)