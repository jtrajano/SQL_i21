CREATE TABLE [dbo].[tblPATCustomerVolumeLog]
(
	[intCustomerVolumeLogId] INT NOT NULL IDENTITY,
	[intInvoiceId] INT NULL,
	[intBillId] INT NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[ysnDirectSale] BIT NOT NULL DEFAULT 0,
	[intItemId] INT NULL,
	[dblVolume] NUMERIC(18,6) NOT NULL DEFAULT 0,
	[ysnIsUnposted] BIT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblPATCustomerVolumeLog] PRIMARY KEY ([intCustomerVolumeLogId]),
	CONSTRAINT [FK_tblPATCustomerVolumeLog_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPATCustomerVolumeLog_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblARInvoice]([intInvoiceId]) ON DELETE CASCADE
)