CREATE TABLE [dbo].[tblRKAcceptableCurrency]
(
	[intAcceptableCurrencyId] INT IDENTITY(1,1) NOT NULL,
	[intCreditLineId] INT NOT NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblHaircut] NUMERIC(18, 6) NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKAcceptableCurrency_intAcceptableCurrencyId] PRIMARY KEY ([intAcceptableCurrencyId]),
	CONSTRAINT [FK_tblRKAcceptableCurrency_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
	CONSTRAINT [FK_tblRKAcceptableCurrency_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID])
)
