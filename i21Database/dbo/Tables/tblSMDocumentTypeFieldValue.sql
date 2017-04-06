CREATE TABLE [dbo].[tblSMDocumentTypeFieldValue] (
    [intDocumentTypeFieldValueId]	INT             IDENTITY (1, 1) NOT NULL,
	[intDocumentTypeFieldId]		INT             NOT NULL,
	[intDocumentId]					INT             NOT NULL,
    [strValue]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intValue]						INT				NULL,
	[dblValue]						NUMERIC(18,6)	NULL,
	[dtmValue]						DATETIME		NULL,
	[ysnValue]						BIT	NULL,
    [intConcurrencyId]				INT				NOT NULL,
	CONSTRAINT [FK_tblSMDocumentTypeFieldValue_tblSMDocumentTypeField] FOREIGN KEY ([intDocumentTypeFieldId]) REFERENCES [dbo].[tblSMDocumentTypeField] ([intDocumentTypeFieldId]),
	CONSTRAINT [FK_tblSMDocumentTypeFieldValue_tblSMDocument] FOREIGN KEY ([intDocumentId]) REFERENCES [dbo].[tblSMDocument] ([intDocumentId]) ON DELETE CASCADE,
    CONSTRAINT [PK_dbo.tblSMDocumentTypeValue] PRIMARY KEY CLUSTERED ([intDocumentTypeFieldValueId] ASC)
);