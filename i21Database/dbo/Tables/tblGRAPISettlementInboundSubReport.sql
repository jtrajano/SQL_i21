﻿
CREATE TABLE [dbo].[tblGRAPISettlementInboundSubReport](
	intSettlementInboundSubReportId		INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId						uniqueidentifier
	,[intPaymentId]						[int] NOT NULL,
	[strDiscountCode]					[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDiscountCodeDescription]		[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[WeightedAverageReading]			[decimal](38, 6) NULL,
	[WeightedAverageShrink]				[decimal](38, 6) NULL,
	[Discount]							[decimal](38, 6) NULL,
	[Amount]							[decimal](38, 6) NULL,
	[Tax]								[decimal](38, 6) NULL,
	[intId]								[int] NOT NULL
)