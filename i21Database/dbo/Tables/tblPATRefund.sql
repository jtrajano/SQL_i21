﻿CREATE TABLE [dbo].[tblPATRefund](
		[intRefundId] [int] NOT NULL IDENTITY,
		[intFiscalYearId] [int] NULL,
		[dtmRefundDate] [datetime] NULL,
		[strRefund] [char](1) COLLATE Latin1_General_CI_AS NULL,
		[dblMinimumRefund] [numeric](18, 6) NULL,
		[dblServiceFee] [numeric](18, 6) NULL,
		[dblCashCutoffAmount] [numeric](18, 6) NULL,
		[dblFedWithholdingPercentage] [numeric](18, 6) NULL,
		[strDescription] [nvarchar](max) NULL,
		[ysnPosted] BIT NULL DEFAULT 0,
		[ysnVoucherProcessed] BIT NULL DEFAULT 0,
		[ysnPrinted] BIT NULL DEFAULT 0,
		[intConcurrencyId] [int] NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefund] PRIMARY KEY ([intRefundId])
	)