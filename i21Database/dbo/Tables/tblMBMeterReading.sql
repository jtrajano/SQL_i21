CREATE TABLE [dbo].[tblMBMeterReading]
(
	[intMeterReadingId] INT NOT NULL IDENTITY, 
    [strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intMeterAccountId] INT NOT NULL,
    [dtmTransaction] DATETIME NOT NULL DEFAULT (GETDATE()), 
	[strInvoiceComment] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInvoiceId] INT NULL,
	[ysnPosted] BIT NULL DEFAULT((0)),
	[dtmPostedDate] DATETIME NULL,
	[intEntityId] INT NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterReading] PRIMARY KEY ([intMeterReadingId]), 
    CONSTRAINT [AK_tblMBMeterReading_strTransactionId] UNIQUE ([strTransactionId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblMBMeterAccount] FOREIGN KEY ([intMeterAccountId]) REFERENCES [tblMBMeterAccount]([intMeterAccountId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblARInvoice]([intInvoiceId])
)
