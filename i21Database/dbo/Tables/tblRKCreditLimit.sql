CREATE TABLE [dbo].[tblRKCreditLimit] 
(
    [intCreditLimitId] INT IDENTITY(1,1) NOT NULL,
	[intCreditLineId] INT NOT NULL,
	[dblAmountInsurance] NUMERIC(18, 6) NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDateInsuranceFrom] DATETIME NULL, 
	[dtmDateInsuranceTo] DATETIME NULL, 
	[intCreditInsuranceId] INT NOT NULL, 
	[strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPolicyNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKCreditLimit_intCreditLimitId] PRIMARY KEY ([intCreditLimitId]),
	CONSTRAINT [FK_tblRKCreditLimit_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
	CONSTRAINT [FK_tblRKCreditLimit_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID]),
	CONSTRAINT [FK_tblRKCreditLimit_tblRKCreditInsurance_intCreditInsuranceId] FOREIGN KEY (intCreditInsuranceId) REFERENCES tblRKCreditInsurance([intCreditInsuranceId])
)