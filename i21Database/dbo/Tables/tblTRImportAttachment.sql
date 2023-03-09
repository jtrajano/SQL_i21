CREATE TABLE [dbo].[tblTRImportAttachment]
(
	[intImportAttachmentId] INT NOT NULL IDENTITY,
	[guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
	[dtmImportDate] DATETIME2 NULL,
	[intUserId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	[strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblTRImportAttachment] PRIMARY KEY (intImportAttachmentId)
)
GO