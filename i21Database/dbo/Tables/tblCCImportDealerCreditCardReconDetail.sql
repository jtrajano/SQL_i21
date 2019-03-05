CREATE TABLE [dbo].[tblCCImportDealerCreditCardReconDetail]
(
	[intImportDealerCreditCardReconDetailId] INT NOT NULL IDENTITY,
	[intImportDealerCreditCardReconId] INT NOT NULL,
	[intSiteId] INT NULL,
	[strSiteNumber] NVARCHAR(100) NOT NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[dblGross] NUMERIC(18,6) NULL,
	[dblNet] NUMERIC(18,6) NULL,
	[dblFee] NUMERIC(18,6) NULL,
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnValid] BIT NULL, 
    CONSTRAINT [PK_tblCCImportDealerCreditCardReconDetail] PRIMARY KEY ([intImportDealerCreditCardReconDetailId]),
	CONSTRAINT [FK_tblCCImportDealerCreditCardReconDetail_tblCCImportDealerCreditCardRecon] FOREIGN KEY([intImportDealerCreditCardReconId]) REFERENCES [tblCCImportDealerCreditCardRecon] ([intImportDealerCreditCardReconId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblCCImportDealerCreditCardReconDetail_intImportDealerCreditCardReconId] ON [dbo].[tblCCImportDealerCreditCardReconDetail] ([intImportDealerCreditCardReconId])
GO
