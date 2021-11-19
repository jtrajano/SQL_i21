CREATE TABLE [dbo].[tblCMCashFlowReportBucketType]
(
	[intCashFlowReportBucketTypeId] INT IDENTITY(1, 1) NOT NULL,
	[strCashFlowReportBucketType]	NVARCHAR(100) NOT NULL,
	[intConcurrencyId]				INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportBucketType] PRIMARY KEY CLUSTERED ([intCashFlowReportBucketTypeId] ASC)
)
