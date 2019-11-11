CREATE TABLE [dbo].[tblTRImportDtnDetail]
(
    [intImportDtnDetailId] INT NOT NULL IDENTITY,
    [intImportDtnId] INT NOT NULL,
	[strDtnNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityVendorId] INT NULL,
    [strSeller] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [dtmInvoiceDate] DATETIME NULL,
    [strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblInvoiceAmount] NUMERIC(18,6) NULL,
    [intTermId] INT NULL,
    [strTerm] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dtmDueDate] DATETIME NULL,
	[intInventoryReceiptId] INT NULL,
	[intBillId] INT NULL,
    [ysnValid] BIT,
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),	
    CONSTRAINT [PK_tblTRImportDtnDetail] PRIMARY KEY ([intImportDtnDetailId]),
	CONSTRAINT [FK_tblTRImportDtnDetail_tblTRImportDtn_intImportDtnId] FOREIGN KEY ([intImportDtnId]) REFERENCES [dbo].[tblTRImportDtn] ([intImportDtnId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTRImportDtnDetail_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_tblTRImportDtnDetail_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId])
)
GO

CREATE INDEX [IX_tblTRImportDtnDetail_intImportDtnId] ON [dbo].[tblTRImportDtnDetail] ([intImportDtnId])
GO
