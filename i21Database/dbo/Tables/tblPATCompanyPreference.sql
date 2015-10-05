﻿CREATE TABLE [dbo].[tblPATCompanyPreference](
	[intCompanyPreferenceId] [int] IDENTITY(1,1) NOT NULL,
	[intYearEnd] [int] NULL,
	[intGrainDiscountId] [int] NULL,
	[intGrainStorageId] [int] NULL,
	[intServiceChargeId] [int] NULL,
	[intDebitMemoId] int NULL,
	[intDiscountGivenId] int NULL,
	[strRefund] [char](1) COLLATE Latin1_General_CI_AS NULL,
	[dblMinimumRefund] [numeric](18, 6) NULL,
	[dblServiceFee] [numeric](18, 6) NULL,
	[dblCutoffAmount] [numeric](18, 6) NULL,
	[strCutoffTo] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strPayOnGrain] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[dblFederalBackup] [numeric](18, 6) NULL,
	[intCheckbookAccountId] [int] NULL,
	[strPrintCheck] [nvarchar](2) COLLATE Latin1_General_CI_AS NULL,
	[dblMinimumDividends] [numeric](18, 6) NULL,
	[ysnProRatedDividends] [bit] NULL,
	[dtmCutoffDate] [datetime] NULL,
	[intVotingStockId] [int] NULL,
	[intNonVotingStockId] [int] NULL,
	[intFractionalShareId] [int] NULL,
	[intServiceFeeIncomeId] [int] NULL,
	[intFWTLiabilityAccountId] [int] NULL,
	[intDividendsGLAccount] [int] NULL,
	[intTreasuryGLAccount] [int] NULL,
	[intConcurrencyId] [int] NULL, 
    CONSTRAINT [PK_tblPATCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId])
	)