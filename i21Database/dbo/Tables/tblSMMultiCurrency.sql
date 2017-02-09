﻿CREATE TABLE [dbo].[tblSMMultiCurrency]
(
	[intMultiCurrencyId]							INT NOT NULL PRIMARY KEY IDENTITY,
	[dblRealizedGainOrLossBasis]					NUMERIC(18, 6) NULL,
	[dblRealizedGainOrLossFutures]					NUMERIC(18, 6) NULL,
	[dblRealizedGainOrLossCash]						NUMERIC(18, 6) NULL,
	[dblInventoryOffsetForRealizedGainOrLoss]		NUMERIC(18, 6) NULL,
	[dblUnrealizedGainOrLossBasis]					NUMERIC(18, 6) NULL,
	[dblUnrealizedGainOrLossFutures]				NUMERIC(18, 6) NULL,
	[dblUnrealizedGainOrLossCash]					NUMERIC(18, 6) NULL,
	[dblInventoryOffsetForUnrealizedGainOrLoss]		NUMERIC(18, 6) NULL,
    [intAPVoucherId]								INT NULL,
	[intCMPaymentId]								INT NULL,
	[intInventoryTransactionId]						INT NULL,
	[intAPRevaluationId]							INT NULL, 
    [intContractRevaluationId]						INT NULL, 
    [intARRevaluationId]							INT NULL, 
    [intConcurrencyId]								INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMMultiCurrency_RateType_APVoucher] FOREIGN KEY ([intAPVoucherId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_CMPayment] FOREIGN KEY ([intCMPaymentId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_InventoryTransaction] FOREIGN KEY ([intInventoryTransactionId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_APRevaluation] FOREIGN KEY ([intAPRevaluationId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_ContractRevaluation] FOREIGN KEY ([intContractRevaluationId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblSMMultiCurrency_RateType_ARRevaluation] FOREIGN KEY ([intARRevaluationId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
