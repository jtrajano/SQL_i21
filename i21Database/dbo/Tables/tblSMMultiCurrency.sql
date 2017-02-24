CREATE TABLE [dbo].[tblSMMultiCurrency]
(
	[intMultiCurrencyId]							INT NOT NULL PRIMARY KEY IDENTITY,
	[intForexRealizedGainOrLossId]					INT NULL,
	[intForexUnrealizedGainOrLossId]				INT NULL,
	[intForexRevalueOffsetId]						INT NULL,
    [intPurchasingId]								INT NULL,
	[intCashManagementId]							INT NULL,
	[intInventoryId]								INT NULL,
	[intContractId]									INT NULL, 
    [intSalesId]									INT NULL, 
	[intGeneralJournalId]							INT NULL, 
	[ysnRevalue]									BIT NULL DEFAULT 0,
    [intConcurrencyId]								INT NOT NULL DEFAULT 1, 
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_Realized] FOREIGN KEY ([intForexRealizedGainOrLossId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_Unrealized] FOREIGN KEY ([intForexUnrealizedGainOrLossId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_GLAccount_RevalueOffset] FOREIGN KEY ([intForexRevalueOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
    CONSTRAINT [FK_tblSMMultiCurrency_RateType_Purchasing] FOREIGN KEY ([intPurchasingId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_CashManagement] FOREIGN KEY ([intCashManagementId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Inventory] FOREIGN KEY ([intInventoryId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Contract] FOREIGN KEY ([intContractId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Sales] FOREIGN KEY ([intSalesId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_GeneralJournal] FOREIGN KEY ([intGeneralJournalId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
