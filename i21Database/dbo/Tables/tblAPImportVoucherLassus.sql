CREATE TABLE [dbo].[tblAPImportVoucherLassus]
(
	[strIdentity] CHAR(1) NOT NULL,
	[strInvoiceNumber] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intVoucherType] TINYINT,
	[strReference] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVendorId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblTotal] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDateOrAccount] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDetailInfo] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[dblDebit] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[dblCredit] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription] NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL
)
GO