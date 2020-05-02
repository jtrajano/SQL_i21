CREATE TABLE [dbo].[tblCMCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NULL,
	[ysnImportBankTransFromBankStmnt] BIT NULL
)