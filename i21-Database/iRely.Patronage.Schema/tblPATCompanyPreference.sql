﻿CREATE TABLE [dbo].[tblPATCompanyPreference]
(
	[intCompanyPreferenceId] INT IDENTITY(1,1) NOT NULL,
	[strRefund] CHAR(1) COLLATE Latin1_General_CI_AS NULL,
	[dblMinimumRefund] NUMERIC(18, 6) NULL,
	[dblServiceFee] NUMERIC(18, 6) NULL,
	[dblCutoffAmount] NUMERIC(18, 6) NULL,
	[strCutoffTo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strPayOnGrain] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strPrintCheck] NVARCHAR(2) COLLATE Latin1_General_CI_AS NULL,
	[intPaymentItemId] INT NULL,
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
    CONSTRAINT [PK_tblPATCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]),
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intVotingStockId_intAccountId] FOREIGN KEY ([intVotingStockId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intNonVotingStockId_intAccountId] FOREIGN KEY ([intNonVotingStockId]) REFERENCES [tblGLAccount]([intAccountId]),	
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intFractionalShareId_intAccountId] FOREIGN KEY ([intFractionalShareId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intServiceFeeIncomeId_intAccountId] FOREIGN KEY ([intServiceFeeIncomeId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intDividendsGLAccount_intAccountId] FOREIGN KEY ([intDividendsGLAccount]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATCompanyPreference_tblGLAccount_intAPClearingGLAccount_intAccountId] FOREIGN KEY ([intAPClearingGLAccount]) REFERENCES [tblGLAccount]([intAccountId])
)