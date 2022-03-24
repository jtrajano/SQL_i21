CREATE TYPE StagingPassportMCM AS TABLE
(
	[intRowCount] 								  INT				NULL,
	[intMerchandiseCode]						  INT				NULL,
	[strMerchandiseCodeDescription]				  NVARCHAR(MAX)		NULL,
	
	[dblDiscountAmount]							  NUMERIC(18,6)     NULL,
	[dblDiscountCount]							  NUMERIC(18,6)     NULL,
	[dblPromotionAmount]						  NUMERIC(18,6)     NULL,
	[dblPromotionCount]							  NUMERIC(18,6)     NULL,
	[dblRefundAmount]							  NUMERIC(18,6)     NULL,
	[dblRefundCount]							  NUMERIC(18,6)     NULL,
	[dblSalesQuantity]							  NUMERIC(18,6)     NULL,
	[dblSalesAmount]							  NUMERIC(18,6)     NULL,
	[dblTransactionCount]						  NUMERIC(18,6)     NULL,
	[dblOpenDepartmentSalesAmount]				  NUMERIC(18,6)     NULL,
	[dblOpenDepartmentTransactionCount]			  NUMERIC(18,6)     NULL
)
