CREATE TABLE [dbo].[tblAPImportVoucherLassusSas]
(
	[strStoreNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSasInvoiceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblAmount] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strNotUsed] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strGLAccount] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDistributionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)
