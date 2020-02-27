CREATE TABLE [dbo].[tblAPImportVoucherLassusSas]
(
	[strStoreNumber] NVARCHAR(200) NOT NULL,
	[dtmDate] NVARCHAR(100) NOT NULL,
	[strSasInvoiceNumber] NVARCHAR(100) NULL,
	[strInvoiceNumber] NVARCHAR(100) NOT NULL,
	[dblAmount] NVARCHAR(500) NOT NULL,
	[strNotUsed] NVARCHAR(100) NULL,
	[strGLAccount] NVARCHAR(100) NOT NULL,
	[strDistributionType] NVARCHAR(50) NOT NULL
)
