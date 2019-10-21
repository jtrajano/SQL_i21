﻿CREATE TABLE [dbo].[tblSMMultiCurrency]
(
	[intMultiCurrencyId]							INT NOT NULL PRIMARY KEY IDENTITY,
	/* Default Rate Types*/
	[intAccountsPayableRateTypeId]					INT NULL,
	[intCashManagementRateTypeId]					INT NULL,
	[intInventoryRateTypeId]						INT NULL,
	[intContractRateTypeId]							INT NULL, 
    [intAccountsReceivableRateTypeId]				INT NULL, 
	[intGeneralJournalRateTypeId]					INT NULL, 
	/* Unrealized */
	[intAccountsPayableUnrealizedId]				INT NULL,
	[intAccountsReceivableUnrealizedId]				INT NULL, 
	[intInventoryUnrealizedId]						INT NULL,
	[intContractPurchaseUnrealizedId]				INT NULL, 
	[intContractSaleUnrealizedId]					INT NULL, 
    [intCashManagementUnrealizedId]					INT NULL,
	[intRiskManagementBasisUnrealizedId]			INT NULL,
	[intRiskManagementFutureUnrealizedId]			INT NULL,
	[intRiskManagementCashUnrealizedId]				INT NULL,
	/* Offset */
	[ysnRevalue]									BIT NULL DEFAULT 0,
	[intAccountsPayableOffsetId]					INT NULL,
	[intAccountsReceivableOffsetId]					INT NULL, 
	[intInventoryOffsetId]							INT NULL,
	[intContractPurchaseOffsetId]					INT NULL, 
	[intContractSaleOffsetId]						INT NULL, 
    [intCashManagementOffsetId]						INT NULL,
	[intRiskManagementBasisOffsetId]				INT NULL,
	[intRiskManagementFutureOffsetId]				INT NULL,
	[intRiskManagementCashOffsetId]					INT NULL,
	/* Offset */
	[intAccountsPayableRealizedId]					INT NULL,
	[intAccountsReceivableRealizedId]				INT NULL, 	
    [intConcurrencyId]								INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMMultiCurrency_RateType_AccountsPayable] FOREIGN KEY ([intAccountsPayableRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_CashManagement] FOREIGN KEY ([intCashManagementRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Inventory] FOREIGN KEY ([intInventoryRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_Contract] FOREIGN KEY ([intContractRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_AccountsReceivable] FOREIGN KEY ([intAccountsReceivableRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_GeneralJournal] FOREIGN KEY ([intGeneralJournalRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_AccountsPayable] FOREIGN KEY ([intAccountsPayableUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_AccountsReceivable] FOREIGN KEY ([intAccountsReceivableUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_Inventory] FOREIGN KEY ([intInventoryUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_ContractPurchase] FOREIGN KEY ([intContractPurchaseUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_ContractSale] FOREIGN KEY ([intContractSaleUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_CashManagement] FOREIGN KEY ([intCashManagementUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_RiskManagemenBasis] FOREIGN KEY ([intRiskManagementBasisUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_RiskManagementFuture] FOREIGN KEY ([intRiskManagementFutureUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Unrealized_RiskManagementCash] FOREIGN KEY ([intRiskManagementCashUnrealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_AccountsPayable] FOREIGN KEY ([intAccountsPayableOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_AccountsReceivable] FOREIGN KEY ([intAccountsReceivableOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_Inventory] FOREIGN KEY ([intInventoryOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_ContractPurchase] FOREIGN KEY ([intContractPurchaseOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_ContractSale] FOREIGN KEY ([intContractSaleOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_CashManagement] FOREIGN KEY ([intCashManagementOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_RiskManagemenBasis] FOREIGN KEY ([intRiskManagementBasisOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_RiskManagementFuture] FOREIGN KEY ([intRiskManagementFutureOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Offset_RiskManagementCash] FOREIGN KEY ([intRiskManagementCashOffsetId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Realized_RiskManagementFuture] FOREIGN KEY ([intAccountsPayableRealizedId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblSMMultiCurrency_Realized_RiskManagementCash] FOREIGN KEY ([intAccountsReceivableRealizedId]) REFERENCES [tblGLAccount]([intAccountId])
)
