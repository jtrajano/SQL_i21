CREATE TYPE [dbo].[StagingRadiantMCM] AS TABLE(
	[intRowCount] [int] NULL,
	[intMerchandiseCode] [int] NULL,
	[strMerchandiseCodeDescription] [nvarchar](max) NULL,
	[dblDiscountAmount] [numeric](18, 6) NULL,
	[dblDiscountCount] [numeric](18, 6) NULL,
	[dblPromotionAmount] [numeric](18, 6) NULL,
	[dblPromotionCount] [numeric](18, 6) NULL,
	[dblRefundAmount] [numeric](18, 6) NULL,
	[dblRefundCount] [numeric](18, 6) NULL,
	[dblSalesQuantity] [numeric](18, 6) NULL,
	[dblSalesAmount] [numeric](18, 6) NULL,
	[dblTransactionCount] [numeric](18, 6) NULL,
	[dblOpenDepartmentSalesAmount] [numeric](18, 6) NULL,
	[dblOpenDepartmentTransactionCount] [numeric](18, 6) NULL
)