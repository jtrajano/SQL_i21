﻿CREATE TABLE [dbo].[tblCMCashFlowReportSummaryDetail]
(
	[intCashFlowReportSummaryDetailId]	INT IDENTITY(1, 1) NOT NULL,
	[intCashFlowReportId]				INT NULL,
	[intCashFlowReportSummaryId]		INT NULL,
	[intTransactionId]					INT NOT NULL,
	[strTransactionId]					NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType]				NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate]				DATETIME NULL,
	[dblBucket1]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket2]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket3]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket4]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket5]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket6]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket7]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket8]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblBucket9]						NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[intCurrencyId]						INT NULL,
	[intReportingCurrencyId]			INT NULL,
	[intCurrencyExchangeRateTypeId]		INT NULL,
	[dblRate]							NUMERIC(18, 6) NOT NULL DEFAULT(1),
	[intAccountId]						INT NULL,
	[intBankAccountId]					INT NULL,
	[intCompanyLocationId]				INT NULL,
	[intConcurrencyId]					INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportSummaryDetail] PRIMARY KEY CLUSTERED ([intCashFlowReportSummaryDetailId] ASC),
	CONSTRAINT [FK_tblCMCashFlowReportSummaryDetail_tblCMCashFlowReport] FOREIGN KEY([intCashFlowReportId]) REFERENCES [dbo].[tblCMCashFlowReport]([intCashFlowReportId]),
	CONSTRAINT [FK_tblCMCashFlowReportSummaryDetail_tblCMCashFlowReportSummary] FOREIGN KEY([intCashFlowReportSummaryId]) REFERENCES [dbo].[tblCMCashFlowReportSummary]([intCashFlowReportSummaryId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCMCashFlowReportSummaryDetail_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCMCashFlowReportSummaryDetail_tblSMCurrency_Reporting] FOREIGN KEY([intReportingCurrencyId]) REFERENCES [dbo].[tblSMCurrency](intCurrencyID),
	CONSTRAINT [FK_tblCMCashFlowReportSummaryDetail_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
