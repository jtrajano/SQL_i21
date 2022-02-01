CREATE TABLE [dbo].[tblCMCashFlowReportSummary]
(
	[intCashFlowReportSummaryId]	INT IDENTITY(1, 1) NOT NULL,
	[dtmReportDate]					DATETIME NOT NULL,
    [intReportingCurrencyId]		INT NULL,
	[intBankAccountId]				INT NULL,
	[intCompanyLocationId]			INT NULL,
    [dblTotal]						NUMERIC(18, 6) NULL,
	[dblBucket1]					NUMERIC(18, 6) NULL, -- Current
	[dblBucket2]					NUMERIC(18, 6) NULL, -- 1 -7
	[dblBucket3]					NUMERIC(18, 6) NULL, -- 8 - 14
	[dblBucket4]					NUMERIC(18, 6) NULL, -- 15 - 21
	[dblBucket5]					NUMERIC(18, 6) NULL, -- 22 - 29
	[dblBucket6]					NUMERIC(18, 6) NULL, -- 30 - 60
	[dblBucket7]					NUMERIC(18, 6) NULL, -- 60 - 90
	[dblBucket8]					NUMERIC(18, 6) NULL, -- 90 - 120
	[dblBucket9]					NUMERIC(18, 6) NULL, -- 120+
	[intCashFlowReportId]			INT NOT NULL,
	[intCashFlowReportSummaryCodeId] INT NOT NULL,
	[intConcurrencyId]				INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportSummary] PRIMARY KEY CLUSTERED ([intCashFlowReportSummaryId] ASC),
	CONSTRAINT [FK_tblCMCashFlowReportSummary_tblCMCashFlowReportSummaryCode] FOREIGN KEY ([intCashFlowReportSummaryCodeId]) REFERENCES [dbo].[tblCMCashFlowReportSummaryCode]([intCashFlowReportSummaryCodeId]),
	CONSTRAINT [FK_tblCMCashFlowReportSummary_tblCMCashFlowReport] FOREIGN KEY ([intCashFlowReportId]) REFERENCES [dbo].[tblCMCashFlowReport]([intCashFlowReportId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCMCashFlowReportSummary_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [FK_tblCMCashFlowReportSummary_tblSMCurrency_Reporting] FOREIGN KEY ([intReportingCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID])
)
