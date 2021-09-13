CREATE TABLE [dbo].[tblSMIDPFieldMappingTable] (
    [intIDPFieldMappingTableId]	INT IDENTITY (1, 1) NOT NULL,
    [intIDPFieldMappingId]				INT NOT NULL,
    [intIDPFieldMappingFieldId]			INT NOT NULL,
	[strDocumentTag]					NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]					INT DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblSMIDPFieldMappingTable] PRIMARY KEY CLUSTERED ([intIDPFieldMappingTableId] ASC),
    CONSTRAINT [FK_tblSMIDPFieldMappingTable_tblSMIDPFieldMapping] FOREIGN KEY ([intIDPFieldMappingId]) REFERENCES [dbo].[tblSMIDPFieldMapping] ([intIDPFieldMappingId]) ON DELETE CASCADE
);


