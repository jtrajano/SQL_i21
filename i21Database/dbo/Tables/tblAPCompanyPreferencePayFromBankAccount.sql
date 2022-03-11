CREATE TABLE [dbo].[tblAPCompanyPreferencePayFromBankAccount]
(
	[intCompanyPreferencePayFromBankAccountId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intCompanyPreferenceId] INT NOT NULL,
	[intCurrencyId] INT NOT NULL,
    [intPayFromBankAccountId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT(0),
	CONSTRAINT [FK_tblAPCompanyPreferencePayFromBankAccount_tblAPCompanyPreference_intCompanyPreferenceId] FOREIGN KEY ([intCompanyPreferenceId]) REFERENCES tblAPCompanyPreference ([intCompanyPreferenceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPCompanyPreferencePayFromBankAccount_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES tblSMCurrency([intCurrencyID])
)