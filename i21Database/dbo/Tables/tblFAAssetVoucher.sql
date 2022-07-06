CREATE TABLE [dbo].[tblFAAssetVoucher]
(
	[intAssetVoucherId]	INT IDENTITY(1, 1) NOT NULL,
	[intAssetId]		INT NOT NULL,
	[intBillId]			INT NULL,
	[intConcurrencyId]	INT DEFAULT (1) NOT NULL,

	CONSTRAINT [PK_tblFAAssetVoucher] PRIMARY KEY CLUSTERED ([intAssetVoucherId] ASC),
	CONSTRAINT [FK_tblFAAssetVoucher_tblFAFixedAsset] FOREIGN KEY ([intAssetId]) REFERENCES [dbo].[tblFAFixedAsset]([intAssetId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblFAAssetVoucher_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill]([intBillId])
)
