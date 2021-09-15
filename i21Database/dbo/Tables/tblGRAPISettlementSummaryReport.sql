CREATE TABLE [dbo].[tblGRAPISettlementSummaryReport](
	intSettlementSummaryReportId	INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId					uniqueidentifier
	,[intPaymentId]					[int] NOT NULL,
	[strPaymentNo]					[nvarchar](50) NULL,
	[InboundNetWeight]				[decimal](38, 15) NULL,
	[InboundGrossDollars]			[decimal](38, 6) NULL,
	[InboundTax]					[decimal](38, 6) NULL,
	[InboundDiscount]				[decimal](38, 6) NULL,
	[InboundNetDue]					[decimal](38, 6) NULL,
	[OutboundNetWeight]				[int] NOT NULL,
	[OutboundGrossDollars]			[int] NOT NULL,
	[OutboundTax]					[int] NOT NULL,
	[OutboundDiscount]				[int] NOT NULL,
	[OutboundNetDue]				[int] NOT NULL,
	[SalesAdjustment]				[decimal](38, 6) NOT NULL,
	[VoucherAdjustment]				[decimal](38, 6) NULL,
	[dblVendorPrepayment]			[decimal](38, 6) NULL,
	[lblVendorPrepayment]			[varchar](13) NOT NULL,
	[dblCustomerPrepayment]			[decimal](38, 6) NULL,
	[lblCustomerPrepayment]			[varchar](15) NOT NULL,
	[dblGradeFactorTax]				[decimal](38, 6) NULL,
	[lblFactorTax]					[varchar](10) NOT NULL,
	[dblPartialPrepaymentSubTotal]	[decimal](38, 6) NULL,
	[lblPartialPrepayment]			[varchar](20) NOT NULL,
	[dblPartialPrepayment]			[decimal](38, 6) NULL,
	[CheckAmount]					[decimal](18, 6) NOT NULL,
	[intId]							[int] NOT NULL
) 