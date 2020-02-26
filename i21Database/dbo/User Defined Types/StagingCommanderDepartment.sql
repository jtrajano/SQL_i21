CREATE TYPE StagingCommanderDepartment AS TABLE
(
	[intRowCount] 								INT					NULL,
	[dblDeptInfoGrossSale]                     	NUMERIC(18,6)		NULL,
	[dblDeptInfoPercentOfSale]                  NUMERIC(18,6)		NULL,
	[strSysId] 								    NVARCHAR(MAX)		NULL,
	[intNetSaleCount]                           INT					NULL,
	[dblNetSaleAmount]                          NUMERIC(18,6)		NULL,
	[dblNetSaleItemCount]                       NUMERIC(18,6)		NULL,
	[intRefundCount]							INT					NULL,
	[dblRefundAmount]                           NUMERIC(18,6)		NULL,
	[intTotalCount]                             INT					NULL,
	[dblTotalAmount]                            NUMERIC(18,6)		NULL,
	[intPromotionCount]                         INT					NULL,
	[dblPromotionAmount]                        NUMERIC(18,6)		NULL
)

