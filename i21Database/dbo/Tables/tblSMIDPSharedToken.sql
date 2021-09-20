CREATE TABLE [dbo].[tblSMIDPSharedToken]
(
	[intIDPSharedTokenId]			INT IDENTITY (1, 1) NOT NULL,
	[intEntityId]					INT NOT NULL,
	[strProjectName]				NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSharedToken]				NVARCHAR (1000) COLLATE Latin1_General_CI_AS NOT NULL,
	[strConnectionName]				NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strConnectionSasURI]			NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]				INT DEFAULT (1) NOT NULL,

	CONSTRAINT [PK_tblSMIDPSharedToken] PRIMARY KEY CLUSTERED ([intIDPSharedTokenId] ASC)
)
