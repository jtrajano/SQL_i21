CREATE TABLE [dbo].[tblRKComplementaryLimit] 
(
    [intComplementaryLimitId] INT IDENTITY(1,1) NOT NULL,
	[intCreditLineId] INT NOT NULL,
	[dblTopOffAmount] NUMERIC(18, 6) NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmTopOffDateFrom] DATETIME NULL, 
	[dtmTopOffDateTo] DATETIME NULL, 
	[intCreditInsuranceId] INT NOT NULL, 
	[strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPolicyNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKComplementaryLimit_intComplementaryLimitId] PRIMARY KEY ([intComplementaryLimitId]),
	CONSTRAINT [FK_tblRKComplementaryLimit_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
	CONSTRAINT [FK_tblRKComplementaryLimit_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID]),
	CONSTRAINT [FK_tblRKComplementaryLimit_tblRKCreditInsurance_intCreditInsuranceId] FOREIGN KEY (intCreditInsuranceId) REFERENCES tblRKCreditInsurance([intCreditInsuranceId])
)