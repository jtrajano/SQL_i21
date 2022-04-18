CREATE TABLE [dbo].[tblRKInternalLimit] 
(
    [intInternalLimitId] INT IDENTITY(1,1) NOT NULL,
	[intCreditLineId] INT NOT NULL,
	[dblAmount] NUMERIC(18, 6) NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDateFrom] DATETIME NULL, 
	[dtmDateTo] DATETIME NULL, 
	[strInternalRemarks] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKInternalLimit_intInternalLimitId] PRIMARY KEY ([intInternalLimitId]),
	CONSTRAINT [FK_tblRKInternalLimit_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
	CONSTRAINT [FK_tblRKInternalLimit_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID]),
)