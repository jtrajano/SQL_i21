CREATE TABLE [dbo].[tblSMDocument] (
    [intDocumentId]				INT             IDENTITY (1, 1) NOT NULL,
    [strName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]					NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDateModified]			DATETIME        NOT NULL,
    [intSize]					INT             NOT NULL,
	[intDocumentSourceFolderId] INT				NULL,
	[intTransactionId]			INT				NOT NULL,
	[intEntityId]				INT				NOT NULL,
	[intUploadId]				INT				NOT NULL,
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [FK_tblSMDocument_tblSMDocumentSourceFolder] FOREIGN KEY ([intDocumentSourceFolderId]) REFERENCES [dbo].[tblSMDocumentSourceFolder] ([intDocumentSourceFolderId]),
	CONSTRAINT [FK_tblSMDocument_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblSMTransaction] ([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMDocument_tblSMUpload] FOREIGN KEY ([intUploadId]) REFERENCES [dbo].[tblSMUpload] ([intUploadId]),
	CONSTRAINT [FK_tblSMDocument_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [PK_dbo.tblSMDocument] PRIMARY KEY CLUSTERED ([intDocumentId] ASC)
);







