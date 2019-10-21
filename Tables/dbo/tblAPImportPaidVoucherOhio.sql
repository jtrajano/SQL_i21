CREATE TABLE [dbo].[tblAPImportPaidVoucherOhio]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intCurrencyId] INT NOT NULL,
	[intEntityVendorId] INT NOT NULL,
	[strBillId]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strNotes] NVARCHAR (1000)  COLLATE Latin1_General_CI_AS NULL,
	[strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
)
