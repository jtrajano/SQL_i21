CREATE TABLE [dbo].[tblPATCustomerVolumeLog]
(
	[intCustomerVolumeLogId] INT NOT NULL IDENTITY,
	[intTransactionId] INT NOT NULL,
	[strTransactionNo] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[strPurchaseSale] NVARCHAR(10),
	[dblVolume] NUMERIC(18,6) NOT NULL DEFAULT 0,
	[ysnIsUnposted] BIT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblPATCustomerVolumeLog] PRIMARY KEY ([intCustomerVolumeLogId])
)