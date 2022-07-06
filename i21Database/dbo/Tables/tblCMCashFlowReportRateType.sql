CREATE TABLE [dbo].[tblCMCashFlowReportRateType]
(
	[intCashFlowReportRateTypeId] INT IDENTITY(1, 1) NOT NULL,
	[intCashFlowReportId]		INT NOT NULL,
	[intFilterCurrencyId]		INT NOT NULL,
	[intRateTypeBucket1]		INT NULL,
	[intRateTypeBucket2]		INT NULL,
	[intRateTypeBucket3]		INT NULL,
	[intRateTypeBucket4]		INT NULL,
	[intRateTypeBucket5]		INT NULL,
	[intRateTypeBucket6]		INT NULL,
	[intRateTypeBucket7]		INT NULL,
	[intRateTypeBucket8]		INT NULL,
	[intRateTypeBucket9]		INT NULL,
	[intConcurrencyId]			INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportRateType] PRIMARY KEY CLUSTERED ([intCashFlowReportRateTypeId] ASC),
	CONSTRAINT [FK_tblCMCashFlowReportRateType_tblCMCashFlowReport] FOREIGN KEY ([intCashFlowReportId]) REFERENCES [dbo].[tblCMCashFlowReport]([intCashFlowReportId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrency] FOREIGN KEY ([intFilterCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket1] FOREIGN KEY ([intRateTypeBucket1]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket2] FOREIGN KEY ([intRateTypeBucket2]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket3] FOREIGN KEY ([intRateTypeBucket3]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket4] FOREIGN KEY ([intRateTypeBucket4]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket5] FOREIGN KEY ([intRateTypeBucket5]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket6] FOREIGN KEY ([intRateTypeBucket6]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket7] FOREIGN KEY ([intRateTypeBucket7]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket8] FOREIGN KEY ([intRateTypeBucket8]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
    CONSTRAINT [FK_tblCMCashFlowReportRateType_tblSMCurrencyExchangeRateTypeBucket9] FOREIGN KEY ([intRateTypeBucket9]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
