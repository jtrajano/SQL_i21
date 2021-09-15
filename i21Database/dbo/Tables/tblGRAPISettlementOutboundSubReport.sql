CREATE TABLE [dbo].[tblGRAPISettlementOutboundSubReport](
	intSettlementOutboundSubReportId	INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId						uniqueidentifier
	,[intPaymentId]						[int] NOT NULL,
	[strDiscountCode]					[nvarchar](50) NULL,
	[strDiscountCodeDescription]		[nvarchar](50) NOT NULL,
	[WeightedAverageReading]			[decimal](38, 6) NULL,
	[WeightedAverageShrink]				[decimal](38, 6) NULL,
	[Discount]							[numeric](38, 6) NULL,
	[Amount]							[numeric](38, 6) NULL,
	[Tax]								[numeric](38, 6) NULL,
	[intId]								[int] NOT NULL
)