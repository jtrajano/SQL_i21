CREATE TABLE [dbo].[tblSMMultiCurrency]
(
	[intMultiCurrencyId]							INT NOT NULL PRIMARY KEY IDENTITY,
	[intForexRealizedGainOrLossId]					INT NULL,
	[intForexUnrealizedGainOrLossId]				INT NULL,
	[intForexRevalueOffsetId]						INT NULL,
    [intAccountsPayableId]								INT NULL,
	[intCashManagementId]							INT NULL,
	[intInventoryId]								INT NULL,
	[intContractId]									INT NULL, 
    [intAccountsReceivableId]									INT NULL, 
	[intGeneralJournalId]							INT NULL, 
	[ysnRevalue]									BIT NULL DEFAULT 0,
    [intConcurrencyId]								INT NOT NULL DEFAULT 1, 
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_Realized] FOREIGN KEY ([intForexRealizedGainOrLossId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_Unrealized] FOREIGN KEY ([intForexUnrealizedGainOrLossId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_RevalueOffset] FOREIGN KEY ([intForexRevalueOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
    CONSTRAINT [FK_tblSMMultiCurrency_RateType_AccountsPayable] FOREIGN KEY ([intAccountsPayableId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_CashManagement] FOREIGN KEY ([intCashManagementId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Inventory] FOREIGN KEY ([intInventoryId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Contract] FOREIGN KEY ([intContractId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_AccountsReceivable] FOREIGN KEY ([intAccountsReceivableId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_GeneralJournal] FOREIGN KEY ([intGeneralJournalId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
