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
	[dblSubFee1] NUMERIC(18,6) NULL,
	[dblSubFee2] NUMERIC(18,6) NULL,
	[dblSubFee3] NUMERIC(18,6) NULL,
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnValid] BIT NULL,
	[strBatchNumber] NVARCHAR(100) NULL,
	[dblBatchGross] NUMERIC(18,6) NULL,
	[dblBatchNet] NUMERIC(18,6) NULL,
	[dblBatchFee] NUMERIC(18,6) NULL,
    [dblBatchSubFee1] NUMERIC(18,6) NULL,
	[dblBatchSubFee2] NUMERIC(18,6) NULL,
	[dblBatchSubFee3] NUMERIC(18,6) NULL,
	[intSubImportFileHeaderId] INT NULL,
	CONSTRAINT [PK_tblCCImportDealerCreditCardReconDetail] PRIMARY KEY ([intImportDealerCreditCardReconDetailId]),
	CONSTRAINT [FK_tblCCImportDealerCreditCardReconDetail_tblCCImportDealerCreditCardRecon] FOREIGN KEY([intImportDealerCreditCardReconId]) REFERENCES [tblCCImportDealerCreditCardRecon] ([intImportDealerCreditCardReconId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblCCImportDealerCreditCardReconDetail_intImportDealerCreditCardReconId] ON [dbo].[tblCCImportDealerCreditCardReconDetail] ([intImportDealerCreditCardReconId])
GO
