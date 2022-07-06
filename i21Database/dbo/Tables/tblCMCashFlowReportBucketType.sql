﻿CREATE TABLE [dbo].[tblCMCashFlowReportBucketType]
(
	[intCashFlowReportBucketTypeId] INT IDENTITY(1, 1) NOT NULL,
	[strCashFlowReportBucketType]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]				INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMCashFlowReportBucketType] PRIMARY KEY CLUSTERED ([intCashFlowReportBucketTypeId] ASC)
)
