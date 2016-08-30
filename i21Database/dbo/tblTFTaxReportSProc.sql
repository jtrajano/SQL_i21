CREATE TABLE [dbo].[tblTFTaxReportSProc](
	[intSPId] [int] IDENTITY(1,1) NOT NULL,
	[strSPFormCode] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSPInventory] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSPInvoice] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSPGenerateReport] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFTaxReportSProc] ADD  CONSTRAINT [DF_tblTFTaxReportSProc_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO