
CREATE TABLE [dbo].[tblGRAPISettlementSubReport](
	intSettlementSubReportId		INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId					uniqueidentifier
	,[intBillDetailId]				[int] NOT NULL,
	[strId]							[nvarchar](50) NULL,
	[intItemId]						[int] NULL,
	[strDiscountCode]				[nvarchar](50) NULL,
	[strDiscountCodeDescription]	[nvarchar](50) NULL,
	[strTaxClass]					[nvarchar](50) NULL,
	[dblDiscountAmount]				[numeric](38, 20) NULL,
	[dblShrinkPercent]				[decimal](24, 10) NULL,
	[dblGradeReading]				[nvarchar](50) NOT NULL,
	[dblAmount]						[decimal](38, 6) NULL,
	[dblTax]						[decimal](38, 6) NULL,
	[dblNetTotal]					[decimal](38, 6) NULL,
	[intId] [int]					NOT NULL
)
