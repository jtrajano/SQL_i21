CREATE TYPE StagingCommanderCashier AS TABLE
(
	[intRowCount] [int] NULL,
	[strCashierName] [nvarchar](max) NULL,
	[dblCashierRefundAmount] [numeric](18, 6) NULL,
	[intCashierRefundCount] [numeric](18, 6) NULL,
	[intCashierSaleCount] [int] NULL,
	[dblCashierSaleAmount] [int] NULL
)

