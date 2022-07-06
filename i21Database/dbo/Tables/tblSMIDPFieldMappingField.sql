CREATE TABLE [dbo].[tblSMIDPFieldMappingField] (
    [intIDPFieldMappingFieldId]			INT IDENTITY (1, 1) NOT NULL,
    [intScreenId]						INT NOT NULL,
    [strField]							NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFieldDataIndex]					NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDetailTable]					BIT NULL,
	[ysnDetail]							BIT NULL,
    [intConcurrencyId]					INT DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblSMIDPFieldMappingField] PRIMARY KEY CLUSTERED ([intIDPFieldMappingFieldId] ASC),
    CONSTRAINT [FK_tblSMIDPFieldMappingField_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId])
);

