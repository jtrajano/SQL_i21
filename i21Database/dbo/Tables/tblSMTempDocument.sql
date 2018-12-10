CREATE TABLE [dbo].[tblSMTempDocument] (
    [intDocumentId]				INT             NULL,
    [strName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]					NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDateModified]			DATETIME        NOT NULL,
    [intSize]					INT             NOT NULL,
	[intDocumentSourceFolderId] INT				NULL,
	[intTransactionId]			INT				NOT NULL,
	[intEntityId]				INT				NOT NULL,
	[intUploadId]				INT				NOT NULL,
	[ysnPending]				BIT				NULL DEFAULT(0),
    [intConcurrencyId]			INT				NOT NULL

);