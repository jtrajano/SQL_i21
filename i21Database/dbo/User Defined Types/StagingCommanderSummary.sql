CREATE TYPE StagingCommanderSummary AS TABLE
(
	[intRowCount] [int] NULL,
	[strSysId] [nvarchar](max) NULL,
	[dblMopInfoAmount] [numeric](18, 6) NULL,
	[dblMopInfoCount] [numeric](18, 6) NULL,
	[dblSummaryInfoCustomerCount] [int] NULL,
	[dblSummaryInfoTotalSalesTaxes] [numeric](18, 6) NULL,
	[dblSummaryInfoNoSaleCount] [numeric](18, 6) NULL,
	[dblSummaryInfoTotalPaymentOut] [int] NULL,
	[strCashier] [nvarchar](max) NULL,
	[dblCashierTotalPaymentOption] [numeric](18, 6) NULL,
	[dblCashierVoidLineNumberOfVoids] [numeric](18, 6) NULL,
	[dblCashierVoidLineAmountOfVoids] [numeric](18, 6) NULL,
	[dblCashierSummaryInfoNumberOfOverrides] [numeric](18, 6) NULL,
	[dblCashierSummaryInfoNumberOfCustomerCount] [numeric](18, 6) NULL,
	[dblTotalDeposit] [numeric](18, 6) NULL
)