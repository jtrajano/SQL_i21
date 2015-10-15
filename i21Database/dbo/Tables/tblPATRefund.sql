CREATE TABLE [dbo].[tblPATRefund](
		[intRefundId] [int] NOT NULL,
		[intFiscalYearId] [int] NULL,
		[dtmRefundDate] [datetime] NULL,
		[strRefund] [char](1) NULL,
		[dblMinimumRefund] [numeric](18, 6) NULL,
		[dblServiceFee] [numeric](18, 6) NULL,
		[dblCashCutoffAmount] [numeric](18, 6) NULL,
		[dblFedWithholdingPercentage] [numeric](18, 6) NULL,
		[intConcurrencyId] [int] NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefund] PRIMARY KEY ([intRefundId])
	)