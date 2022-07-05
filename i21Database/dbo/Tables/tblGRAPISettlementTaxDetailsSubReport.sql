CREATE TABLE [dbo].[tblGRAPISettlementTaxDetailsSubReport](
	intSettlementTaxDetailsSubReportId	INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId						uniqueidentifier
	,[strBillId]						[nvarchar](50)   COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass]						[nvarchar](50)   COLLATE Latin1_General_CI_AS NULL,
	[dblTax]							[numeric](38, 6) ,
	[intInventoryReceiptItemId]			[int] NOT NULL,
	[intContractDetailId]				[int] NOT NULL,
	[strItemNo]							[nvarchar](50)  COLLATE Latin1_General_CI_AS  NULL,
	[intBillDetailId]					[int] NOT NULL,
	[intId]								[int] NOT NULL
)