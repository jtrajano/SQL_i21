CREATE TABLE [dbo].[tblFAAssetInvoice]
(
	[intAssetInvoiceId]	INT IDENTITY(1, 1) NOT NULL,
	[intAssetId]		INT NOT NULL,
	[intInvoiceId]		INT NULL,
	[intConcurrencyId]	INT DEFAULT (1) NOT NULL,

	CONSTRAINT [PK_tblFAAssetInvoice] PRIMARY KEY CLUSTERED ([intAssetInvoiceId] ASC),
	CONSTRAINT [FK_tblFAAssetInvoice_tblFAFixedAsset] FOREIGN KEY ([intAssetId]) REFERENCES [dbo].[tblFAFixedAsset]([intAssetId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblFAAssetInvoice_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice]([intInvoiceId])
)
