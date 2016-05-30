﻿CREATE TABLE [dbo].[tblPATCompanyPreference](
	[intCompanyPreferenceId] [int] IDENTITY(1,1) NOT NULL,
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
	[intAPClearingGLAccount] [int] NULL,
	[intConcurrencyId] [int] NULL, 
    CONSTRAINT [PK_tblPATCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]),
	CONSTRAINT [FK_tblPATCompanyPreference_GrainDisc] FOREIGN KEY ([intGrainDiscountId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]),
	CONSTRAINT [FK_tblPATCompanyPreference_GrainStorage] FOREIGN KEY ([intGrainStorageId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]),
	CONSTRAINT [FK_tblPATCompanyPreference_ServiceCharge] FOREIGN KEY ([intServiceChargeId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]),
	CONSTRAINT [FK_tblPATCompanyPreference_DebitMemo] FOREIGN KEY ([intDebitMemoId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]),
	CONSTRAINT [FK_tblPATCompanyPreference_DiscGiven] FOREIGN KEY ([intDiscountGivenId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId])
	)