CREATE TYPE StagingCommanderSummary AS TABLE
(
	[intRowCount] 								INT					NULL,
	[strSysId] 								    NVARCHAR(MAX)		NULL,
	[dblMopInfoAmount]                     		NUMERIC(18,6)		NULL,
	[dblMopInfoCount]                  			NUMERIC(18,6)		NULL,
	[dblSummaryInfoCustomerCount]               INT					NULL,
	[dblSummaryInfoTotalSalesTaxes]             NUMERIC(18,6)		NULL,
	[dblSummaryInfoNoSaleCount]                 NUMERIC(18,6)		NULL,
	[dblSummaryInfoTotalPaymentOut]				INT					NULL
)