CREATE TABLE [dbo].[tblCCImportDealerCreditCardRecon]
(
	[intImportDealerCreditCardReconId] INT NOT NULL IDENTITY,
	[guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
	[intImportFileHeaderId] INT NOT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME NOT NULL,
	[intVendorDefaultId] INT NOT NULL, 
    CONSTRAINT [PK_tblCCImportDealerCreditCardRecon] PRIMARY KEY ([intImportDealerCreditCardReconId]),
	CONSTRAINT [FK_tblCCImportDealerCreditCardRecon_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId]),
	CONSTRAINT [FK_tblCCImportDealerCreditCardRecon_tblCCVendorDefault] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [tblCCVendorDefault]([intVendorDefaultId])
)
GO

CREATE INDEX [IX_tblCCImportDealerCreditCardRecon_guidImportIdentifier] ON [dbo].[tblCCImportDealerCreditCardRecon] ([guidImportIdentifier])
GO