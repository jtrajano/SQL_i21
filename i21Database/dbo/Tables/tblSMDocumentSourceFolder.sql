CREATE TABLE [dbo].[tblSMDocumentSourceFolder]
(
	[intDocumentSourceFolderId]	INT             IDENTITY (1, 1) NOT NULL,
	[intScreenId]				INT             NOT NULL,
    [strName]					NVARCHAR (255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intSort]					INT             NOT NULL,
	[intDocumentTypeId]			INT             NULL,
	[intDocumentFolderParentId]	INT             NULL,
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [FK_tblSMDocumentSourceFolder_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMDocumentSourceFolder_tblSMDocumentType] FOREIGN KEY ([intDocumentTypeId]) REFERENCES [dbo].[tblSMDocumentType] ([intDocumentTypeId]),
	CONSTRAINT [FK_tblSMDocumentSourceFolder_tblSMDocumentSourceFolder] FOREIGN KEY ([intDocumentFolderParentId]) REFERENCES [dbo].[tblSMDocumentSourceFolder] ([intDocumentSourceFolderId]),
    CONSTRAINT [PK_dbo.tblSMDocumentSourceFolder] PRIMARY KEY CLUSTERED ([intDocumentSourceFolderId] ASC)
)