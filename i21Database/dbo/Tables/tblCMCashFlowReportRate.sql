CREATE TABLE [dbo].[tblCMCashFlowReportRate]
(
	[intCashFlowReportRateId] INT IDENTITY(1, 1) NOT NULL,
	[intCashFlowReportId]		INT NOT NULL,
	[intFilterCurrencyId]		INT NOT NULL,
	[dblRateBucket1]		NUMERIC(18,6) NULL,
	[dblRateBucket2]		NUMERIC(18,6) NULL,
	[dblRateBucket3]		NUMERIC(18,6) NULL,
	[dblRateBucket4]		NUMERIC(18,6) NULL,
	[dblRateBucket5]		NUMERIC(18,6) NULL,
	[dblRateBucket6]		NUMERIC(18,6) NULL,
	[dblRateBucket7]		NUMERIC(18,6) NULL,
	[dblRateBucket8]		NUMERIC(18,6) NULL,
	[dblRateBucket9]		NUMERIC(18,6) NULL,
	[intConcurrencyId]		INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportRate] PRIMARY KEY CLUSTERED ([intCashFlowReportRateId] ASC),
	CONSTRAINT [FK_tblCMCashFlowReportRate_tblCMCashFlowReport] FOREIGN KEY ([intCashFlowReportId]) REFERENCES [dbo].[tblCMCashFlowReport]([intCashFlowReportId]) ON DELETE CASCADE,
)
