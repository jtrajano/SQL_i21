CREATE TABLE [dbo].[tblSMIDPFieldMapping] (
    [intIDPFieldMappingId]			INT IDENTITY (1, 1) NOT NULL,
    [intScreenId]					INT NOT NULL,
    [intIDPFieldMappingFieldId]		INT NOT NULL,
	[strDocumentTag]				NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]				INT DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblSMIDPFieldMapping] PRIMARY KEY CLUSTERED ([intIDPFieldMappingId] ASC),
    CONSTRAINT [FK_tblSMIDPFieldMapping_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId])
);

