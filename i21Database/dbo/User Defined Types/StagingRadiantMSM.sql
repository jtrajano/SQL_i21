CREATE TYPE [dbo].[StagingRadiantMSM] AS TABLE(
	[intRowCount] [int] NULL,
	[strMiscellaneousSummaryCode] [nvarchar](max) NULL,
	[strMiscellaneousSummarySubCode] [nvarchar](max) NULL,
	[strMiscellaneousSummarySubCodeModifier] [nvarchar](max) NULL,
	[dblMiscellaneousSummaryAmount] [numeric](18, 6) NULL,
	[intMiscellaneousSummaryCount] [int] NULL
)