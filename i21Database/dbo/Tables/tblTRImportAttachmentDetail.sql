CREATE TABLE [dbo].[tblTRImportAttachmentDetail]
(
	[intImportAttachmentDetailId] INT NOT NULL IDENTITY,
	[intImportAttachmentId] INT NOT NULL,
	[strFileName] NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileExtension] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSupplier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intVendorId] INT NULL,
	[intSupplyPointId] INT NULL,
	[intVendorCompanyLocationId] INT NULL,
	[strBillOfLading] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmLoadDateTime] DATETIME NULL,
	[strMessage] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[ysnValid] BIT,
	[intAttachmentId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	[intLoadHeaderId] INT NULL,
	[strInvoiceId] NVARCHAR(300) NULL,
	[ysnDelete] BIT NULL,
	CONSTRAINT [PK_tblTRImportAttachmentDetail] PRIMARY KEY (intImportAttachmentDetailId),
	CONSTRAINT [FK_tblTRImportAttachmentDetail_tblTRImportAttachment_intImportAttachmentId] FOREIGN KEY ([intImportAttachmentId]) REFERENCES [dbo].[tblTRImportAttachment] ([intImportAttachmentId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblTRImportAttachmentDetail_intImportAttachmentId] ON [dbo].[tblTRImportAttachmentDetail] ([intImportAttachmentId])
GO