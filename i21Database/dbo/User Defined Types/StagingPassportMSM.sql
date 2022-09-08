CREATE TYPE StagingPassportMSM AS TABLE
(
	[intRowCount] 										  INT				NULL,
	[strCashierId]										  NVARCHAR(MAX)		NULL,
	[strMiscellaneousSummaryCode]                         NVARCHAR(MAX)		NULL,
	[strMiscellaneousSummarySubCode]					  NVARCHAR(MAX)		NULL,
	[strMiscellaneousSummarySubCodeModifier] 			  NVARCHAR(MAX)		NULL,
	[dblMiscellaneousSummaryAmount]                       NUMERIC(18,6)     NULL,
	[dblMiscellaneousSummaryCount]                        NUMERIC(18,6)				NULL
)
