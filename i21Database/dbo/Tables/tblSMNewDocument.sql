CREATE TABLE [dbo].[tblSMNewDocument] (
    [intNewDocumentId]			INT             IDENTITY (1, 1) NOT NULL,
    [strName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]					NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDateModified]			DATETIME        NOT NULL,
    [intSize]					INT             NOT NULL,
	[intEntityId]				INT				NOT NULL,
	[intUploadId]				INT				NOT NULL,
	[ysnPending]				BIT				NULL,
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [FK_tblSMNewDocument_tblSMUpload] FOREIGN KEY ([intUploadId]) REFERENCES [dbo].[tblSMUpload] ([intUploadId]),
	CONSTRAINT [FK_tblSMNewDocument_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [PK_dbo.tblSMNewDocument] PRIMARY KEY CLUSTERED ([intNewDocumentId] ASC)
);