CREATE TABLE [dbo].[tblCMCashFlowReport]
(
	[intCashFlowReportId]		INT IDENTITY(1,1) NOT NULL,
	[strDescription]			NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateGenerated]			DATETIME DEFAULT(GETDATE()) NULL,
	[dtmReportDate]				DATETIME NOT NULL,
	[intFilterCurrencyId]		INT NULL,
	[intReportingCurrencyId]	INT NULL,
	[intBankId]					INT NULL,
	[intBankAccountId]			INT NULL,
	[intCompanyLocationId]		INT NULL,
	[intEntityId]				INT NULL,
	[intConcurrencyId]			INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReport] PRIMARY KEY CLUSTERED ([intCashFlowReportId] ASC),
	CONSTRAINT [FK_tblCMCashFlowReport_tblCMBank] FOREIGN KEY ([intBankId]) REFERENCES [dbo].[tblCMBank]([intBankId]),
	CONSTRAINT [FK_tblCMCashFlowReport_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [FK_tblCMCashFlowReport_tblSMCurrency_Filter] FOREIGN KEY ([intFilterCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCMCashFlowReport_tblSMCurrency_Reporting] FOREIGN KEY ([intReportingCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCMCashFlowReport_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation]([intCompanyLocationId])
)
