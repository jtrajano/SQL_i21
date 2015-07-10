CREATE TABLE [dbo].[tblNRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY, 
    [dblFee] DECIMAL(18, 6) NULL, 
    [intNotesReceivableAccountId] INT NULL, 
    [intClearingAccountId] INT NULL, 
    [intNotesWriteOffAccountId] INT NULL, 
    [intInterestIncomeAccountId] INT NULL, 
    [intScheduledInvoiceAccountId] INT NULL, 
    [intScheduledInvoiceLateFeeAccountId] INT NULL, 
    [intCashAccountId] INT NULL, 
    [intBankAccountId] INT NULL, 
    [blnContinueInterestCalculationAfterNoteMaturityDate] BIT NULL, 
    [intNumberofDaysPriorNoteBeGenerated] INT NULL, 
    [blnOriginCompatible] BIT NULL, 
    [strOriginSystem] NVARCHAR(50) NULL, 
    [strVersionNumber] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1	,
	CONSTRAINT [PK_tblNRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
)
