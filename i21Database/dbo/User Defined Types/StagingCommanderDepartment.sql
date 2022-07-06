CREATE TYPE StagingCommanderDepartment AS TABLE
(
	[intRowCount] [int] NULL,
	[dblDeptInfoGrossSale] [numeric](18, 6) NULL,
	[dblDeptInfoPercentOfSale] [numeric](18, 6) NULL,
	[strSysId] [nvarchar](max) NULL,
	[intNetSaleCount] [int] NULL,
	[dblNetSaleAmount] [numeric](18, 6) NULL,
	[dblNetSaleItemCount] [numeric](18, 6) NULL,
	[intRefundCount] [int] NULL,
	[dblRefundAmount] [numeric](18, 6) NULL,
	[intTotalCount] [int] NULL,
	[dblTotalAmount] [numeric](18, 6) NULL,
	[intPromotionCount] [int] NULL,
	[dblPromotionAmount] [numeric](18, 6) NULL,
	[strCashierName] [nvarchar](max) NULL,
	[dblCashierRefundAmount] [numeric](18, 6) NULL,
	[intCashierRefundCount] [numeric](18, 6) NULL,
	[intCashierSaleCount] [int] NULL,
	[dblCashierSaleAmount] [int] NULL
)

