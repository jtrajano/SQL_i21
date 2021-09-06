CREATE TABLE [dbo].[tblAPImportPaidVouchersForPayment]
(
	[intId] 				INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intCurrencyId] 		INT NOT NULL,
	[intEntityVendorId] 	INT NOT NULL,
	[strEntityVendorName]	NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[dtmDatePaid]       	DATETIME NULL,
	[strStore]          	NVARCHAR (3) COLLATE Latin1_General_CI_AS NULL,
	[strBillId]         	NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorOrderNumber] 	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmBillDate]       	DATETIME NULL,
	[strCheckNumber]		NVARCHAR (55) COLLATE Latin1_General_CI_AS NULL,
	[dblPayment] 			DECIMAL(18, 2) NOT NULL DEFAULT 0, 
	[dblDiscount] 			DECIMAL(18, 2) NULL DEFAULT 0, 
	[dblInterest] 			DECIMAL(18, 2) NULL DEFAULT 0,
	[strNotes] 				NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
	[intCustomPartition]	INT NULL DEFAULT 0
)