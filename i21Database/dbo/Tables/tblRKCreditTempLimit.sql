CREATE TABLE [dbo].[tblRKCreditTempLimit] 
(
    [intCreditTempLimitId] INT IDENTITY(1,1) NOT NULL,
	[intCreditLineId] INT NOT NULL,
	[dblTempAmount] NUMERIC(18, 6) NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmTempDateFrom] DATETIME NULL, 
	[dtmTempDateTo] DATETIME NULL, 
	[intCreditInsuranceId] INT NOT NULL, 
	[strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPolicyNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKCreditTempLimit_intCreditTempLimitId] PRIMARY KEY ([intCreditTempLimitId]),
	CONSTRAINT [FK_tblRKCreditTempLimit_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
	CONSTRAINT [FK_tblRKCreditTempLimit_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID]),
	CONSTRAINT [FK_tblRKCreditTempLimit_tblRKCreditInsurance_intCreditInsuranceId] FOREIGN KEY (intCreditInsuranceId) REFERENCES tblRKCreditInsurance([intCreditInsuranceId])
)