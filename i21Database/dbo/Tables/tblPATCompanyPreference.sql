CREATE TABLE [dbo].[tblPATCompanyPreference]
(
	[intCompanyPreferenceId] INT IDENTITY(1,1) NOT NULL,
	[strRefund] CHAR(1) COLLATE Latin1_General_CI_AS NULL,
	[dblMinimumRefund] NUMERIC(18, 6) NULL,
	[dblServiceFee] NUMERIC(18, 6) NULL,
	[dblCutoffAmount] NUMERIC(18, 6) NULL,
	[strCutoffTo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strPayOnGrain] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[dblMinimumDividends] NUMERIC(18, 6) NULL,
	[ysnProRatedDividends] BIT NULL,
	[dtmCutoffDate] DATETIME NULL,
	[intVotingStockId] INT NULL,
	[intNonVotingStockId] INT NULL,
	[intFractionalShareId] INT NULL,
	[intServiceFeeIncomeId] INT NULL,
	[intDividendsGLAccount] INT NULL,
	[intAPClearingGLAccount] INT NULL,
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblPATCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId])
)