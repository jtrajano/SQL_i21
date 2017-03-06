CREATE TABLE [dbo].[tblSMDocumentTypeField] (
    [intDocumentTypeFieldId]	INT             IDENTITY (1, 1) NOT NULL,
	[intDocumentTypeId]			INT             NOT NULL,
    [strFieldName]				NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strFieldType]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intSort]					INT             NOT NULL,
	[ysnRequired]				BIT             NOT NULL,
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [FK_tblSMDocumentTypeField_tblSMDocumentType] FOREIGN KEY ([intDocumentTypeId]) REFERENCES [dbo].[tblSMDocumentType] ([intDocumentTypeId]) ON DELETE CASCADE,
    CONSTRAINT [PK_dbo.tblSMDocumentTypeField] PRIMARY KEY CLUSTERED ([intDocumentTypeFieldId] ASC)
);







